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

#line 191 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means);

#line 94 "StatisticsModule.cs"
__device__ double mathblocks_statistics_correlation_value(double covariance, double left_variance, double right_variance);

#line 369 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 106 "StatisticsModule.cs"
__device__ double mathblocks_statistics_distance_correlation_value(
    double covariance_square,
    double left_variance_square,
    double right_variance_square);

#line 238 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_kendall_value(
    const double* left_values,
    const double* right_values,
    int count,
    double* value);

#line 49 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count);

#line 163 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count);

#line 218 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_moment_value(
    const double* values,
    int count,
    double order_value,
    bool central,
    double* value);

#line 334 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_averages(
    const double* values,
    int count,
    double* averages);

#line 349 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_slopes(
    const double* x,
    const double* y,
    int count,
    double* slopes);

#line 119 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count);

#line 70 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count);

#line 55 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count);

#line 85 "StatisticsModule.cs"
__device__ double mathblocks_statistics_quotient_by_variance(double covariance, double variance);

#line 170 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result);

#line 276 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_shape_moment_value(
    const double* values,
    int count,
    bool kurtosis,
    double* value);

#line 138 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result,
    bool descending);

#line 148 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability);

#line 303 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_weighted_value(
    const double* values,
    const double* weights,
    int count,
    bool variance,
    double* value);

#line 191 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means)
#line 197 "StatisticsModule.cs"
{
#line 198 "StatisticsModule.cs"
    double total_mean = 0.0;
#line 199 "StatisticsModule.cs"
    {
#line 199 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 200 "StatisticsModule.cs"
            {
#line 201 "StatisticsModule.cs"
#line 201 "StatisticsModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 202 "StatisticsModule.cs"
                {
#line 202 "StatisticsModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 203 "StatisticsModule.cs"
                        {
#line 204 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 204 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 204 "StatisticsModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 205 "StatisticsModule.cs"
#line 205 "StatisticsModule.cs"
                            double* csharp2cuda_temp_5 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
                            (*(csharp2cuda_temp_5) = distance);
#line 206 "StatisticsModule.cs"
#line 206 "StatisticsModule.cs"
                            double* csharp2cuda_temp_6 = &((row_means)[row]);
#line 206 "StatisticsModule.cs"
                            double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
                            (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, distance));
#line 207 "StatisticsModule.cs"
#line 207 "StatisticsModule.cs"
                            double* csharp2cuda_temp_8 = &(total_mean);
#line 207 "StatisticsModule.cs"
                            double csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
                            (*(csharp2cuda_temp_8) = __dadd_rn(csharp2cuda_temp_9, distance));
                        }
#line 202 "StatisticsModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 209 "StatisticsModule.cs"
#line 209 "StatisticsModule.cs"
                double* csharp2cuda_temp_10 = &((row_means)[row]);
#line 209 "StatisticsModule.cs"
                double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                (*(csharp2cuda_temp_10) = __ddiv_rn(csharp2cuda_temp_11, ((double)(count))));
            }
#line 199 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 211 "StatisticsModule.cs"
#line 211 "StatisticsModule.cs"
    double* csharp2cuda_temp_12 = &(total_mean);
#line 211 "StatisticsModule.cs"
    double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
    (*(csharp2cuda_temp_12) = __ddiv_rn(csharp2cuda_temp_13, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 212 "StatisticsModule.cs"
    {
#line 212 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 213 "StatisticsModule.cs"
            {
#line 213 "StatisticsModule.cs"
                int column = 0;
                while (true)
                {
                    if (!(((column) < (count))))
                        break;
#line 214 "StatisticsModule.cs"
#line 214 "StatisticsModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
#line 214 "StatisticsModule.cs"
                    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
#line 215 "StatisticsModule.cs"
                    double csharp2cuda_temp_18 = (row_means)[row];
#line 215 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (row_means)[column];
                    (*(csharp2cuda_temp_16) = __dsub_rn(csharp2cuda_temp_17, __dsub_rn(__dadd_rn(csharp2cuda_temp_18, csharp2cuda_temp_19), total_mean)));
#line 213 "StatisticsModule.cs"
                    int* csharp2cuda_temp_15 = &(column);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                }
            }
#line 212 "StatisticsModule.cs"
            int* csharp2cuda_temp_14 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
}

#line 94 "StatisticsModule.cs"
__device__ double mathblocks_statistics_correlation_value(double covariance, double left_variance, double right_variance)
#line 96 "StatisticsModule.cs"
{
#line 97 "StatisticsModule.cs"
#line 97 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 97 "StatisticsModule.cs"
    if (!((!(isfinite(left_variance)))))
    {
#line 97 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(isfinite(right_variance)));
    }
    else
    {
#line 97 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 98 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 99 "StatisticsModule.cs"
    double denominator = __dmul_rn(mathblocks_square_root(left_variance), mathblocks_square_root(right_variance));
#line 100 "StatisticsModule.cs"
    if ((!(isfinite(denominator))))
    {
#line 101 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 102 "StatisticsModule.cs"
    return __ddiv_rn(covariance, denominator);
}

#line 369 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 375 "StatisticsModule.cs"
{
#line 376 "StatisticsModule.cs"
    int thread = threadIdx.x;
#line 377 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 377 "StatisticsModule.cs"
    if (((input_count) > (0)))
    {
#line 377 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 377 "StatisticsModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 377 "StatisticsModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 378 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 378 "StatisticsModule.cs"
    if (((input_count) > (1)))
    {
#line 378 "StatisticsModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 378 "StatisticsModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 378 "StatisticsModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 379 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 380 "StatisticsModule.cs"
    {
#line 381 "StatisticsModule.cs"
#line 381 "StatisticsModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 382 "StatisticsModule.cs"
#line 382 "StatisticsModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 383 "StatisticsModule.cs"
#line 383 "StatisticsModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 384 "StatisticsModule.cs"
#line 384 "StatisticsModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 385 "StatisticsModule.cs"
#line 385 "StatisticsModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 386 "StatisticsModule.cs"
#line 386 "StatisticsModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 386 "StatisticsModule.cs"
        bool csharp2cuda_temp_8;
#line 386 "StatisticsModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 386 "StatisticsModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 386 "StatisticsModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 387 "StatisticsModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 388 "StatisticsModule.cs"
#line 388 "StatisticsModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 388 "StatisticsModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 388 "StatisticsModule.cs"
            bool csharp2cuda_temp_11;
#line 388 "StatisticsModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 388 "StatisticsModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 388 "StatisticsModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 390 "StatisticsModule.cs"
    __syncthreads();
#line 391 "StatisticsModule.cs"
#line 391 "StatisticsModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 392 "StatisticsModule.cs"
        return;
    }
#line 394 "StatisticsModule.cs"
    double* csharp2cuda_temp_13;
#line 394 "StatisticsModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 394 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 394 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 394 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 394 "StatisticsModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 395 "StatisticsModule.cs"
    double* csharp2cuda_temp_15;
#line 395 "StatisticsModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 395 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 395 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 395 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 395 "StatisticsModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 396 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 396 "StatisticsModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 397 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 397 "StatisticsModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 399 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 400 "StatisticsModule.cs"
    {
#line 401 "StatisticsModule.cs"
        switch (opcode)
        {
#line 403 "StatisticsModule.cs"
            case 0:
#line 404 "StatisticsModule.cs"
                {
#line 405 "StatisticsModule.cs"
                    int lag = 0;
#line 406 "StatisticsModule.cs"
#line 406 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (second)->scalar_value;
#line 406 "StatisticsModule.cs"
                    int* csharp2cuda_temp_20 = &(lag);
#line 406 "StatisticsModule.cs"
                    bool csharp2cuda_temp_21 = mathblocks_sequence_positive_integer(csharp2cuda_temp_19, csharp2cuda_temp_20);
#line 406 "StatisticsModule.cs"
                    bool csharp2cuda_temp_22;
#line 406 "StatisticsModule.cs"
                    if (!((!(csharp2cuda_temp_21))))
                    {
#line 406 "StatisticsModule.cs"
                        int csharp2cuda_temp_23 = (first)->count;
#line 406 "StatisticsModule.cs"
                        csharp2cuda_temp_22 = ((lag) >= (csharp2cuda_temp_23));
                    }
                    else
                    {
#line 406 "StatisticsModule.cs"
                        csharp2cuda_temp_22 = true;
                    }
                    if (csharp2cuda_temp_22)
#line 407 "StatisticsModule.cs"
                    {
#line 408 "StatisticsModule.cs"
#line 408 "StatisticsModule.cs"
                        int* csharp2cuda_temp_24 = &((output)->valid);
                        (*(csharp2cuda_temp_24) = 0);
#line 409 "StatisticsModule.cs"
                        break;
                    }
#line 411 "StatisticsModule.cs"
                    int csharp2cuda_temp_25 = (first)->count;
#line 411 "StatisticsModule.cs"
                    int count = csharp2cuda_i32_sub(csharp2cuda_temp_25, lag);
#line 412 "StatisticsModule.cs"
#line 412 "StatisticsModule.cs"
                    double* csharp2cuda_temp_26 = &((output)->scalar_value);
#line 412 "StatisticsModule.cs"
                    double csharp2cuda_temp_27 = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), count);
                    (*(csharp2cuda_temp_26) = csharp2cuda_temp_27);
#line 413 "StatisticsModule.cs"
                    break;
                }
#line 415 "StatisticsModule.cs"
            case 1:
            case 18:
#line 417 "StatisticsModule.cs"
#line 419 "StatisticsModule.cs"
                int csharp2cuda_temp_28 = (first)->count;
#line 420 "StatisticsModule.cs"
                double csharp2cuda_temp_29 = (second)->scalar_value;
#line 422 "StatisticsModule.cs"
                double* csharp2cuda_temp_30 = &((output)->scalar_value);
#line 417 "StatisticsModule.cs"
                bool csharp2cuda_temp_31 = mathblocks_statistics_moment_value(a, csharp2cuda_temp_28, csharp2cuda_temp_29, ((opcode) == (1)), csharp2cuda_temp_30);
                if ((!(csharp2cuda_temp_31)))
                {
#line 423 "StatisticsModule.cs"
#line 423 "StatisticsModule.cs"
                    int* csharp2cuda_temp_32 = &((output)->valid);
                    (*(csharp2cuda_temp_32) = 0);
                }
#line 424 "StatisticsModule.cs"
                break;
#line 425 "StatisticsModule.cs"
            case 2:
#line 426 "StatisticsModule.cs"
                {
#line 427 "StatisticsModule.cs"
                    int rows = (first)->rows;
#line 428 "StatisticsModule.cs"
                    int columns = (first)->columns;
#line 429 "StatisticsModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, columns, columns);
#line 430 "StatisticsModule.cs"
#line 430 "StatisticsModule.cs"
                    bool csharp2cuda_temp_33;
#line 430 "StatisticsModule.cs"
                    if (!(((rows) <= (0))))
                    {
#line 430 "StatisticsModule.cs"
                        csharp2cuda_temp_33 = ((columns) <= (0));
                    }
                    else
                    {
#line 430 "StatisticsModule.cs"
                        csharp2cuda_temp_33 = true;
                    }
#line 430 "StatisticsModule.cs"
                    bool csharp2cuda_temp_34;
#line 430 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_33))
                    {
#line 430 "StatisticsModule.cs"
                        csharp2cuda_temp_34 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 430 "StatisticsModule.cs"
                        csharp2cuda_temp_34 = true;
                    }
                    if (csharp2cuda_temp_34)
#line 431 "StatisticsModule.cs"
                    {
#line 432 "StatisticsModule.cs"
#line 432 "StatisticsModule.cs"
                        int* csharp2cuda_temp_35 = &((output)->valid);
                        (*(csharp2cuda_temp_35) = 0);
#line 433 "StatisticsModule.cs"
                        break;
                    }
#line 435 "StatisticsModule.cs"
                    {
#line 435 "StatisticsModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (columns))))
                                break;
#line 436 "StatisticsModule.cs"
                            {
#line 437 "StatisticsModule.cs"
#line 437 "StatisticsModule.cs"
                                double* csharp2cuda_temp_37 = &((scratch)[column]);
                                (*(csharp2cuda_temp_37) = 0.0);
#line 438 "StatisticsModule.cs"
                                {
#line 438 "StatisticsModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
                                        if (!(((row) < (rows))))
                                            break;
#line 439 "StatisticsModule.cs"
#line 439 "StatisticsModule.cs"
                                        double* csharp2cuda_temp_39 = &((scratch)[column]);
#line 439 "StatisticsModule.cs"
                                        double csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
#line 439 "StatisticsModule.cs"
                                        double csharp2cuda_temp_41 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 439 "StatisticsModule.cs"
                                        double csharp2cuda_temp_42 = __ddiv_rn(csharp2cuda_temp_41, ((double)(rows)));
                                        (*(csharp2cuda_temp_39) = __dadd_rn(csharp2cuda_temp_40, csharp2cuda_temp_42));
#line 438 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_38 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_38));
                                    }
                                }
                            }
#line 435 "StatisticsModule.cs"
                            int* csharp2cuda_temp_36 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_36));
                        }
                    }
#line 441 "StatisticsModule.cs"
                    {
#line 441 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (columns))))
                                break;
#line 442 "StatisticsModule.cs"
                            {
#line 443 "StatisticsModule.cs"
                                {
#line 443 "StatisticsModule.cs"
                                    int right = left;
                                    while (true)
                                    {
                                        if (!(((right) < (columns))))
                                            break;
#line 444 "StatisticsModule.cs"
                                        {
#line 445 "StatisticsModule.cs"
                                            double sum = 0.0;
#line 446 "StatisticsModule.cs"
                                            {
#line 446 "StatisticsModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 447 "StatisticsModule.cs"
                                                    {
#line 448 "StatisticsModule.cs"
#line 448 "StatisticsModule.cs"
                                                        double* csharp2cuda_temp_46 = &(sum);
#line 448 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_47 = *(csharp2cuda_temp_46);
#line 448 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_48 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), left)];
#line 448 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_49 = (scratch)[left];
#line 449 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_50 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), right)];
#line 449 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_51 = (scratch)[right];
                                                        (*(csharp2cuda_temp_46) = __dadd_rn(csharp2cuda_temp_47, __dmul_rn(__dsub_rn(csharp2cuda_temp_48, csharp2cuda_temp_49), __dsub_rn(csharp2cuda_temp_50, csharp2cuda_temp_51))));
                                                    }
#line 446 "StatisticsModule.cs"
                                                    int* csharp2cuda_temp_45 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                                                }
                                            }
#line 451 "StatisticsModule.cs"
                                            double covariance = __ddiv_rn(sum, ((double)(rows)));
#line 452 "StatisticsModule.cs"
#line 452 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_52 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), right)]);
                                            (*(csharp2cuda_temp_52) = covariance);
#line 453 "StatisticsModule.cs"
#line 453 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_53 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), left)]);
                                            (*(csharp2cuda_temp_53) = covariance);
#line 454 "StatisticsModule.cs"
                                            if ((!(isfinite(covariance))))
                                            {
#line 454 "StatisticsModule.cs"
#line 454 "StatisticsModule.cs"
                                                int* csharp2cuda_temp_54 = &((output)->valid);
                                                (*(csharp2cuda_temp_54) = 0);
                                            }
                                        }
#line 443 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_44 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_44));
                                    }
                                }
                            }
#line 441 "StatisticsModule.cs"
                            int* csharp2cuda_temp_43 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_43));
                        }
                    }
#line 457 "StatisticsModule.cs"
                    break;
                }
#line 459 "StatisticsModule.cs"
            case 3:
#line 460 "StatisticsModule.cs"
                {
#line 461 "StatisticsModule.cs"
                    int count = (first)->count;
#line 462 "StatisticsModule.cs"
#line 462 "StatisticsModule.cs"
                    bool csharp2cuda_temp_55;
#line 462 "StatisticsModule.cs"
                    if (!(((count) <= (0))))
                    {
#line 462 "StatisticsModule.cs"
                        int csharp2cuda_temp_56 = (second)->count;
#line 462 "StatisticsModule.cs"
                        csharp2cuda_temp_55 = ((count) != (csharp2cuda_temp_56));
                    }
                    else
                    {
#line 462 "StatisticsModule.cs"
                        csharp2cuda_temp_55 = true;
                    }
#line 462 "StatisticsModule.cs"
                    bool csharp2cuda_temp_57;
#line 462 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_55))
                    {
#line 462 "StatisticsModule.cs"
                        csharp2cuda_temp_57 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 462 "StatisticsModule.cs"
                        csharp2cuda_temp_57 = true;
                    }
                    if (csharp2cuda_temp_57)
#line 463 "StatisticsModule.cs"
                    {
#line 464 "StatisticsModule.cs"
#line 464 "StatisticsModule.cs"
                        int* csharp2cuda_temp_58 = &((output)->valid);
                        (*(csharp2cuda_temp_58) = 0);
#line 465 "StatisticsModule.cs"
                        break;
                    }
#line 467 "StatisticsModule.cs"
                    double* left_distances = scratch;
#line 468 "StatisticsModule.cs"
                    double* right_distances = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(count, count));
#line 469 "StatisticsModule.cs"
                    double* row_means = csharp2cuda_pointer_add(right_distances, csharp2cuda_i32_mul(count, count));
#line 470 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(a, count, left_distances, row_means);
#line 471 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(b, count, right_distances, row_means);
#line 472 "StatisticsModule.cs"
                    double covariance_square = 0.0;
#line 473 "StatisticsModule.cs"
                    double left_variance_square = 0.0;
#line 474 "StatisticsModule.cs"
                    double right_variance_square = 0.0;
#line 475 "StatisticsModule.cs"
                    {
#line 475 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 476 "StatisticsModule.cs"
                            {
#line 477 "StatisticsModule.cs"
#line 477 "StatisticsModule.cs"
                                double* csharp2cuda_temp_60 = &(covariance_square);
#line 477 "StatisticsModule.cs"
                                double csharp2cuda_temp_61 = *(csharp2cuda_temp_60);
#line 477 "StatisticsModule.cs"
                                double csharp2cuda_temp_62 = (left_distances)[index];
#line 477 "StatisticsModule.cs"
                                double csharp2cuda_temp_63 = (right_distances)[index];
                                (*(csharp2cuda_temp_60) = __dadd_rn(csharp2cuda_temp_61, __dmul_rn(csharp2cuda_temp_62, csharp2cuda_temp_63)));
#line 478 "StatisticsModule.cs"
#line 478 "StatisticsModule.cs"
                                double* csharp2cuda_temp_64 = &(left_variance_square);
#line 478 "StatisticsModule.cs"
                                double csharp2cuda_temp_65 = *(csharp2cuda_temp_64);
#line 478 "StatisticsModule.cs"
                                double csharp2cuda_temp_66 = (left_distances)[index];
#line 478 "StatisticsModule.cs"
                                double csharp2cuda_temp_67 = (left_distances)[index];
                                (*(csharp2cuda_temp_64) = __dadd_rn(csharp2cuda_temp_65, __dmul_rn(csharp2cuda_temp_66, csharp2cuda_temp_67)));
#line 479 "StatisticsModule.cs"
#line 479 "StatisticsModule.cs"
                                double* csharp2cuda_temp_68 = &(right_variance_square);
#line 479 "StatisticsModule.cs"
                                double csharp2cuda_temp_69 = *(csharp2cuda_temp_68);
#line 479 "StatisticsModule.cs"
                                double csharp2cuda_temp_70 = (right_distances)[index];
#line 479 "StatisticsModule.cs"
                                double csharp2cuda_temp_71 = (right_distances)[index];
                                (*(csharp2cuda_temp_68) = __dadd_rn(csharp2cuda_temp_69, __dmul_rn(csharp2cuda_temp_70, csharp2cuda_temp_71)));
                            }
#line 475 "StatisticsModule.cs"
                            int* csharp2cuda_temp_59 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_59));
                        }
                    }
#line 481 "StatisticsModule.cs"
#line 481 "StatisticsModule.cs"
                    double* csharp2cuda_temp_72 = &(covariance_square);
#line 481 "StatisticsModule.cs"
                    double csharp2cuda_temp_73 = *(csharp2cuda_temp_72);
                    (*(csharp2cuda_temp_72) = __ddiv_rn(csharp2cuda_temp_73, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 482 "StatisticsModule.cs"
#line 482 "StatisticsModule.cs"
                    double* csharp2cuda_temp_74 = &(left_variance_square);
#line 482 "StatisticsModule.cs"
                    double csharp2cuda_temp_75 = *(csharp2cuda_temp_74);
                    (*(csharp2cuda_temp_74) = __ddiv_rn(csharp2cuda_temp_75, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 483 "StatisticsModule.cs"
#line 483 "StatisticsModule.cs"
                    double* csharp2cuda_temp_76 = &(right_variance_square);
#line 483 "StatisticsModule.cs"
                    double csharp2cuda_temp_77 = *(csharp2cuda_temp_76);
                    (*(csharp2cuda_temp_76) = __ddiv_rn(csharp2cuda_temp_77, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 484 "StatisticsModule.cs"
#line 484 "StatisticsModule.cs"
                    double* csharp2cuda_temp_78 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_78) = mathblocks_statistics_distance_correlation_value(covariance_square, left_variance_square, right_variance_square));
#line 486 "StatisticsModule.cs"
                    break;
                }
#line 488 "StatisticsModule.cs"
            case 4:
#line 489 "StatisticsModule.cs"
                {
#line 490 "StatisticsModule.cs"
#line 490 "StatisticsModule.cs"
                    int csharp2cuda_temp_79 = (second)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_79, 1));
#line 491 "StatisticsModule.cs"
                    {
#line 491 "StatisticsModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 491 "StatisticsModule.cs"
                            int csharp2cuda_temp_81 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_81))))
                                break;
#line 492 "StatisticsModule.cs"
                            {
#line 493 "StatisticsModule.cs"
#line 493 "StatisticsModule.cs"
                                double csharp2cuda_temp_82 = (b)[index];
#line 493 "StatisticsModule.cs"
                                double csharp2cuda_temp_83 = (b)[csharp2cuda_i32_sub(index, 1)];
                                if (((csharp2cuda_temp_82) <= (csharp2cuda_temp_83)))
#line 494 "StatisticsModule.cs"
                                {
#line 495 "StatisticsModule.cs"
#line 495 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_84 = &((output)->valid);
                                    (*(csharp2cuda_temp_84) = 0);
#line 496 "StatisticsModule.cs"
                                    break;
                                }
                            }
#line 491 "StatisticsModule.cs"
                            int* csharp2cuda_temp_80 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_80));
                        }
                    }
#line 499 "StatisticsModule.cs"
                    {
#line 499 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 499 "StatisticsModule.cs"
                            bool csharp2cuda_temp_86 = (output)->valid;
#line 499 "StatisticsModule.cs"
                            bool csharp2cuda_temp_87;
#line 499 "StatisticsModule.cs"
                            if (csharp2cuda_temp_86)
                            {
#line 499 "StatisticsModule.cs"
                                int csharp2cuda_temp_88 = (output)->count;
#line 499 "StatisticsModule.cs"
                                csharp2cuda_temp_87 = ((index) < (csharp2cuda_temp_88));
                            }
                            else
                            {
#line 499 "StatisticsModule.cs"
                                csharp2cuda_temp_87 = false;
                            }
                            if (!(csharp2cuda_temp_87))
                                break;
#line 500 "StatisticsModule.cs"
#line 500 "StatisticsModule.cs"
                            double* csharp2cuda_temp_89 = &((result)[index]);
                            (*(csharp2cuda_temp_89) = 0.0);
#line 499 "StatisticsModule.cs"
                            int* csharp2cuda_temp_85 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_85));
                        }
                    }
#line 501 "StatisticsModule.cs"
                    {
#line 501 "StatisticsModule.cs"
                        int value_index = 0;
                        while (true)
                        {
#line 501 "StatisticsModule.cs"
                            bool csharp2cuda_temp_91 = (output)->valid;
#line 501 "StatisticsModule.cs"
                            bool csharp2cuda_temp_92;
#line 501 "StatisticsModule.cs"
                            if (csharp2cuda_temp_91)
                            {
#line 501 "StatisticsModule.cs"
                                int csharp2cuda_temp_93 = (first)->count;
#line 501 "StatisticsModule.cs"
                                csharp2cuda_temp_92 = ((value_index) < (csharp2cuda_temp_93));
                            }
                            else
                            {
#line 501 "StatisticsModule.cs"
                                csharp2cuda_temp_92 = false;
                            }
                            if (!(csharp2cuda_temp_92))
                                break;
#line 502 "StatisticsModule.cs"
                            {
#line 503 "StatisticsModule.cs"
                                int lower = 0;
#line 504 "StatisticsModule.cs"
                                int upper = (second)->count;
#line 505 "StatisticsModule.cs"
                                while (true)
                                {
                                    if (!(((lower) < (upper))))
                                        break;
#line 506 "StatisticsModule.cs"
                                    {
#line 507 "StatisticsModule.cs"
                                        int csharp2cuda_temp_94 = csharp2cuda_i32_div(csharp2cuda_i32_sub(upper, lower), 2);
#line 507 "StatisticsModule.cs"
                                        int middle = csharp2cuda_i32_add(lower, csharp2cuda_temp_94);
#line 508 "StatisticsModule.cs"
#line 508 "StatisticsModule.cs"
                                        double csharp2cuda_temp_95 = (a)[value_index];
#line 508 "StatisticsModule.cs"
                                        double csharp2cuda_temp_96 = (b)[middle];
                                        if (((csharp2cuda_temp_95) <= (csharp2cuda_temp_96)))
                                        {
#line 509 "StatisticsModule.cs"
#line 509 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_97 = &(upper);
                                            (*(csharp2cuda_temp_97) = middle);
                                        }
                                        else
                                        {
#line 511 "StatisticsModule.cs"
#line 511 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_98 = &(lower);
                                            (*(csharp2cuda_temp_98) = csharp2cuda_i32_add(middle, 1));
                                        }
                                    }
                                }
#line 513 "StatisticsModule.cs"
#line 513 "StatisticsModule.cs"
                                double* csharp2cuda_temp_99 = &((result)[lower]);
#line 513 "StatisticsModule.cs"
                                double csharp2cuda_temp_100 = *(csharp2cuda_temp_99);
                                (*(csharp2cuda_temp_99) = __dadd_rn(csharp2cuda_temp_100, 1.0));
                            }
#line 501 "StatisticsModule.cs"
                            int* csharp2cuda_temp_90 = &(value_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_90));
                        }
                    }
#line 515 "StatisticsModule.cs"
                    break;
                }
#line 517 "StatisticsModule.cs"
            case 5:
#line 518 "StatisticsModule.cs"
                {
#line 519 "StatisticsModule.cs"
#line 519 "StatisticsModule.cs"
                    int csharp2cuda_temp_101 = (first)->count;
#line 519 "StatisticsModule.cs"
                    bool csharp2cuda_temp_102;
#line 519 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_101) <= (0))))
                    {
#line 519 "StatisticsModule.cs"
                        csharp2cuda_temp_102 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 519 "StatisticsModule.cs"
                        csharp2cuda_temp_102 = true;
                    }
                    if (csharp2cuda_temp_102)
#line 520 "StatisticsModule.cs"
                    {
#line 521 "StatisticsModule.cs"
#line 521 "StatisticsModule.cs"
                        int* csharp2cuda_temp_103 = &((output)->valid);
                        (*(csharp2cuda_temp_103) = 0);
#line 522 "StatisticsModule.cs"
                        break;
                    }
#line 524 "StatisticsModule.cs"
#line 524 "StatisticsModule.cs"
                    int csharp2cuda_temp_104 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_104, scratch, false);
#line 525 "StatisticsModule.cs"
#line 525 "StatisticsModule.cs"
                    double* csharp2cuda_temp_105 = &((output)->scalar_value);
#line 526 "StatisticsModule.cs"
                    int csharp2cuda_temp_106 = (first)->count;
#line 526 "StatisticsModule.cs"
                    double csharp2cuda_temp_107 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_106, 0.75);
#line 527 "StatisticsModule.cs"
                    int csharp2cuda_temp_108 = (first)->count;
#line 527 "StatisticsModule.cs"
                    double csharp2cuda_temp_109 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_108, 0.25);
                    (*(csharp2cuda_temp_105) = __dsub_rn(csharp2cuda_temp_107, csharp2cuda_temp_109));
#line 528 "StatisticsModule.cs"
                    break;
                }
#line 530 "StatisticsModule.cs"
            case 6:
#line 531 "StatisticsModule.cs"
#line 531 "StatisticsModule.cs"
                int csharp2cuda_temp_110 = (first)->count;
#line 531 "StatisticsModule.cs"
                int csharp2cuda_temp_111 = (second)->count;
#line 531 "StatisticsModule.cs"
                bool csharp2cuda_temp_112;
#line 531 "StatisticsModule.cs"
                if (!(((csharp2cuda_temp_110) != (csharp2cuda_temp_111))))
                {
#line 532 "StatisticsModule.cs"
                    int csharp2cuda_temp_113 = (first)->count;
#line 532 "StatisticsModule.cs"
                    double* csharp2cuda_temp_114 = &((output)->scalar_value);
#line 532 "StatisticsModule.cs"
                    bool csharp2cuda_temp_115 = mathblocks_statistics_kendall_value(a, b, csharp2cuda_temp_113, csharp2cuda_temp_114);
#line 531 "StatisticsModule.cs"
                    csharp2cuda_temp_112 = (!(csharp2cuda_temp_115));
                }
                else
                {
#line 531 "StatisticsModule.cs"
                    csharp2cuda_temp_112 = true;
                }
                if (csharp2cuda_temp_112)
                {
#line 533 "StatisticsModule.cs"
#line 533 "StatisticsModule.cs"
                    int* csharp2cuda_temp_116 = &((output)->valid);
                    (*(csharp2cuda_temp_116) = 0);
                }
#line 534 "StatisticsModule.cs"
                break;
#line 535 "StatisticsModule.cs"
            case 7:
            case 8:
            case 9:
            case 11:
            case 12:
            case 20:
#line 541 "StatisticsModule.cs"
                {
#line 542 "StatisticsModule.cs"
#line 542 "StatisticsModule.cs"
                    int csharp2cuda_temp_117 = (first)->count;
#line 542 "StatisticsModule.cs"
                    bool csharp2cuda_temp_118;
#line 542 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_117) <= (0))))
                    {
#line 542 "StatisticsModule.cs"
                        int csharp2cuda_temp_119 = (first)->count;
#line 542 "StatisticsModule.cs"
                        int csharp2cuda_temp_120 = (second)->count;
#line 542 "StatisticsModule.cs"
                        csharp2cuda_temp_118 = ((csharp2cuda_temp_119) != (csharp2cuda_temp_120));
                    }
                    else
                    {
#line 542 "StatisticsModule.cs"
                        csharp2cuda_temp_118 = true;
                    }
                    if (csharp2cuda_temp_118)
#line 543 "StatisticsModule.cs"
                    {
#line 544 "StatisticsModule.cs"
#line 544 "StatisticsModule.cs"
                        int* csharp2cuda_temp_121 = &((output)->valid);
                        (*(csharp2cuda_temp_121) = 0);
#line 545 "StatisticsModule.cs"
                        break;
                    }
#line 547 "StatisticsModule.cs"
                    int csharp2cuda_temp_122 = (first)->count;
#line 547 "StatisticsModule.cs"
                    double covariance = mathblocks_statistics_population_covariance(a, b, csharp2cuda_temp_122);
#line 548 "StatisticsModule.cs"
#line 548 "StatisticsModule.cs"
                    bool csharp2cuda_temp_123;
#line 548 "StatisticsModule.cs"
                    if (!(((opcode) == (12))))
                    {
#line 548 "StatisticsModule.cs"
                        csharp2cuda_temp_123 = ((opcode) == (20));
                    }
                    else
                    {
#line 548 "StatisticsModule.cs"
                        csharp2cuda_temp_123 = true;
                    }
                    if (csharp2cuda_temp_123)
#line 549 "StatisticsModule.cs"
                    {
#line 550 "StatisticsModule.cs"
#line 550 "StatisticsModule.cs"
                        double* csharp2cuda_temp_124 = &((output)->scalar_value);
#line 550 "StatisticsModule.cs"
                        double csharp2cuda_temp_125;
#line 550 "StatisticsModule.cs"
                        if (((opcode) == (12)))
                        {
#line 550 "StatisticsModule.cs"
                            csharp2cuda_temp_125 = covariance;
                        }
                        else
                        {
#line 552 "StatisticsModule.cs"
                            int csharp2cuda_temp_126 = (first)->count;
#line 552 "StatisticsModule.cs"
                            int csharp2cuda_temp_127 = (first)->count;
#line 550 "StatisticsModule.cs"
                            csharp2cuda_temp_125 = __ddiv_rn(__dmul_rn(covariance, ((double)(csharp2cuda_temp_126))), __dsub_rn(((double)(csharp2cuda_temp_127)), 1.0));
                        }
                        (*(csharp2cuda_temp_124) = csharp2cuda_temp_125);
                    }
                    else
                    {
#line 554 "StatisticsModule.cs"
                        if (((opcode) == (9)))
#line 555 "StatisticsModule.cs"
                        {
#line 556 "StatisticsModule.cs"
#line 556 "StatisticsModule.cs"
                            double* csharp2cuda_temp_128 = &((output)->scalar_value);
#line 557 "StatisticsModule.cs"
                            int csharp2cuda_temp_129 = (first)->count;
#line 557 "StatisticsModule.cs"
                            double csharp2cuda_temp_130 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_129);
                            (*(csharp2cuda_temp_128) = mathblocks_statistics_quotient_by_variance(covariance, csharp2cuda_temp_130));
                        }
                        else
                        {
#line 559 "StatisticsModule.cs"
                            if (((opcode) == (7)))
#line 560 "StatisticsModule.cs"
                            {
#line 562 "StatisticsModule.cs"
                                int csharp2cuda_temp_131 = (first)->count;
#line 562 "StatisticsModule.cs"
                                double csharp2cuda_temp_132 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_131);
#line 561 "StatisticsModule.cs"
                                double slope = mathblocks_statistics_quotient_by_variance(covariance, csharp2cuda_temp_132);
#line 563 "StatisticsModule.cs"
#line 563 "StatisticsModule.cs"
                                double* csharp2cuda_temp_133 = &((output)->scalar_value);
#line 563 "StatisticsModule.cs"
                                int csharp2cuda_temp_134 = (first)->count;
#line 563 "StatisticsModule.cs"
                                double csharp2cuda_temp_135 = mathblocks_statistics_mean(b, csharp2cuda_temp_134);
#line 564 "StatisticsModule.cs"
                                int csharp2cuda_temp_136 = (first)->count;
#line 564 "StatisticsModule.cs"
                                double csharp2cuda_temp_137 = mathblocks_statistics_mean(a, csharp2cuda_temp_136);
                                (*(csharp2cuda_temp_133) = __dsub_rn(csharp2cuda_temp_135, __dmul_rn(slope, csharp2cuda_temp_137)));
                            }
                            else
#line 567 "StatisticsModule.cs"
                            {
#line 570 "StatisticsModule.cs"
                                int csharp2cuda_temp_138 = (first)->count;
#line 570 "StatisticsModule.cs"
                                double csharp2cuda_temp_139 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_138);
#line 571 "StatisticsModule.cs"
                                int csharp2cuda_temp_140 = (first)->count;
#line 571 "StatisticsModule.cs"
                                double csharp2cuda_temp_141 = mathblocks_statistics_population_variance(b, csharp2cuda_temp_140);
#line 568 "StatisticsModule.cs"
                                double correlation = mathblocks_statistics_correlation_value(covariance, csharp2cuda_temp_139, csharp2cuda_temp_141);
#line 572 "StatisticsModule.cs"
#line 572 "StatisticsModule.cs"
                                double* csharp2cuda_temp_142 = &((output)->scalar_value);
#line 572 "StatisticsModule.cs"
                                double csharp2cuda_temp_143;
#line 572 "StatisticsModule.cs"
                                if (((opcode) == (8)))
                                {
#line 572 "StatisticsModule.cs"
                                    csharp2cuda_temp_143 = __dmul_rn(correlation, correlation);
                                }
                                else
                                {
#line 572 "StatisticsModule.cs"
                                    csharp2cuda_temp_143 = correlation;
                                }
                                (*(csharp2cuda_temp_142) = csharp2cuda_temp_143);
                            }
                        }
                    }
#line 574 "StatisticsModule.cs"
                    break;
                }
#line 576 "StatisticsModule.cs"
            case 10:
#line 577 "StatisticsModule.cs"
                {
#line 578 "StatisticsModule.cs"
#line 578 "StatisticsModule.cs"
                    int csharp2cuda_temp_144 = (first)->count;
#line 578 "StatisticsModule.cs"
                    bool csharp2cuda_temp_145;
#line 578 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_144) <= (0))))
                    {
#line 578 "StatisticsModule.cs"
                        csharp2cuda_temp_145 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 578 "StatisticsModule.cs"
                        csharp2cuda_temp_145 = true;
                    }
                    if (csharp2cuda_temp_145)
#line 579 "StatisticsModule.cs"
                    {
#line 580 "StatisticsModule.cs"
#line 580 "StatisticsModule.cs"
                        int* csharp2cuda_temp_146 = &((output)->valid);
                        (*(csharp2cuda_temp_146) = 0);
#line 581 "StatisticsModule.cs"
                        break;
                    }
#line 583 "StatisticsModule.cs"
                    double* sorted = scratch;
#line 584 "StatisticsModule.cs"
                    int csharp2cuda_temp_147 = (first)->count;
#line 584 "StatisticsModule.cs"
                    double* deviations = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_147);
#line 585 "StatisticsModule.cs"
#line 585 "StatisticsModule.cs"
                    int csharp2cuda_temp_148 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_148, sorted, false);
#line 586 "StatisticsModule.cs"
                    int csharp2cuda_temp_149 = (first)->count;
#line 586 "StatisticsModule.cs"
                    double median = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_149, 0.5);
#line 587 "StatisticsModule.cs"
                    {
#line 587 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 587 "StatisticsModule.cs"
                            int csharp2cuda_temp_151 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_151))))
                                break;
#line 588 "StatisticsModule.cs"
#line 588 "StatisticsModule.cs"
                            double* csharp2cuda_temp_152 = &((deviations)[index]);
#line 588 "StatisticsModule.cs"
                            double csharp2cuda_temp_153 = (a)[index];
                            (*(csharp2cuda_temp_152) = fabs(__dsub_rn(csharp2cuda_temp_153, median)));
#line 587 "StatisticsModule.cs"
                            int* csharp2cuda_temp_150 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_150));
                        }
                    }
#line 589 "StatisticsModule.cs"
#line 589 "StatisticsModule.cs"
                    int csharp2cuda_temp_154 = (first)->count;
                    mathblocks_statistics_sort_copy(deviations, csharp2cuda_temp_154, sorted, false);
#line 590 "StatisticsModule.cs"
#line 590 "StatisticsModule.cs"
                    double* csharp2cuda_temp_155 = &((output)->scalar_value);
#line 590 "StatisticsModule.cs"
                    int csharp2cuda_temp_156 = (first)->count;
#line 590 "StatisticsModule.cs"
                    double csharp2cuda_temp_157 = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_156, 0.5);
                    (*(csharp2cuda_temp_155) = csharp2cuda_temp_157);
#line 591 "StatisticsModule.cs"
                    break;
                }
#line 593 "StatisticsModule.cs"
            case 13:
            case 14:
#line 595 "StatisticsModule.cs"
#line 597 "StatisticsModule.cs"
                int csharp2cuda_temp_158 = (first)->count;
#line 599 "StatisticsModule.cs"
                double* csharp2cuda_temp_159 = &((output)->scalar_value);
#line 595 "StatisticsModule.cs"
                bool csharp2cuda_temp_160 = mathblocks_statistics_shape_moment_value(a, csharp2cuda_temp_158, ((opcode) == (13)), csharp2cuda_temp_159);
                if ((!(csharp2cuda_temp_160)))
                {
#line 600 "StatisticsModule.cs"
#line 600 "StatisticsModule.cs"
                    int* csharp2cuda_temp_161 = &((output)->valid);
                    (*(csharp2cuda_temp_161) = 0);
                }
#line 601 "StatisticsModule.cs"
                break;
#line 602 "StatisticsModule.cs"
            case 15:
            case 16:
            case 21:
            case 22:
#line 606 "StatisticsModule.cs"
                {
#line 607 "StatisticsModule.cs"
#line 607 "StatisticsModule.cs"
                    int csharp2cuda_temp_162 = (first)->count;
                    if (((csharp2cuda_temp_162) <= (0)))
#line 608 "StatisticsModule.cs"
                    {
#line 609 "StatisticsModule.cs"
#line 609 "StatisticsModule.cs"
                        int* csharp2cuda_temp_163 = &((output)->valid);
                        (*(csharp2cuda_temp_163) = 0);
#line 610 "StatisticsModule.cs"
                        break;
                    }
#line 612 "StatisticsModule.cs"
                    int csharp2cuda_temp_164 = (first)->count;
#line 612 "StatisticsModule.cs"
                    double variance = mathblocks_statistics_population_variance(a, csharp2cuda_temp_164);
#line 613 "StatisticsModule.cs"
#line 613 "StatisticsModule.cs"
                    bool csharp2cuda_temp_165;
#line 613 "StatisticsModule.cs"
                    if (!(((opcode) == (21))))
                    {
#line 613 "StatisticsModule.cs"
                        csharp2cuda_temp_165 = ((opcode) == (22));
                    }
                    else
                    {
#line 613 "StatisticsModule.cs"
                        csharp2cuda_temp_165 = true;
                    }
                    if (csharp2cuda_temp_165)
                    {
#line 614 "StatisticsModule.cs"
#line 614 "StatisticsModule.cs"
                        double* csharp2cuda_temp_166 = &(variance);
#line 614 "StatisticsModule.cs"
                        int csharp2cuda_temp_167 = (first)->count;
#line 614 "StatisticsModule.cs"
                        int csharp2cuda_temp_168 = (first)->count;
#line 614 "StatisticsModule.cs"
                        double csharp2cuda_temp_169 = __ddiv_rn(__dmul_rn(variance, ((double)(csharp2cuda_temp_167))), __dsub_rn(((double)(csharp2cuda_temp_168)), 1.0));
                        (*(csharp2cuda_temp_166) = csharp2cuda_temp_169);
                    }
#line 615 "StatisticsModule.cs"
#line 615 "StatisticsModule.cs"
                    double* csharp2cuda_temp_170 = &((output)->scalar_value);
#line 615 "StatisticsModule.cs"
                    bool csharp2cuda_temp_171;
#line 615 "StatisticsModule.cs"
                    if (!(((opcode) == (15))))
                    {
#line 615 "StatisticsModule.cs"
                        csharp2cuda_temp_171 = ((opcode) == (21));
                    }
                    else
                    {
#line 615 "StatisticsModule.cs"
                        csharp2cuda_temp_171 = true;
                    }
#line 615 "StatisticsModule.cs"
                    double csharp2cuda_temp_172;
#line 615 "StatisticsModule.cs"
                    if (csharp2cuda_temp_171)
                    {
#line 615 "StatisticsModule.cs"
                        csharp2cuda_temp_172 = mathblocks_square_root(variance);
                    }
                    else
                    {
#line 615 "StatisticsModule.cs"
                        csharp2cuda_temp_172 = variance;
                    }
                    (*(csharp2cuda_temp_170) = csharp2cuda_temp_172);
#line 618 "StatisticsModule.cs"
                    break;
                }
#line 620 "StatisticsModule.cs"
            case 17:
#line 621 "StatisticsModule.cs"
                {
#line 622 "StatisticsModule.cs"
#line 622 "StatisticsModule.cs"
                    int csharp2cuda_temp_173 = (first)->count;
#line 622 "StatisticsModule.cs"
                    bool csharp2cuda_temp_174;
#line 622 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_173) <= (0))))
                    {
#line 622 "StatisticsModule.cs"
                        csharp2cuda_temp_174 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 622 "StatisticsModule.cs"
                        csharp2cuda_temp_174 = true;
                    }
                    if (csharp2cuda_temp_174)
#line 623 "StatisticsModule.cs"
                    {
#line 624 "StatisticsModule.cs"
#line 624 "StatisticsModule.cs"
                        int* csharp2cuda_temp_175 = &((output)->valid);
                        (*(csharp2cuda_temp_175) = 0);
#line 625 "StatisticsModule.cs"
                        break;
                    }
#line 627 "StatisticsModule.cs"
                    int csharp2cuda_temp_176 = (first)->count;
#line 627 "StatisticsModule.cs"
                    int count = mathblocks_statistics_pair_averages(a, csharp2cuda_temp_176, scratch);
#line 628 "StatisticsModule.cs"
#line 628 "StatisticsModule.cs"
                    double* csharp2cuda_temp_177 = &((output)->scalar_value);
#line 628 "StatisticsModule.cs"
                    double csharp2cuda_temp_178 = mathblocks_statistics_median(scratch, count);
                    (*(csharp2cuda_temp_177) = csharp2cuda_temp_178);
#line 629 "StatisticsModule.cs"
                    break;
                }
#line 631 "StatisticsModule.cs"
            case 19:
#line 632 "StatisticsModule.cs"
#line 632 "StatisticsModule.cs"
                double* csharp2cuda_temp_179 = &((output)->scalar_value);
#line 633 "StatisticsModule.cs"
                int csharp2cuda_temp_180 = (first)->count;
#line 633 "StatisticsModule.cs"
                int csharp2cuda_temp_181 = (first)->count;
#line 633 "StatisticsModule.cs"
                double csharp2cuda_temp_182 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_180), ((double)(csharp2cuda_temp_181)));
                (*(csharp2cuda_temp_179) = mathblocks_square_root(csharp2cuda_temp_182));
#line 634 "StatisticsModule.cs"
                break;
#line 635 "StatisticsModule.cs"
            case 23:
#line 636 "StatisticsModule.cs"
                {
#line 637 "StatisticsModule.cs"
#line 637 "StatisticsModule.cs"
                    int csharp2cuda_temp_183 = (first)->count;
#line 637 "StatisticsModule.cs"
                    bool csharp2cuda_temp_184;
#line 637 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_183) <= (0))))
                    {
#line 637 "StatisticsModule.cs"
                        int csharp2cuda_temp_185 = (first)->count;
#line 637 "StatisticsModule.cs"
                        int csharp2cuda_temp_186 = (second)->count;
#line 637 "StatisticsModule.cs"
                        csharp2cuda_temp_184 = ((csharp2cuda_temp_185) != (csharp2cuda_temp_186));
                    }
                    else
                    {
#line 637 "StatisticsModule.cs"
                        csharp2cuda_temp_184 = true;
                    }
#line 637 "StatisticsModule.cs"
                    bool csharp2cuda_temp_187;
#line 637 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_184))
                    {
#line 637 "StatisticsModule.cs"
                        csharp2cuda_temp_187 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 637 "StatisticsModule.cs"
                        csharp2cuda_temp_187 = true;
                    }
                    if (csharp2cuda_temp_187)
#line 638 "StatisticsModule.cs"
                    {
#line 639 "StatisticsModule.cs"
#line 639 "StatisticsModule.cs"
                        int* csharp2cuda_temp_188 = &((output)->valid);
                        (*(csharp2cuda_temp_188) = 0);
#line 640 "StatisticsModule.cs"
                        break;
                    }
#line 642 "StatisticsModule.cs"
                    double* left_ranks = scratch;
#line 643 "StatisticsModule.cs"
                    int csharp2cuda_temp_189 = (first)->count;
#line 643 "StatisticsModule.cs"
                    double* right_ranks = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_189);
#line 644 "StatisticsModule.cs"
#line 644 "StatisticsModule.cs"
                    int csharp2cuda_temp_190 = (first)->count;
                    mathblocks_statistics_rank(a, csharp2cuda_temp_190, left_ranks);
#line 645 "StatisticsModule.cs"
#line 645 "StatisticsModule.cs"
                    int csharp2cuda_temp_191 = (first)->count;
                    mathblocks_statistics_rank(b, csharp2cuda_temp_191, right_ranks);
#line 646 "StatisticsModule.cs"
#line 646 "StatisticsModule.cs"
                    double* csharp2cuda_temp_192 = &((output)->scalar_value);
#line 649 "StatisticsModule.cs"
                    int csharp2cuda_temp_193 = (first)->count;
#line 646 "StatisticsModule.cs"
                    double csharp2cuda_temp_194 = mathblocks_statistics_pearson(left_ranks, right_ranks, csharp2cuda_temp_193);
                    (*(csharp2cuda_temp_192) = csharp2cuda_temp_194);
#line 650 "StatisticsModule.cs"
                    break;
                }
#line 652 "StatisticsModule.cs"
            case 24:
#line 653 "StatisticsModule.cs"
                {
#line 654 "StatisticsModule.cs"
#line 654 "StatisticsModule.cs"
                    int csharp2cuda_temp_195 = (first)->count;
#line 654 "StatisticsModule.cs"
                    int csharp2cuda_temp_196 = (second)->count;
#line 654 "StatisticsModule.cs"
                    bool csharp2cuda_temp_197;
#line 654 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_195) != (csharp2cuda_temp_196))))
                    {
#line 654 "StatisticsModule.cs"
                        csharp2cuda_temp_197 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 654 "StatisticsModule.cs"
                        csharp2cuda_temp_197 = true;
                    }
                    if (csharp2cuda_temp_197)
#line 655 "StatisticsModule.cs"
                    {
#line 656 "StatisticsModule.cs"
#line 656 "StatisticsModule.cs"
                        int* csharp2cuda_temp_198 = &((output)->valid);
                        (*(csharp2cuda_temp_198) = 0);
#line 657 "StatisticsModule.cs"
                        break;
                    }
#line 659 "StatisticsModule.cs"
                    int csharp2cuda_temp_199 = (first)->count;
#line 659 "StatisticsModule.cs"
                    int count = mathblocks_statistics_pair_slopes(a, b, csharp2cuda_temp_199, scratch);
#line 660 "StatisticsModule.cs"
                    if (((count) == (0)))
                    {
#line 661 "StatisticsModule.cs"
#line 661 "StatisticsModule.cs"
                        int* csharp2cuda_temp_200 = &((output)->valid);
                        (*(csharp2cuda_temp_200) = 0);
                    }
                    else
                    {
#line 663 "StatisticsModule.cs"
#line 663 "StatisticsModule.cs"
                        double* csharp2cuda_temp_201 = &((output)->scalar_value);
#line 663 "StatisticsModule.cs"
                        double csharp2cuda_temp_202 = mathblocks_statistics_median(scratch, count);
                        (*(csharp2cuda_temp_201) = csharp2cuda_temp_202);
                    }
#line 664 "StatisticsModule.cs"
                    break;
                }
#line 666 "StatisticsModule.cs"
            case 25:
            case 26:
#line 668 "StatisticsModule.cs"
#line 668 "StatisticsModule.cs"
                int csharp2cuda_temp_203 = (first)->count;
#line 668 "StatisticsModule.cs"
                int csharp2cuda_temp_204 = (second)->count;
#line 668 "StatisticsModule.cs"
                bool csharp2cuda_temp_205;
#line 668 "StatisticsModule.cs"
                if (!(((csharp2cuda_temp_203) != (csharp2cuda_temp_204))))
                {
#line 672 "StatisticsModule.cs"
                    int csharp2cuda_temp_206 = (first)->count;
#line 674 "StatisticsModule.cs"
                    double* csharp2cuda_temp_207 = &((output)->scalar_value);
#line 669 "StatisticsModule.cs"
                    bool csharp2cuda_temp_208 = mathblocks_statistics_weighted_value(a, b, csharp2cuda_temp_206, ((opcode) == (26)), csharp2cuda_temp_207);
#line 668 "StatisticsModule.cs"
                    csharp2cuda_temp_205 = (!(csharp2cuda_temp_208));
                }
                else
                {
#line 668 "StatisticsModule.cs"
                    csharp2cuda_temp_205 = true;
                }
                if (csharp2cuda_temp_205)
                {
#line 675 "StatisticsModule.cs"
#line 675 "StatisticsModule.cs"
                    int* csharp2cuda_temp_209 = &((output)->valid);
                    (*(csharp2cuda_temp_209) = 0);
                }
#line 676 "StatisticsModule.cs"
                break;
        }
#line 678 "StatisticsModule.cs"
#line 678 "StatisticsModule.cs"
        bool csharp2cuda_temp_210 = (output)->valid;
#line 678 "StatisticsModule.cs"
        bool csharp2cuda_temp_211;
#line 678 "StatisticsModule.cs"
        if (csharp2cuda_temp_210)
        {
#line 678 "StatisticsModule.cs"
            csharp2cuda_temp_211 = ((opcode) != (2));
        }
        else
        {
#line 678 "StatisticsModule.cs"
            csharp2cuda_temp_211 = false;
        }
#line 678 "StatisticsModule.cs"
        bool csharp2cuda_temp_212;
#line 678 "StatisticsModule.cs"
        if (csharp2cuda_temp_211)
        {
#line 678 "StatisticsModule.cs"
            csharp2cuda_temp_212 = ((opcode) != (4));
        }
        else
        {
#line 678 "StatisticsModule.cs"
            csharp2cuda_temp_212 = false;
        }
#line 678 "StatisticsModule.cs"
        bool csharp2cuda_temp_213;
#line 678 "StatisticsModule.cs"
        if (csharp2cuda_temp_212)
        {
#line 678 "StatisticsModule.cs"
            double csharp2cuda_temp_214 = (output)->scalar_value;
#line 678 "StatisticsModule.cs"
            csharp2cuda_temp_213 = (!(isfinite(csharp2cuda_temp_214)));
        }
        else
        {
#line 678 "StatisticsModule.cs"
            csharp2cuda_temp_213 = false;
        }
        if (csharp2cuda_temp_213)
        {
#line 679 "StatisticsModule.cs"
#line 679 "StatisticsModule.cs"
            int* csharp2cuda_temp_215 = &((output)->valid);
            (*(csharp2cuda_temp_215) = 0);
        }
    }
}

#line 106 "StatisticsModule.cs"
__device__ double mathblocks_statistics_distance_correlation_value(
    double covariance_square,
    double left_variance_square,
    double right_variance_square)
#line 111 "StatisticsModule.cs"
{
#line 112 "StatisticsModule.cs"
    double denominator = mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square));
#line 113 "StatisticsModule.cs"
#line 113 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 113 "StatisticsModule.cs"
    if (!((!(isfinite(covariance_square)))))
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(isfinite(left_variance_square)));
    }
    else
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 113 "StatisticsModule.cs"
    bool csharp2cuda_temp_1;
#line 113 "StatisticsModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_1 = (!(isfinite(right_variance_square)));
    }
    else
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_1 = true;
    }
#line 113 "StatisticsModule.cs"
    bool csharp2cuda_temp_2;
#line 113 "StatisticsModule.cs"
    if (!(csharp2cuda_temp_1))
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_2 = (!(isfinite(denominator)));
    }
    else
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_2 = true;
    }
    if (csharp2cuda_temp_2)
    {
#line 115 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 116 "StatisticsModule.cs"
#line 116 "StatisticsModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(covariance_square, denominator);
    return mathblocks_square_root(csharp2cuda_temp_3);
}

#line 238 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_kendall_value(
    const double* left_values,
    const double* right_values,
    int count,
    double* value)
#line 244 "StatisticsModule.cs"
{
#line 245 "StatisticsModule.cs"
    long long concordant = ((long long)(0));
#line 246 "StatisticsModule.cs"
    long long discordant = ((long long)(0));
#line 247 "StatisticsModule.cs"
    long long left_ties = ((long long)(0));
#line 248 "StatisticsModule.cs"
    long long right_ties = ((long long)(0));
#line 249 "StatisticsModule.cs"
    {
#line 249 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 250 "StatisticsModule.cs"
            {
#line 251 "StatisticsModule.cs"
                {
#line 251 "StatisticsModule.cs"
                    int right = csharp2cuda_i32_add(left, 1);
                    while (true)
                    {
                        if (!(((right) < (count))))
                            break;
#line 252 "StatisticsModule.cs"
                        {
#line 253 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[left];
#line 253 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[right];
#line 253 "StatisticsModule.cs"
                            double left_difference = __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 254 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (right_values)[left];
#line 254 "StatisticsModule.cs"
                            double csharp2cuda_temp_5 = (right_values)[right];
#line 254 "StatisticsModule.cs"
                            double right_difference = __dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 255 "StatisticsModule.cs"
                            int csharp2cuda_temp_6;
#line 255 "StatisticsModule.cs"
                            if (((left_difference) > (0.0)))
                            {
#line 255 "StatisticsModule.cs"
                                csharp2cuda_temp_6 = 1;
                            }
                            else
                            {
#line 255 "StatisticsModule.cs"
                                int csharp2cuda_temp_7;
#line 255 "StatisticsModule.cs"
                                if (((left_difference) < (0.0)))
                                {
#line 255 "StatisticsModule.cs"
                                    csharp2cuda_temp_7 = csharp2cuda_i32_neg(1);
                                }
                                else
                                {
#line 255 "StatisticsModule.cs"
                                    csharp2cuda_temp_7 = 0;
                                }
#line 255 "StatisticsModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_temp_7;
                            }
#line 255 "StatisticsModule.cs"
                            int left_sign = csharp2cuda_temp_6;
#line 256 "StatisticsModule.cs"
                            int csharp2cuda_temp_8;
#line 256 "StatisticsModule.cs"
                            if (((right_difference) > (0.0)))
                            {
#line 256 "StatisticsModule.cs"
                                csharp2cuda_temp_8 = 1;
                            }
                            else
                            {
#line 256 "StatisticsModule.cs"
                                int csharp2cuda_temp_9;
#line 256 "StatisticsModule.cs"
                                if (((right_difference) < (0.0)))
                                {
#line 256 "StatisticsModule.cs"
                                    csharp2cuda_temp_9 = csharp2cuda_i32_neg(1);
                                }
                                else
                                {
#line 256 "StatisticsModule.cs"
                                    csharp2cuda_temp_9 = 0;
                                }
#line 256 "StatisticsModule.cs"
                                csharp2cuda_temp_8 = csharp2cuda_temp_9;
                            }
#line 256 "StatisticsModule.cs"
                            int right_sign = csharp2cuda_temp_8;
#line 257 "StatisticsModule.cs"
#line 257 "StatisticsModule.cs"
                            bool csharp2cuda_temp_10;
#line 257 "StatisticsModule.cs"
                            if (((left_sign) == (0)))
                            {
#line 257 "StatisticsModule.cs"
                                csharp2cuda_temp_10 = ((right_sign) == (0));
                            }
                            else
                            {
#line 257 "StatisticsModule.cs"
                                csharp2cuda_temp_10 = false;
                            }
                            if (csharp2cuda_temp_10)
                            {
#line 258 "StatisticsModule.cs"
                                goto csharp2cuda_for_continue_0;
                            }
#line 259 "StatisticsModule.cs"
                            if (((left_sign) == (0)))
                            {
#line 260 "StatisticsModule.cs"
#line 260 "StatisticsModule.cs"
                                long long* csharp2cuda_temp_11 = &(left_ties);
                                csharp2cuda_i64_post_increment(*(csharp2cuda_temp_11));
                            }
                            else
                            {
#line 261 "StatisticsModule.cs"
                                if (((right_sign) == (0)))
                                {
#line 262 "StatisticsModule.cs"
#line 262 "StatisticsModule.cs"
                                    long long* csharp2cuda_temp_12 = &(right_ties);
                                    csharp2cuda_i64_post_increment(*(csharp2cuda_temp_12));
                                }
                                else
                                {
#line 263 "StatisticsModule.cs"
                                    if (((left_sign) == (right_sign)))
                                    {
#line 264 "StatisticsModule.cs"
#line 264 "StatisticsModule.cs"
                                        long long* csharp2cuda_temp_13 = &(concordant);
                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_13));
                                    }
                                    else
                                    {
#line 266 "StatisticsModule.cs"
#line 266 "StatisticsModule.cs"
                                        long long* csharp2cuda_temp_14 = &(discordant);
                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_14));
                                    }
                                }
                            }
                        }
                        csharp2cuda_for_continue_0:
#line 251 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(right);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 249 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 269 "StatisticsModule.cs"
#line 269 "StatisticsModule.cs"
    double* csharp2cuda_temp_15 = value;
#line 269 "StatisticsModule.cs"
    double csharp2cuda_temp_16 = __ddiv_rn(((double)(csharp2cuda_i64_sub(concordant, discordant))), mathblocks_square_root(__dmul_rn(((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), left_ties))), ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), right_ties))))));
    (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 273 "StatisticsModule.cs"
#line 273 "StatisticsModule.cs"
    double csharp2cuda_temp_17 = *(value);
    return isfinite(csharp2cuda_temp_17);
}

#line 49 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count)
#line 51 "StatisticsModule.cs"
{
#line 52 "StatisticsModule.cs"
    return __ddiv_rn(mathblocks_compensated_sum(values, count), ((double)(count)));
}

#line 163 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count)
#line 165 "StatisticsModule.cs"
{
#line 166 "StatisticsModule.cs"
    double* sorted = mathblocks_stable_merge_sort(values, csharp2cuda_pointer_add(values, count), count, false);
#line 167 "StatisticsModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 218 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_moment_value(
    const double* values,
    int count,
    double order_value,
    bool central,
    double* value)
#line 225 "StatisticsModule.cs"
{
#line 226 "StatisticsModule.cs"
    int order = 0;
#line 227 "StatisticsModule.cs"
#line 227 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 227 "StatisticsModule.cs"
    if (!(((count) <= (0))))
    {
#line 228 "StatisticsModule.cs"
        int* csharp2cuda_temp_1 = &(order);
#line 228 "StatisticsModule.cs"
        bool csharp2cuda_temp_2 = mathblocks_nonnegative_integer(order_value, csharp2cuda_temp_1);
#line 227 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(csharp2cuda_temp_2));
    }
    else
    {
#line 227 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 229 "StatisticsModule.cs"
        return false;
    }
#line 230 "StatisticsModule.cs"
    double csharp2cuda_temp_3;
#line 230 "StatisticsModule.cs"
    if (central)
    {
#line 230 "StatisticsModule.cs"
        csharp2cuda_temp_3 = mathblocks_statistics_mean(values, count);
    }
    else
    {
#line 230 "StatisticsModule.cs"
        csharp2cuda_temp_3 = 0.0;
    }
#line 230 "StatisticsModule.cs"
    double mean = csharp2cuda_temp_3;
#line 231 "StatisticsModule.cs"
    double sum = 0.0;
#line 232 "StatisticsModule.cs"
    {
#line 232 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 233 "StatisticsModule.cs"
#line 233 "StatisticsModule.cs"
            double* csharp2cuda_temp_5 = &(sum);
#line 233 "StatisticsModule.cs"
            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
#line 233 "StatisticsModule.cs"
            double csharp2cuda_temp_7 = (values)[index];
            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, mathblocks_power(__dsub_rn(csharp2cuda_temp_7, mean), ((double)(order)))));
#line 232 "StatisticsModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 234 "StatisticsModule.cs"
#line 234 "StatisticsModule.cs"
    double* csharp2cuda_temp_8 = value;
#line 234 "StatisticsModule.cs"
    double csharp2cuda_temp_9 = __ddiv_rn(sum, ((double)(count)));
    (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 235 "StatisticsModule.cs"
#line 235 "StatisticsModule.cs"
    double csharp2cuda_temp_10 = *(value);
    return isfinite(csharp2cuda_temp_10);
}

#line 334 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_averages(
    const double* values,
    int count,
    double* averages)
#line 339 "StatisticsModule.cs"
{
#line 340 "StatisticsModule.cs"
    int average_count = 0;
#line 341 "StatisticsModule.cs"
    {
#line 341 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 342 "StatisticsModule.cs"
            {
#line 342 "StatisticsModule.cs"
                int right = left;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 343 "StatisticsModule.cs"
#line 343 "StatisticsModule.cs"
                    int* csharp2cuda_temp_2 = &(average_count);
#line 343 "StatisticsModule.cs"
                    int csharp2cuda_temp_3 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
#line 343 "StatisticsModule.cs"
                    double* csharp2cuda_temp_4 = &((averages)[csharp2cuda_temp_3]);
#line 343 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (values)[left];
#line 343 "StatisticsModule.cs"
                    double csharp2cuda_temp_6 = (values)[right];
#line 343 "StatisticsModule.cs"
                    double csharp2cuda_temp_7 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_6), 2.0);
                    (*(csharp2cuda_temp_4) = csharp2cuda_temp_7);
#line 342 "StatisticsModule.cs"
                    int* csharp2cuda_temp_1 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 341 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 344 "StatisticsModule.cs"
    return average_count;
}

#line 349 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_slopes(
    const double* x,
    const double* y,
    int count,
    double* slopes)
#line 355 "StatisticsModule.cs"
{
#line 356 "StatisticsModule.cs"
    int slope_count = 0;
#line 357 "StatisticsModule.cs"
    {
#line 357 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 358 "StatisticsModule.cs"
            {
#line 359 "StatisticsModule.cs"
                {
#line 359 "StatisticsModule.cs"
                    int right = csharp2cuda_i32_add(left, 1);
                    while (true)
                    {
                        if (!(((right) < (count))))
                            break;
#line 360 "StatisticsModule.cs"
                        {
#line 361 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (x)[right];
#line 361 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (x)[left];
#line 361 "StatisticsModule.cs"
                            double difference = __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 362 "StatisticsModule.cs"
                            if (((difference) != (0.0)))
                            {
#line 363 "StatisticsModule.cs"
#line 363 "StatisticsModule.cs"
                                int* csharp2cuda_temp_4 = &(slope_count);
#line 363 "StatisticsModule.cs"
                                int csharp2cuda_temp_5 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
#line 363 "StatisticsModule.cs"
                                double* csharp2cuda_temp_6 = &((slopes)[csharp2cuda_temp_5]);
#line 363 "StatisticsModule.cs"
                                double csharp2cuda_temp_7 = (y)[right];
#line 363 "StatisticsModule.cs"
                                double csharp2cuda_temp_8 = (y)[left];
#line 363 "StatisticsModule.cs"
                                double csharp2cuda_temp_9 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_7, csharp2cuda_temp_8), difference);
                                (*(csharp2cuda_temp_6) = csharp2cuda_temp_9);
                            }
                        }
#line 359 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(right);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 357 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 366 "StatisticsModule.cs"
    return slope_count;
}

#line 119 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count)
#line 124 "StatisticsModule.cs"
{
#line 125 "StatisticsModule.cs"
#line 126 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = mathblocks_statistics_population_covariance(left, right, count);
#line 127 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = mathblocks_statistics_population_variance(left, count);
#line 128 "StatisticsModule.cs"
    double csharp2cuda_temp_2 = mathblocks_statistics_population_variance(right, count);
    return mathblocks_statistics_correlation_value(csharp2cuda_temp_0, csharp2cuda_temp_1, csharp2cuda_temp_2);
}

#line 70 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count)
#line 75 "StatisticsModule.cs"
{
#line 76 "StatisticsModule.cs"
    double left_mean = mathblocks_statistics_mean(left, count);
#line 77 "StatisticsModule.cs"
    double right_mean = mathblocks_statistics_mean(right, count);
#line 78 "StatisticsModule.cs"
    double sum = 0.0;
#line 79 "StatisticsModule.cs"
    {
#line 79 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 80 "StatisticsModule.cs"
#line 80 "StatisticsModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 80 "StatisticsModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 80 "StatisticsModule.cs"
            double csharp2cuda_temp_3 = (left)[index];
#line 80 "StatisticsModule.cs"
            double csharp2cuda_temp_4 = (right)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, __dmul_rn(__dsub_rn(csharp2cuda_temp_3, left_mean), __dsub_rn(csharp2cuda_temp_4, right_mean))));
#line 79 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 81 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 55 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count)
#line 59 "StatisticsModule.cs"
{
#line 60 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 61 "StatisticsModule.cs"
    double sum = 0.0;
#line 62 "StatisticsModule.cs"
    {
#line 62 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 63 "StatisticsModule.cs"
            {
#line 64 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 64 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 65 "StatisticsModule.cs"
#line 65 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(sum);
#line 65 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, __dmul_rn(difference, difference)));
            }
#line 62 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 67 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 85 "StatisticsModule.cs"
__device__ double mathblocks_statistics_quotient_by_variance(double covariance, double variance)
#line 87 "StatisticsModule.cs"
{
#line 88 "StatisticsModule.cs"
    if ((!(isfinite(variance))))
    {
#line 89 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 90 "StatisticsModule.cs"
    return __ddiv_rn(covariance, variance);
}

#line 170 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result)
#line 175 "StatisticsModule.cs"
{
#line 176 "StatisticsModule.cs"
    {
#line 176 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 177 "StatisticsModule.cs"
            {
#line 178 "StatisticsModule.cs"
                int lower = 0;
#line 179 "StatisticsModule.cs"
                int equal = 0;
#line 180 "StatisticsModule.cs"
                {
#line 180 "StatisticsModule.cs"
                    int candidate = 0;
                    while (true)
                    {
                        if (!(((candidate) < (count))))
                            break;
#line 181 "StatisticsModule.cs"
                        {
#line 182 "StatisticsModule.cs"
#line 182 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (values)[candidate];
#line 182 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[index];
                            if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
                            {
#line 183 "StatisticsModule.cs"
#line 183 "StatisticsModule.cs"
                                int* csharp2cuda_temp_4 = &(lower);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                            }
                            else
                            {
#line 184 "StatisticsModule.cs"
#line 184 "StatisticsModule.cs"
                                double csharp2cuda_temp_5 = (values)[candidate];
#line 184 "StatisticsModule.cs"
                                double csharp2cuda_temp_6 = (values)[index];
                                if (((csharp2cuda_temp_5) == (csharp2cuda_temp_6)))
                                {
#line 185 "StatisticsModule.cs"
#line 185 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_7 = &(equal);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                                }
                            }
                        }
#line 180 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(candidate);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 187 "StatisticsModule.cs"
#line 187 "StatisticsModule.cs"
                double* csharp2cuda_temp_8 = &((result)[index]);
#line 187 "StatisticsModule.cs"
                double csharp2cuda_temp_9 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
                (*(csharp2cuda_temp_8) = __dadd_rn(((double)(lower)), csharp2cuda_temp_9));
            }
#line 176 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 276 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_shape_moment_value(
    const double* values,
    int count,
    bool kurtosis,
    double* value)
#line 282 "StatisticsModule.cs"
{
#line 283 "StatisticsModule.cs"
    if (((count) <= (0)))
    {
#line 284 "StatisticsModule.cs"
        return false;
    }
#line 285 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 286 "StatisticsModule.cs"
    double second_moment = 0.0;
#line 287 "StatisticsModule.cs"
    double higher_moment = 0.0;
#line 288 "StatisticsModule.cs"
    {
#line 288 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 289 "StatisticsModule.cs"
            {
#line 290 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 290 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 291 "StatisticsModule.cs"
                double square = __dmul_rn(difference, difference);
#line 292 "StatisticsModule.cs"
#line 292 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(second_moment);
#line 292 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, square));
#line 293 "StatisticsModule.cs"
#line 293 "StatisticsModule.cs"
                double* csharp2cuda_temp_4 = &(higher_moment);
#line 293 "StatisticsModule.cs"
                double csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
#line 293 "StatisticsModule.cs"
                double csharp2cuda_temp_6;
#line 293 "StatisticsModule.cs"
                if (kurtosis)
                {
#line 293 "StatisticsModule.cs"
                    csharp2cuda_temp_6 = __dmul_rn(square, square);
                }
                else
                {
#line 293 "StatisticsModule.cs"
                    csharp2cuda_temp_6 = __dmul_rn(square, difference);
                }
                (*(csharp2cuda_temp_4) = __dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_6));
            }
#line 288 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 295 "StatisticsModule.cs"
#line 295 "StatisticsModule.cs"
    double* csharp2cuda_temp_7 = &(second_moment);
#line 295 "StatisticsModule.cs"
    double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
    (*(csharp2cuda_temp_7) = __ddiv_rn(csharp2cuda_temp_8, ((double)(count))));
#line 296 "StatisticsModule.cs"
#line 296 "StatisticsModule.cs"
    double* csharp2cuda_temp_9 = &(higher_moment);
#line 296 "StatisticsModule.cs"
    double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
    (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
#line 297 "StatisticsModule.cs"
#line 297 "StatisticsModule.cs"
    double* csharp2cuda_temp_11 = value;
#line 297 "StatisticsModule.cs"
    double csharp2cuda_temp_12;
#line 297 "StatisticsModule.cs"
    if (kurtosis)
    {
#line 298 "StatisticsModule.cs"
        double csharp2cuda_temp_13 = __ddiv_rn(higher_moment, __dmul_rn(second_moment, second_moment));
#line 297 "StatisticsModule.cs"
        csharp2cuda_temp_12 = __dsub_rn(csharp2cuda_temp_13, 3.0);
    }
    else
    {
#line 297 "StatisticsModule.cs"
        csharp2cuda_temp_12 = __ddiv_rn(higher_moment, mathblocks_power(second_moment, 1.5));
    }
    (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 300 "StatisticsModule.cs"
#line 300 "StatisticsModule.cs"
    double csharp2cuda_temp_14 = *(value);
    return isfinite(csharp2cuda_temp_14);
}

#line 138 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result,
    bool descending)
#line 144 "StatisticsModule.cs"
{
#line 145 "StatisticsModule.cs"
    mathblocks_stable_sort_into(values, count, result, csharp2cuda_pointer_add(result, count), descending);
}

#line 148 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability)
#line 153 "StatisticsModule.cs"
{
#line 154 "StatisticsModule.cs"
    if (((count) == (1)))
    {
#line 155 "StatisticsModule.cs"
        return (sorted)[0];
    }
#line 156 "StatisticsModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 157 "StatisticsModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 158 "StatisticsModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 159 "StatisticsModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 160 "StatisticsModule.cs"
#line 160 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = (sorted)[lower];
#line 160 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_0, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_1, weight));
}

#line 303 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_weighted_value(
    const double* values,
    const double* weights,
    int count,
    bool variance,
    double* value)
#line 310 "StatisticsModule.cs"
{
#line 311 "StatisticsModule.cs"
    if (((count) <= (0)))
    {
#line 312 "StatisticsModule.cs"
        return false;
    }
#line 313 "StatisticsModule.cs"
    double weight_sum = mathblocks_compensated_sum(weights, count);
#line 314 "StatisticsModule.cs"
    double mean = __ddiv_rn(mathblocks_compensated_product_sum(values, weights, count), weight_sum);
#line 315 "StatisticsModule.cs"
    if ((!(variance)))
#line 316 "StatisticsModule.cs"
    {
#line 317 "StatisticsModule.cs"
#line 317 "StatisticsModule.cs"
        double* csharp2cuda_temp_0 = value;
        (*(csharp2cuda_temp_0) = mean);
    }
    else
#line 320 "StatisticsModule.cs"
    {
#line 321 "StatisticsModule.cs"
        double numerator = 0.0;
#line 322 "StatisticsModule.cs"
        {
#line 322 "StatisticsModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 323 "StatisticsModule.cs"
                {
#line 324 "StatisticsModule.cs"
                    double csharp2cuda_temp_2 = (values)[index];
#line 324 "StatisticsModule.cs"
                    double difference = __dsub_rn(csharp2cuda_temp_2, mean);
#line 325 "StatisticsModule.cs"
#line 325 "StatisticsModule.cs"
                    double* csharp2cuda_temp_3 = &(numerator);
#line 325 "StatisticsModule.cs"
                    double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 325 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (weights)[index];
                    (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(__dmul_rn(csharp2cuda_temp_5, difference), difference)));
                }
#line 322 "StatisticsModule.cs"
                int* csharp2cuda_temp_1 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
            }
        }
#line 327 "StatisticsModule.cs"
#line 327 "StatisticsModule.cs"
        double* csharp2cuda_temp_6 = value;
#line 327 "StatisticsModule.cs"
        double csharp2cuda_temp_7 = __ddiv_rn(numerator, weight_sum);
        (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
    }
#line 329 "StatisticsModule.cs"
#line 329 "StatisticsModule.cs"
    double csharp2cuda_temp_8 = *(value);
    return isfinite(csharp2cuda_temp_8);
}