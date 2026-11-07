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

#line 78 "TransportModule.cs"
__device__ void mathblocks_transport_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 64 "TransportModule.cs"
__device__ double mathblocks_transport_mean_pairwise(
    const double* left,
    int left_count,
    const double* right,
    int right_count);

#line 78 "TransportModule.cs"
__device__ void mathblocks_transport_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 84 "TransportModule.cs"
{
#line 85 "TransportModule.cs"
    int thread = threadIdx.x;
#line 86 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 86 "TransportModule.cs"
    if (((input_count) > (0)))
    {
#line 86 "TransportModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 86 "TransportModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 86 "TransportModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 87 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 87 "TransportModule.cs"
    if (((input_count) > (1)))
    {
#line 87 "TransportModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 87 "TransportModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 87 "TransportModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 88 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 88 "TransportModule.cs"
    if (((input_count) > (2)))
    {
#line 88 "TransportModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 88 "TransportModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 88 "TransportModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 89 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 89 "TransportModule.cs"
    if (((input_count) > (3)))
    {
#line 89 "TransportModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 89 "TransportModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 89 "TransportModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 90 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_4;
#line 90 "TransportModule.cs"
    if (((input_count) > (4)))
    {
#line 90 "TransportModule.cs"
        csharp2cuda_temp_4 = (inputs)[4];
    }
    else
    {
#line 90 "TransportModule.cs"
        csharp2cuda_temp_4 = ((MathBlockSlot*)(nullptr));
    }
#line 90 "TransportModule.cs"
    const MathBlockSlot* fifth = csharp2cuda_temp_4;
#line 91 "TransportModule.cs"
    if (((thread) == (0)))
#line 92 "TransportModule.cs"
    {
#line 93 "TransportModule.cs"
#line 93 "TransportModule.cs"
        double* csharp2cuda_temp_5 = &((output)->scalar_value);
        (*(csharp2cuda_temp_5) = 0.0);
#line 94 "TransportModule.cs"
#line 94 "TransportModule.cs"
        int* csharp2cuda_temp_6 = &((output)->boolean_value);
        (*(csharp2cuda_temp_6) = 0);
#line 95 "TransportModule.cs"
#line 95 "TransportModule.cs"
        int* csharp2cuda_temp_7 = &((output)->rows);
        (*(csharp2cuda_temp_7) = 0);
#line 96 "TransportModule.cs"
#line 96 "TransportModule.cs"
        int* csharp2cuda_temp_8 = &((output)->columns);
        (*(csharp2cuda_temp_8) = 0);
#line 97 "TransportModule.cs"
#line 97 "TransportModule.cs"
        int* csharp2cuda_temp_9 = &((output)->count);
        (*(csharp2cuda_temp_9) = 0);
#line 98 "TransportModule.cs"
#line 98 "TransportModule.cs"
        int* csharp2cuda_temp_10 = &((output)->valid);
        (*(csharp2cuda_temp_10) = 1);
#line 99 "TransportModule.cs"
        {
#line 99 "TransportModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 100 "TransportModule.cs"
#line 100 "TransportModule.cs"
                MathBlockSlot* csharp2cuda_temp_12 = (inputs)[index];
#line 100 "TransportModule.cs"
                bool csharp2cuda_temp_13;
#line 100 "TransportModule.cs"
                if (!(((((void*)(csharp2cuda_temp_12))) == (((void*)(nullptr))))))
                {
#line 100 "TransportModule.cs"
                    MathBlockSlot* csharp2cuda_temp_14 = (inputs)[index];
#line 100 "TransportModule.cs"
                    bool csharp2cuda_temp_15 = (csharp2cuda_temp_14)->valid;
#line 100 "TransportModule.cs"
                    csharp2cuda_temp_13 = (!(csharp2cuda_temp_15));
                }
                else
                {
#line 100 "TransportModule.cs"
                    csharp2cuda_temp_13 = true;
                }
                if (csharp2cuda_temp_13)
                {
#line 100 "TransportModule.cs"
#line 100 "TransportModule.cs"
                    int* csharp2cuda_temp_16 = &((output)->valid);
                    (*(csharp2cuda_temp_16) = 0);
                }
#line 99 "TransportModule.cs"
                int* csharp2cuda_temp_11 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
            }
        }
    }
#line 102 "TransportModule.cs"
    __syncthreads();
#line 103 "TransportModule.cs"
#line 103 "TransportModule.cs"
    bool csharp2cuda_temp_17 = (output)->valid;
    if ((!(csharp2cuda_temp_17)))
    {
#line 104 "TransportModule.cs"
        return;
    }
#line 106 "TransportModule.cs"
    double* csharp2cuda_temp_18;
#line 106 "TransportModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 106 "TransportModule.cs"
        csharp2cuda_temp_18 = ((double*)(nullptr));
    }
    else
    {
#line 106 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_19 = (first)->data_pointer;
#line 106 "TransportModule.cs"
        csharp2cuda_temp_18 = ((double*)(csharp2cuda_temp_19));
    }
#line 106 "TransportModule.cs"
    const double* a = csharp2cuda_temp_18;
#line 107 "TransportModule.cs"
    double* csharp2cuda_temp_20;
#line 107 "TransportModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 107 "TransportModule.cs"
        csharp2cuda_temp_20 = ((double*)(nullptr));
    }
    else
    {
#line 107 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_21 = (second)->data_pointer;
#line 107 "TransportModule.cs"
        csharp2cuda_temp_20 = ((double*)(csharp2cuda_temp_21));
    }
#line 107 "TransportModule.cs"
    const double* b = csharp2cuda_temp_20;
#line 108 "TransportModule.cs"
    double* csharp2cuda_temp_22;
#line 108 "TransportModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 108 "TransportModule.cs"
        csharp2cuda_temp_22 = ((double*)(nullptr));
    }
    else
    {
#line 108 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_23 = (third)->data_pointer;
#line 108 "TransportModule.cs"
        csharp2cuda_temp_22 = ((double*)(csharp2cuda_temp_23));
    }
#line 108 "TransportModule.cs"
    const double* c = csharp2cuda_temp_22;
#line 109 "TransportModule.cs"
    double* csharp2cuda_temp_24;
#line 109 "TransportModule.cs"
    if (((((void*)(fourth))) == (((void*)(nullptr)))))
    {
#line 109 "TransportModule.cs"
        csharp2cuda_temp_24 = ((double*)(nullptr));
    }
    else
    {
#line 109 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_25 = (fourth)->data_pointer;
#line 109 "TransportModule.cs"
        csharp2cuda_temp_24 = ((double*)(csharp2cuda_temp_25));
    }
#line 109 "TransportModule.cs"
    const double* d = csharp2cuda_temp_24;
#line 110 "TransportModule.cs"
    unsigned long long csharp2cuda_temp_26 = (output)->data_pointer;
#line 110 "TransportModule.cs"
    double* result = ((double*)(csharp2cuda_temp_26));
#line 111 "TransportModule.cs"
    unsigned long long csharp2cuda_temp_27 = (output)->scratch_pointer;
#line 111 "TransportModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_27));
#line 116 "TransportModule.cs"
    double energy_cross = 0.0;
#line 117 "TransportModule.cs"
    double energy_left_within = 0.0;
#line 118 "TransportModule.cs"
    double energy_right_within = 0.0;
#line 119 "TransportModule.cs"
#line 119 "TransportModule.cs"
    bool csharp2cuda_temp_28;
#line 119 "TransportModule.cs"
    if (((opcode) == (2)))
    {
#line 119 "TransportModule.cs"
        int csharp2cuda_temp_29 = (first)->count;
#line 119 "TransportModule.cs"
        csharp2cuda_temp_28 = ((csharp2cuda_temp_29) > (0));
    }
    else
    {
#line 119 "TransportModule.cs"
        csharp2cuda_temp_28 = false;
    }
#line 119 "TransportModule.cs"
    bool csharp2cuda_temp_30;
#line 119 "TransportModule.cs"
    if (csharp2cuda_temp_28)
    {
#line 119 "TransportModule.cs"
        int csharp2cuda_temp_31 = (second)->count;
#line 119 "TransportModule.cs"
        csharp2cuda_temp_30 = ((csharp2cuda_temp_31) > (0));
    }
    else
    {
#line 119 "TransportModule.cs"
        csharp2cuda_temp_30 = false;
    }
    if (csharp2cuda_temp_30)
#line 120 "TransportModule.cs"
    {
#line 121 "TransportModule.cs"
        int left_owner = csharp2cuda_i32_rem(1, blockDim.x);
#line 122 "TransportModule.cs"
        int right_owner = csharp2cuda_i32_rem(2, blockDim.x);
#line 123 "TransportModule.cs"
        if (((thread) == (0)))
        {
#line 124 "TransportModule.cs"
#line 124 "TransportModule.cs"
            double* csharp2cuda_temp_32 = &(energy_cross);
#line 124 "TransportModule.cs"
            int csharp2cuda_temp_33 = (first)->count;
#line 124 "TransportModule.cs"
            int csharp2cuda_temp_34 = (second)->count;
#line 124 "TransportModule.cs"
            double csharp2cuda_temp_35 = mathblocks_transport_mean_pairwise(a, csharp2cuda_temp_33, b, csharp2cuda_temp_34);
            (*(csharp2cuda_temp_32) = csharp2cuda_temp_35);
        }
#line 125 "TransportModule.cs"
        if (((thread) == (left_owner)))
        {
#line 126 "TransportModule.cs"
#line 126 "TransportModule.cs"
            double* csharp2cuda_temp_36 = &(energy_left_within);
#line 126 "TransportModule.cs"
            int csharp2cuda_temp_37 = (first)->count;
#line 126 "TransportModule.cs"
            int csharp2cuda_temp_38 = (first)->count;
#line 126 "TransportModule.cs"
            double csharp2cuda_temp_39 = mathblocks_transport_mean_pairwise(a, csharp2cuda_temp_37, a, csharp2cuda_temp_38);
            (*(csharp2cuda_temp_36) = csharp2cuda_temp_39);
        }
#line 127 "TransportModule.cs"
        if (((thread) == (right_owner)))
        {
#line 128 "TransportModule.cs"
#line 128 "TransportModule.cs"
            double* csharp2cuda_temp_40 = &(energy_right_within);
#line 128 "TransportModule.cs"
            int csharp2cuda_temp_41 = (second)->count;
#line 128 "TransportModule.cs"
            int csharp2cuda_temp_42 = (second)->count;
#line 128 "TransportModule.cs"
            double csharp2cuda_temp_43 = mathblocks_transport_mean_pairwise(b, csharp2cuda_temp_41, b, csharp2cuda_temp_42);
            (*(csharp2cuda_temp_40) = csharp2cuda_temp_43);
        }
#line 129 "TransportModule.cs"
        if (((left_owner) != (0)))
#line 130 "TransportModule.cs"
        {
#line 131 "TransportModule.cs"
            if (((thread) == (left_owner)))
            {
#line 132 "TransportModule.cs"
#line 132 "TransportModule.cs"
                double* csharp2cuda_temp_44 = &((output)->scalar_value);
                (*(csharp2cuda_temp_44) = energy_left_within);
            }
#line 133 "TransportModule.cs"
            __syncthreads();
#line 134 "TransportModule.cs"
            if (((thread) == (0)))
            {
#line 135 "TransportModule.cs"
#line 135 "TransportModule.cs"
                double* csharp2cuda_temp_45 = &(energy_left_within);
#line 135 "TransportModule.cs"
                double csharp2cuda_temp_46 = (output)->scalar_value;
                (*(csharp2cuda_temp_45) = csharp2cuda_temp_46);
            }
#line 136 "TransportModule.cs"
            __syncthreads();
        }
#line 138 "TransportModule.cs"
        if (((right_owner) != (0)))
#line 139 "TransportModule.cs"
        {
#line 140 "TransportModule.cs"
            if (((thread) == (right_owner)))
            {
#line 141 "TransportModule.cs"
#line 141 "TransportModule.cs"
                double* csharp2cuda_temp_47 = &((output)->scalar_value);
                (*(csharp2cuda_temp_47) = energy_right_within);
            }
#line 142 "TransportModule.cs"
            __syncthreads();
#line 143 "TransportModule.cs"
            if (((thread) == (0)))
            {
#line 144 "TransportModule.cs"
#line 144 "TransportModule.cs"
                double* csharp2cuda_temp_48 = &(energy_right_within);
#line 144 "TransportModule.cs"
                double csharp2cuda_temp_49 = (output)->scalar_value;
                (*(csharp2cuda_temp_48) = csharp2cuda_temp_49);
            }
#line 145 "TransportModule.cs"
            __syncthreads();
        }
    }
#line 149 "TransportModule.cs"
    if (((thread) == (0)))
#line 150 "TransportModule.cs"
    {
#line 151 "TransportModule.cs"
        switch (opcode)
        {
#line 153 "TransportModule.cs"
            case 0:
#line 154 "TransportModule.cs"
#line 154 "TransportModule.cs"
                int csharp2cuda_temp_50 = (first)->rows;
#line 154 "TransportModule.cs"
                int csharp2cuda_temp_51 = (first)->columns;
#line 154 "TransportModule.cs"
                bool csharp2cuda_temp_52;
#line 154 "TransportModule.cs"
                if (!(((csharp2cuda_temp_50) != (csharp2cuda_temp_51))))
                {
#line 154 "TransportModule.cs"
                    int csharp2cuda_temp_53 = (second)->count;
#line 154 "TransportModule.cs"
                    int csharp2cuda_temp_54 = (first)->rows;
#line 154 "TransportModule.cs"
                    csharp2cuda_temp_52 = ((csharp2cuda_temp_53) != (csharp2cuda_temp_54));
                }
                else
                {
#line 154 "TransportModule.cs"
                    csharp2cuda_temp_52 = true;
                }
                if (csharp2cuda_temp_52)
#line 155 "TransportModule.cs"
                {
#line 156 "TransportModule.cs"
#line 156 "TransportModule.cs"
                    int* csharp2cuda_temp_55 = &((output)->valid);
                    (*(csharp2cuda_temp_55) = 0);
#line 157 "TransportModule.cs"
                    break;
                }
#line 159 "TransportModule.cs"
                {
#line 160 "TransportModule.cs"
                    double total = 0.0;
#line 161 "TransportModule.cs"
                    {
#line 161 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 161 "TransportModule.cs"
                            int csharp2cuda_temp_57 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_57))))
                                break;
#line 162 "TransportModule.cs"
                            {
#line 163 "TransportModule.cs"
                                int column = 0;
#line 164 "TransportModule.cs"
#line 164 "TransportModule.cs"
                                double csharp2cuda_temp_58 = (b)[row];
#line 164 "TransportModule.cs"
                                int* csharp2cuda_temp_59 = &(column);
#line 164 "TransportModule.cs"
                                bool csharp2cuda_temp_60 = mathblocks_nonnegative_integer(csharp2cuda_temp_58, csharp2cuda_temp_59);
#line 164 "TransportModule.cs"
                                bool csharp2cuda_temp_61;
#line 164 "TransportModule.cs"
                                if (!((!(csharp2cuda_temp_60))))
                                {
#line 164 "TransportModule.cs"
                                    int csharp2cuda_temp_62 = (first)->columns;
#line 164 "TransportModule.cs"
                                    csharp2cuda_temp_61 = ((column) >= (csharp2cuda_temp_62));
                                }
                                else
                                {
#line 164 "TransportModule.cs"
                                    csharp2cuda_temp_61 = true;
                                }
                                if (csharp2cuda_temp_61)
#line 165 "TransportModule.cs"
                                {
#line 166 "TransportModule.cs"
#line 166 "TransportModule.cs"
                                    int* csharp2cuda_temp_63 = &((output)->valid);
                                    (*(csharp2cuda_temp_63) = 0);
#line 167 "TransportModule.cs"
                                    break;
                                }
#line 169 "TransportModule.cs"
#line 169 "TransportModule.cs"
                                double* csharp2cuda_temp_64 = &(total);
#line 169 "TransportModule.cs"
                                double csharp2cuda_temp_65 = *(csharp2cuda_temp_64);
#line 169 "TransportModule.cs"
                                int csharp2cuda_temp_66 = (first)->columns;
#line 169 "TransportModule.cs"
                                double csharp2cuda_temp_67 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_66), column)];
                                (*(csharp2cuda_temp_64) = __dadd_rn(csharp2cuda_temp_65, csharp2cuda_temp_67));
                            }
#line 161 "TransportModule.cs"
                            int* csharp2cuda_temp_56 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_56));
                        }
                    }
#line 171 "TransportModule.cs"
#line 171 "TransportModule.cs"
                    double* csharp2cuda_temp_68 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_68) = total);
#line 172 "TransportModule.cs"
                    break;
                }
#line 174 "TransportModule.cs"
            case 1:
#line 175 "TransportModule.cs"
#line 175 "TransportModule.cs"
                int csharp2cuda_temp_69 = (first)->rows;
#line 175 "TransportModule.cs"
                int csharp2cuda_temp_70 = (second)->rows;
#line 175 "TransportModule.cs"
                bool csharp2cuda_temp_71;
#line 175 "TransportModule.cs"
                if (!(((csharp2cuda_temp_69) != (csharp2cuda_temp_70))))
                {
#line 175 "TransportModule.cs"
                    int csharp2cuda_temp_72 = (first)->columns;
#line 175 "TransportModule.cs"
                    int csharp2cuda_temp_73 = (second)->columns;
#line 175 "TransportModule.cs"
                    csharp2cuda_temp_71 = ((csharp2cuda_temp_72) != (csharp2cuda_temp_73));
                }
                else
                {
#line 175 "TransportModule.cs"
                    csharp2cuda_temp_71 = true;
                }
                if (csharp2cuda_temp_71)
#line 176 "TransportModule.cs"
                {
#line 177 "TransportModule.cs"
#line 177 "TransportModule.cs"
                    int* csharp2cuda_temp_74 = &((output)->valid);
                    (*(csharp2cuda_temp_74) = 0);
#line 178 "TransportModule.cs"
                    break;
                }
#line 180 "TransportModule.cs"
                {
#line 181 "TransportModule.cs"
                    double total = 0.0;
#line 182 "TransportModule.cs"
                    {
#line 182 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 182 "TransportModule.cs"
                            int csharp2cuda_temp_76 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_76))))
                                break;
#line 183 "TransportModule.cs"
                            {
#line 183 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 183 "TransportModule.cs"
                                    int csharp2cuda_temp_78 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_78))))
                                        break;
#line 184 "TransportModule.cs"
#line 184 "TransportModule.cs"
                                    double* csharp2cuda_temp_79 = &(total);
#line 184 "TransportModule.cs"
                                    double csharp2cuda_temp_80 = *(csharp2cuda_temp_79);
#line 184 "TransportModule.cs"
                                    int csharp2cuda_temp_81 = (first)->columns;
#line 184 "TransportModule.cs"
                                    double csharp2cuda_temp_82 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_81), column)];
#line 185 "TransportModule.cs"
                                    int csharp2cuda_temp_83 = (first)->columns;
#line 185 "TransportModule.cs"
                                    double csharp2cuda_temp_84 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_83), column)];
                                    (*(csharp2cuda_temp_79) = __dadd_rn(csharp2cuda_temp_80, __dmul_rn(csharp2cuda_temp_82, csharp2cuda_temp_84)));
#line 183 "TransportModule.cs"
                                    int* csharp2cuda_temp_77 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_77));
                                }
                            }
#line 182 "TransportModule.cs"
                            int* csharp2cuda_temp_75 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_75));
                        }
                    }
#line 186 "TransportModule.cs"
#line 186 "TransportModule.cs"
                    double* csharp2cuda_temp_85 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_85) = total);
#line 187 "TransportModule.cs"
                    break;
                }
#line 189 "TransportModule.cs"
            case 2:
#line 190 "TransportModule.cs"
#line 190 "TransportModule.cs"
                int csharp2cuda_temp_86 = (first)->count;
#line 190 "TransportModule.cs"
                bool csharp2cuda_temp_87;
#line 190 "TransportModule.cs"
                if (!(((csharp2cuda_temp_86) <= (0))))
                {
#line 190 "TransportModule.cs"
                    int csharp2cuda_temp_88 = (second)->count;
#line 190 "TransportModule.cs"
                    csharp2cuda_temp_87 = ((csharp2cuda_temp_88) <= (0));
                }
                else
                {
#line 190 "TransportModule.cs"
                    csharp2cuda_temp_87 = true;
                }
                if (csharp2cuda_temp_87)
#line 191 "TransportModule.cs"
                {
#line 192 "TransportModule.cs"
#line 192 "TransportModule.cs"
                    int* csharp2cuda_temp_89 = &((output)->valid);
                    (*(csharp2cuda_temp_89) = 0);
#line 193 "TransportModule.cs"
                    break;
                }
#line 195 "TransportModule.cs"
                {
#line 196 "TransportModule.cs"
                    double squared = __dsub_rn(__dsub_rn(__dmul_rn(2.0, energy_cross), energy_left_within), energy_right_within);
#line 198 "TransportModule.cs"
#line 198 "TransportModule.cs"
                    double* csharp2cuda_temp_90 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_90) = mathblocks_square_root(mathblocks_maximum(squared, 0.0)));
#line 199 "TransportModule.cs"
                    break;
                }
#line 201 "TransportModule.cs"
            case 3:
#line 202 "TransportModule.cs"
#line 202 "TransportModule.cs"
                int csharp2cuda_temp_91 = (first)->rows;
#line 202 "TransportModule.cs"
                int csharp2cuda_temp_92 = (first)->columns;
#line 202 "TransportModule.cs"
                bool csharp2cuda_temp_93;
#line 202 "TransportModule.cs"
                if (!(((csharp2cuda_temp_91) != (csharp2cuda_temp_92))))
                {
#line 202 "TransportModule.cs"
                    int csharp2cuda_temp_94 = (first)->rows;
#line 202 "TransportModule.cs"
                    csharp2cuda_temp_93 = ((csharp2cuda_temp_94) > (20));
                }
                else
                {
#line 202 "TransportModule.cs"
                    csharp2cuda_temp_93 = true;
                }
#line 202 "TransportModule.cs"
                bool csharp2cuda_temp_95;
#line 202 "TransportModule.cs"
                if (!(csharp2cuda_temp_93))
                {
#line 202 "TransportModule.cs"
                    csharp2cuda_temp_95 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 202 "TransportModule.cs"
                    csharp2cuda_temp_95 = true;
                }
                if (csharp2cuda_temp_95)
#line 203 "TransportModule.cs"
                {
#line 204 "TransportModule.cs"
#line 204 "TransportModule.cs"
                    int* csharp2cuda_temp_96 = &((output)->valid);
                    (*(csharp2cuda_temp_96) = 0);
#line 205 "TransportModule.cs"
                    break;
                }
#line 207 "TransportModule.cs"
                {
#line 208 "TransportModule.cs"
                    int size = (first)->rows;
#line 209 "TransportModule.cs"
                    int state_count = csharp2cuda_i32_shl(1, size);
#line 210 "TransportModule.cs"
                    mathblocks_sequence_set_vector_shape(output, size);
#line 211 "TransportModule.cs"
                    double* values = scratch;
#line 212 "TransportModule.cs"
                    int* previous_mask = ((int*)(csharp2cuda_pointer_add(values, state_count)));
#line 213 "TransportModule.cs"
                    int* chosen_column = csharp2cuda_pointer_add(previous_mask, state_count);
#line 214 "TransportModule.cs"
                    {
#line 214 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (state_count))))
                                break;
#line 215 "TransportModule.cs"
                            {
#line 216 "TransportModule.cs"
#line 216 "TransportModule.cs"
                                double* csharp2cuda_temp_98 = &((values)[index]);
                                (*(csharp2cuda_temp_98) = mathblocks_positive_infinity());
#line 217 "TransportModule.cs"
#line 217 "TransportModule.cs"
                                int* csharp2cuda_temp_99 = &((previous_mask)[index]);
                                (*(csharp2cuda_temp_99) = 0);
#line 218 "TransportModule.cs"
#line 218 "TransportModule.cs"
                                int* csharp2cuda_temp_100 = &((chosen_column)[index]);
                                (*(csharp2cuda_temp_100) = 0);
                            }
#line 214 "TransportModule.cs"
                            int* csharp2cuda_temp_97 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_97));
                        }
                    }
#line 220 "TransportModule.cs"
#line 220 "TransportModule.cs"
                    double* csharp2cuda_temp_101 = &((values)[0]);
                    (*(csharp2cuda_temp_101) = 0.0);
#line 221 "TransportModule.cs"
                    {
#line 221 "TransportModule.cs"
                        int mask = 0;
                        while (true)
                        {
                            if (!(((mask) < (state_count))))
                                break;
#line 222 "TransportModule.cs"
                            {
#line 223 "TransportModule.cs"
                                int row = mathblocks_advanced_popcount(mask);
#line 224 "TransportModule.cs"
#line 224 "TransportModule.cs"
                                bool csharp2cuda_temp_103;
#line 224 "TransportModule.cs"
                                if (!(((row) >= (size))))
                                {
#line 224 "TransportModule.cs"
                                    double csharp2cuda_temp_104 = (values)[mask];
#line 224 "TransportModule.cs"
                                    csharp2cuda_temp_103 = (!(isfinite(csharp2cuda_temp_104)));
                                }
                                else
                                {
#line 224 "TransportModule.cs"
                                    csharp2cuda_temp_103 = true;
                                }
                                if (csharp2cuda_temp_103)
                                {
#line 225 "TransportModule.cs"
                                    goto csharp2cuda_for_continue_6;
                                }
#line 226 "TransportModule.cs"
                                {
#line 226 "TransportModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (size))))
                                            break;
#line 227 "TransportModule.cs"
                                        {
#line 228 "TransportModule.cs"
                                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, column))) != (0)))
                                            {
#line 229 "TransportModule.cs"
                                                goto csharp2cuda_for_continue_5;
                                            }
#line 230 "TransportModule.cs"
                                            int next = csharp2cuda_i32_or(mask, csharp2cuda_i32_shl(1, column));
#line 231 "TransportModule.cs"
                                            double csharp2cuda_temp_106 = (values)[mask];
#line 231 "TransportModule.cs"
                                            double csharp2cuda_temp_107 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 231 "TransportModule.cs"
                                            double candidate = __dadd_rn(csharp2cuda_temp_106, csharp2cuda_temp_107);
#line 232 "TransportModule.cs"
#line 232 "TransportModule.cs"
                                            double csharp2cuda_temp_108 = (values)[next];
                                            if (((candidate) >= (csharp2cuda_temp_108)))
                                            {
#line 233 "TransportModule.cs"
                                                goto csharp2cuda_for_continue_5;
                                            }
#line 234 "TransportModule.cs"
#line 234 "TransportModule.cs"
                                            double* csharp2cuda_temp_109 = &((values)[next]);
                                            (*(csharp2cuda_temp_109) = candidate);
#line 235 "TransportModule.cs"
#line 235 "TransportModule.cs"
                                            int* csharp2cuda_temp_110 = &((previous_mask)[next]);
                                            (*(csharp2cuda_temp_110) = mask);
#line 236 "TransportModule.cs"
#line 236 "TransportModule.cs"
                                            int* csharp2cuda_temp_111 = &((chosen_column)[next]);
                                            (*(csharp2cuda_temp_111) = column);
                                        }
                                        csharp2cuda_for_continue_5:
#line 226 "TransportModule.cs"
                                        int* csharp2cuda_temp_105 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_105));
                                    }
                                }
                            }
                            csharp2cuda_for_continue_6:
#line 221 "TransportModule.cs"
                            int* csharp2cuda_temp_102 = &(mask);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_102));
                        }
                    }
#line 239 "TransportModule.cs"
                    int current = csharp2cuda_i32_sub(state_count, 1);
#line 240 "TransportModule.cs"
                    {
#line 240 "TransportModule.cs"
                        int row = csharp2cuda_i32_sub(size, 1);
                        while (true)
                        {
                            if (!(((row) >= (0))))
                                break;
#line 241 "TransportModule.cs"
                            {
#line 242 "TransportModule.cs"
#line 242 "TransportModule.cs"
                                double* csharp2cuda_temp_113 = &((result)[row]);
#line 242 "TransportModule.cs"
                                int csharp2cuda_temp_114 = (chosen_column)[current];
                                (*(csharp2cuda_temp_113) = ((double)(csharp2cuda_temp_114)));
#line 243 "TransportModule.cs"
#line 243 "TransportModule.cs"
                                int* csharp2cuda_temp_115 = &(current);
#line 243 "TransportModule.cs"
                                int csharp2cuda_temp_116 = (previous_mask)[current];
                                (*(csharp2cuda_temp_115) = csharp2cuda_temp_116);
                            }
#line 240 "TransportModule.cs"
                            int* csharp2cuda_temp_112 = &(row);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_112));
                        }
                    }
#line 245 "TransportModule.cs"
                    break;
                }
#line 247 "TransportModule.cs"
            case 4:
#line 248 "TransportModule.cs"
#line 248 "TransportModule.cs"
                int csharp2cuda_temp_117 = (first)->count;
#line 248 "TransportModule.cs"
                int csharp2cuda_temp_118 = (second)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_117, csharp2cuda_temp_118);
#line 249 "TransportModule.cs"
#line 249 "TransportModule.cs"
                int csharp2cuda_temp_119 = (first)->count;
#line 249 "TransportModule.cs"
                bool csharp2cuda_temp_120;
#line 249 "TransportModule.cs"
                if (!((!(mathblocks_advanced_distribution(a, csharp2cuda_temp_119)))))
                {
#line 250 "TransportModule.cs"
                    int csharp2cuda_temp_121 = (second)->count;
#line 249 "TransportModule.cs"
                    csharp2cuda_temp_120 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_121)));
                }
                else
                {
#line 249 "TransportModule.cs"
                    csharp2cuda_temp_120 = true;
                }
                if (csharp2cuda_temp_120)
#line 251 "TransportModule.cs"
                {
#line 252 "TransportModule.cs"
#line 252 "TransportModule.cs"
                    int* csharp2cuda_temp_122 = &((output)->valid);
                    (*(csharp2cuda_temp_122) = 0);
#line 253 "TransportModule.cs"
                    break;
                }
#line 255 "TransportModule.cs"
                {
#line 255 "TransportModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 255 "TransportModule.cs"
                        int csharp2cuda_temp_124 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_124))))
                            break;
#line 256 "TransportModule.cs"
#line 256 "TransportModule.cs"
                        double* csharp2cuda_temp_125 = &((result)[index]);
                        (*(csharp2cuda_temp_125) = 0.0);
#line 255 "TransportModule.cs"
                        int* csharp2cuda_temp_123 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_123));
                    }
                }
#line 257 "TransportModule.cs"
                {
#line 258 "TransportModule.cs"
                    int left_index = 0;
#line 259 "TransportModule.cs"
                    int right_index = 0;
#line 260 "TransportModule.cs"
                    double left_remaining = (a)[0];
#line 261 "TransportModule.cs"
                    double right_remaining = (b)[0];
#line 262 "TransportModule.cs"
                    while (true)
                    {
#line 262 "TransportModule.cs"
                        int csharp2cuda_temp_126 = (first)->count;
#line 262 "TransportModule.cs"
                        bool csharp2cuda_temp_127;
#line 262 "TransportModule.cs"
                        if (((left_index) < (csharp2cuda_temp_126)))
                        {
#line 262 "TransportModule.cs"
                            int csharp2cuda_temp_128 = (second)->count;
#line 262 "TransportModule.cs"
                            csharp2cuda_temp_127 = ((right_index) < (csharp2cuda_temp_128));
                        }
                        else
                        {
#line 262 "TransportModule.cs"
                            csharp2cuda_temp_127 = false;
                        }
                        if (!(csharp2cuda_temp_127))
                            break;
#line 263 "TransportModule.cs"
                        {
#line 264 "TransportModule.cs"
                            double csharp2cuda_temp_129;
#line 264 "TransportModule.cs"
                            if (((left_remaining) < (right_remaining)))
                            {
#line 264 "TransportModule.cs"
                                csharp2cuda_temp_129 = left_remaining;
                            }
                            else
                            {
#line 264 "TransportModule.cs"
                                csharp2cuda_temp_129 = right_remaining;
                            }
#line 264 "TransportModule.cs"
                            double amount = csharp2cuda_temp_129;
#line 267 "TransportModule.cs"
#line 267 "TransportModule.cs"
                            int csharp2cuda_temp_130 = (second)->count;
#line 267 "TransportModule.cs"
                            double* csharp2cuda_temp_131 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left_index, csharp2cuda_temp_130), right_index)]);
#line 267 "TransportModule.cs"
                            double csharp2cuda_temp_132 = *(csharp2cuda_temp_131);
                            (*(csharp2cuda_temp_131) = __dadd_rn(csharp2cuda_temp_132, amount));
#line 268 "TransportModule.cs"
#line 268 "TransportModule.cs"
                            double* csharp2cuda_temp_133 = &(left_remaining);
#line 268 "TransportModule.cs"
                            double csharp2cuda_temp_134 = *(csharp2cuda_temp_133);
                            (*(csharp2cuda_temp_133) = __dsub_rn(csharp2cuda_temp_134, amount));
#line 269 "TransportModule.cs"
#line 269 "TransportModule.cs"
                            double* csharp2cuda_temp_135 = &(right_remaining);
#line 269 "TransportModule.cs"
                            double csharp2cuda_temp_136 = *(csharp2cuda_temp_135);
                            (*(csharp2cuda_temp_135) = __dsub_rn(csharp2cuda_temp_136, amount));
#line 270 "TransportModule.cs"
#line 270 "TransportModule.cs"
                            bool csharp2cuda_temp_137;
#line 270 "TransportModule.cs"
                            if (((left_remaining) == (0.0)))
                            {
#line 270 "TransportModule.cs"
                                int* csharp2cuda_temp_138 = &(left_index);
#line 270 "TransportModule.cs"
                                int csharp2cuda_temp_139 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_138));
#line 270 "TransportModule.cs"
                                int csharp2cuda_temp_140 = (first)->count;
#line 270 "TransportModule.cs"
                                csharp2cuda_temp_137 = ((csharp2cuda_temp_139) < (csharp2cuda_temp_140));
                            }
                            else
                            {
#line 270 "TransportModule.cs"
                                csharp2cuda_temp_137 = false;
                            }
                            if (csharp2cuda_temp_137)
                            {
#line 271 "TransportModule.cs"
#line 271 "TransportModule.cs"
                                double* csharp2cuda_temp_141 = &(left_remaining);
#line 271 "TransportModule.cs"
                                double csharp2cuda_temp_142 = (a)[left_index];
                                (*(csharp2cuda_temp_141) = csharp2cuda_temp_142);
                            }
#line 272 "TransportModule.cs"
#line 272 "TransportModule.cs"
                            bool csharp2cuda_temp_143;
#line 272 "TransportModule.cs"
                            if (((right_remaining) == (0.0)))
                            {
#line 272 "TransportModule.cs"
                                int* csharp2cuda_temp_144 = &(right_index);
#line 272 "TransportModule.cs"
                                int csharp2cuda_temp_145 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_144));
#line 272 "TransportModule.cs"
                                int csharp2cuda_temp_146 = (second)->count;
#line 272 "TransportModule.cs"
                                csharp2cuda_temp_143 = ((csharp2cuda_temp_145) < (csharp2cuda_temp_146));
                            }
                            else
                            {
#line 272 "TransportModule.cs"
                                csharp2cuda_temp_143 = false;
                            }
                            if (csharp2cuda_temp_143)
                            {
#line 273 "TransportModule.cs"
#line 273 "TransportModule.cs"
                                double* csharp2cuda_temp_147 = &(right_remaining);
#line 273 "TransportModule.cs"
                                double csharp2cuda_temp_148 = (b)[right_index];
                                (*(csharp2cuda_temp_147) = csharp2cuda_temp_148);
                            }
                        }
                    }
#line 275 "TransportModule.cs"
                    break;
                }
#line 277 "TransportModule.cs"
            case 5:
#line 278 "TransportModule.cs"
#line 278 "TransportModule.cs"
                int csharp2cuda_temp_149 = (first)->count;
#line 278 "TransportModule.cs"
                int csharp2cuda_temp_150 = (second)->count;
#line 278 "TransportModule.cs"
                bool csharp2cuda_temp_151;
#line 278 "TransportModule.cs"
                if (!(((csharp2cuda_temp_149) != (csharp2cuda_temp_150))))
                {
#line 279 "TransportModule.cs"
                    int csharp2cuda_temp_152 = (first)->count;
#line 278 "TransportModule.cs"
                    csharp2cuda_temp_151 = (!(mathblocks_advanced_distribution(a, csharp2cuda_temp_152)));
                }
                else
                {
#line 278 "TransportModule.cs"
                    csharp2cuda_temp_151 = true;
                }
#line 278 "TransportModule.cs"
                bool csharp2cuda_temp_153;
#line 278 "TransportModule.cs"
                if (!(csharp2cuda_temp_151))
                {
#line 280 "TransportModule.cs"
                    int csharp2cuda_temp_154 = (second)->count;
#line 278 "TransportModule.cs"
                    csharp2cuda_temp_153 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_154)));
                }
                else
                {
#line 278 "TransportModule.cs"
                    csharp2cuda_temp_153 = true;
                }
                if (csharp2cuda_temp_153)
#line 281 "TransportModule.cs"
                {
#line 282 "TransportModule.cs"
#line 282 "TransportModule.cs"
                    int* csharp2cuda_temp_155 = &((output)->valid);
                    (*(csharp2cuda_temp_155) = 0);
#line 283 "TransportModule.cs"
                    break;
                }
#line 285 "TransportModule.cs"
                {
#line 286 "TransportModule.cs"
                    double cumulative = 0.0;
#line 287 "TransportModule.cs"
                    double total = 0.0;
#line 288 "TransportModule.cs"
                    {
#line 288 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 288 "TransportModule.cs"
                            int csharp2cuda_temp_157 = (first)->count;
                            if (!(((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_157, 1)))))
                                break;
#line 289 "TransportModule.cs"
                            {
#line 290 "TransportModule.cs"
#line 290 "TransportModule.cs"
                                double* csharp2cuda_temp_158 = &(cumulative);
#line 290 "TransportModule.cs"
                                double csharp2cuda_temp_159 = *(csharp2cuda_temp_158);
#line 290 "TransportModule.cs"
                                double csharp2cuda_temp_160 = (a)[index];
#line 290 "TransportModule.cs"
                                double csharp2cuda_temp_161 = (b)[index];
                                (*(csharp2cuda_temp_158) = __dadd_rn(csharp2cuda_temp_159, __dsub_rn(csharp2cuda_temp_160, csharp2cuda_temp_161)));
#line 291 "TransportModule.cs"
#line 291 "TransportModule.cs"
                                double* csharp2cuda_temp_162 = &(total);
#line 291 "TransportModule.cs"
                                double csharp2cuda_temp_163 = *(csharp2cuda_temp_162);
                                (*(csharp2cuda_temp_162) = __dadd_rn(csharp2cuda_temp_163, fabs(cumulative)));
                            }
#line 288 "TransportModule.cs"
                            int* csharp2cuda_temp_156 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                        }
                    }
#line 293 "TransportModule.cs"
#line 293 "TransportModule.cs"
                    double* csharp2cuda_temp_164 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_164) = total);
#line 294 "TransportModule.cs"
                    break;
                }
#line 296 "TransportModule.cs"
            case 6:
#line 297 "TransportModule.cs"
#line 297 "TransportModule.cs"
                int csharp2cuda_temp_165 = (first)->rows;
#line 297 "TransportModule.cs"
                int csharp2cuda_temp_166 = (first)->columns;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_165, csharp2cuda_temp_166);
#line 298 "TransportModule.cs"
#line 298 "TransportModule.cs"
                int csharp2cuda_temp_167 = (first)->rows;
#line 298 "TransportModule.cs"
                int csharp2cuda_temp_168 = (second)->count;
#line 298 "TransportModule.cs"
                bool csharp2cuda_temp_169;
#line 298 "TransportModule.cs"
                if (!(((csharp2cuda_temp_167) != (csharp2cuda_temp_168))))
                {
#line 298 "TransportModule.cs"
                    int csharp2cuda_temp_170 = (first)->columns;
#line 298 "TransportModule.cs"
                    int csharp2cuda_temp_171 = (third)->count;
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_169 = ((csharp2cuda_temp_170) != (csharp2cuda_temp_171));
                }
                else
                {
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_169 = true;
                }
#line 298 "TransportModule.cs"
                bool csharp2cuda_temp_172;
#line 298 "TransportModule.cs"
                if (!(csharp2cuda_temp_169))
                {
#line 299 "TransportModule.cs"
                    int csharp2cuda_temp_173 = (second)->count;
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_172 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_173)));
                }
                else
                {
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_172 = true;
                }
#line 298 "TransportModule.cs"
                bool csharp2cuda_temp_174;
#line 298 "TransportModule.cs"
                if (!(csharp2cuda_temp_172))
                {
#line 300 "TransportModule.cs"
                    int csharp2cuda_temp_175 = (third)->count;
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_174 = (!(mathblocks_advanced_distribution(c, csharp2cuda_temp_175)));
                }
                else
                {
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_174 = true;
                }
#line 298 "TransportModule.cs"
                bool csharp2cuda_temp_176;
#line 298 "TransportModule.cs"
                if (!(csharp2cuda_temp_174))
                {
#line 301 "TransportModule.cs"
                    double csharp2cuda_temp_177 = (fourth)->scalar_value;
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_176 = ((csharp2cuda_temp_177) <= (0.0));
                }
                else
                {
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_176 = true;
                }
#line 298 "TransportModule.cs"
                bool csharp2cuda_temp_178;
#line 298 "TransportModule.cs"
                if (!(csharp2cuda_temp_176))
                {
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_178 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 298 "TransportModule.cs"
                    csharp2cuda_temp_178 = true;
                }
                if (csharp2cuda_temp_178)
#line 302 "TransportModule.cs"
                {
#line 303 "TransportModule.cs"
#line 303 "TransportModule.cs"
                    int* csharp2cuda_temp_179 = &((output)->valid);
                    (*(csharp2cuda_temp_179) = 0);
#line 304 "TransportModule.cs"
                    break;
                }
#line 306 "TransportModule.cs"
                {
#line 307 "TransportModule.cs"
                    int iterations = 0;
#line 308 "TransportModule.cs"
#line 308 "TransportModule.cs"
                    double csharp2cuda_temp_180 = (fifth)->scalar_value;
#line 308 "TransportModule.cs"
                    int* csharp2cuda_temp_181 = &(iterations);
#line 308 "TransportModule.cs"
                    bool csharp2cuda_temp_182 = mathblocks_sequence_positive_integer(csharp2cuda_temp_180, csharp2cuda_temp_181);
#line 308 "TransportModule.cs"
                    bool csharp2cuda_temp_183;
#line 308 "TransportModule.cs"
                    if (!((!(csharp2cuda_temp_182))))
                    {
#line 308 "TransportModule.cs"
                        csharp2cuda_temp_183 = ((iterations) > (10000));
                    }
                    else
                    {
#line 308 "TransportModule.cs"
                        csharp2cuda_temp_183 = true;
                    }
                    if (csharp2cuda_temp_183)
#line 309 "TransportModule.cs"
                    {
#line 310 "TransportModule.cs"
#line 310 "TransportModule.cs"
                        int* csharp2cuda_temp_184 = &((output)->valid);
                        (*(csharp2cuda_temp_184) = 0);
#line 311 "TransportModule.cs"
                        break;
                    }
#line 313 "TransportModule.cs"
                    double* kernel = scratch;
#line 314 "TransportModule.cs"
                    int csharp2cuda_temp_185 = (first)->count;
#line 314 "TransportModule.cs"
                    double* left_scale = csharp2cuda_pointer_add(kernel, csharp2cuda_temp_185);
#line 315 "TransportModule.cs"
                    int csharp2cuda_temp_186 = (first)->rows;
#line 315 "TransportModule.cs"
                    double* right_scale = csharp2cuda_pointer_add(left_scale, csharp2cuda_temp_186);
#line 316 "TransportModule.cs"
                    {
#line 316 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 316 "TransportModule.cs"
                            int csharp2cuda_temp_188 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_188))))
                                break;
#line 317 "TransportModule.cs"
                            {
#line 317 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 317 "TransportModule.cs"
                                    int csharp2cuda_temp_190 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_190))))
                                        break;
#line 318 "TransportModule.cs"
#line 318 "TransportModule.cs"
                                    int csharp2cuda_temp_191 = (first)->columns;
#line 318 "TransportModule.cs"
                                    double* csharp2cuda_temp_192 = &((kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_191), column)]);
#line 319 "TransportModule.cs"
                                    int csharp2cuda_temp_193 = (first)->columns;
#line 319 "TransportModule.cs"
                                    double csharp2cuda_temp_194 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_193), column)];
#line 320 "TransportModule.cs"
                                    double csharp2cuda_temp_195 = (fourth)->scalar_value;
#line 319 "TransportModule.cs"
                                    double csharp2cuda_temp_196 = __ddiv_rn((-(csharp2cuda_temp_194)), csharp2cuda_temp_195);
                                    (*(csharp2cuda_temp_192) = mathblocks_exponential(csharp2cuda_temp_196));
#line 317 "TransportModule.cs"
                                    int* csharp2cuda_temp_189 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_189));
                                }
                            }
#line 316 "TransportModule.cs"
                            int* csharp2cuda_temp_187 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_187));
                        }
                    }
#line 321 "TransportModule.cs"
                    {
#line 321 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 321 "TransportModule.cs"
                            int csharp2cuda_temp_198 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_198))))
                                break;
#line 322 "TransportModule.cs"
#line 322 "TransportModule.cs"
                            double* csharp2cuda_temp_199 = &((left_scale)[row]);
                            (*(csharp2cuda_temp_199) = 1.0);
#line 321 "TransportModule.cs"
                            int* csharp2cuda_temp_197 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_197));
                        }
                    }
#line 323 "TransportModule.cs"
                    {
#line 323 "TransportModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 323 "TransportModule.cs"
                            int csharp2cuda_temp_201 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_201))))
                                break;
#line 324 "TransportModule.cs"
#line 324 "TransportModule.cs"
                            double* csharp2cuda_temp_202 = &((right_scale)[column]);
                            (*(csharp2cuda_temp_202) = 1.0);
#line 323 "TransportModule.cs"
                            int* csharp2cuda_temp_200 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_200));
                        }
                    }
#line 325 "TransportModule.cs"
                    {
#line 325 "TransportModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 326 "TransportModule.cs"
                            {
#line 327 "TransportModule.cs"
                                {
#line 327 "TransportModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 327 "TransportModule.cs"
                                        int csharp2cuda_temp_205 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_205))))
                                            break;
#line 328 "TransportModule.cs"
                                        {
#line 329 "TransportModule.cs"
                                            double sum = 0.0;
#line 330 "TransportModule.cs"
                                            {
#line 330 "TransportModule.cs"
                                                int column = 0;
                                                while (true)
                                                {
#line 330 "TransportModule.cs"
                                                    int csharp2cuda_temp_207 = (first)->columns;
                                                    if (!(((column) < (csharp2cuda_temp_207))))
                                                        break;
#line 331 "TransportModule.cs"
#line 331 "TransportModule.cs"
                                                    double* csharp2cuda_temp_208 = &(sum);
#line 331 "TransportModule.cs"
                                                    double csharp2cuda_temp_209 = *(csharp2cuda_temp_208);
#line 331 "TransportModule.cs"
                                                    int csharp2cuda_temp_210 = (first)->columns;
#line 331 "TransportModule.cs"
                                                    double csharp2cuda_temp_211 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_210), column)];
#line 331 "TransportModule.cs"
                                                    double csharp2cuda_temp_212 = (right_scale)[column];
                                                    (*(csharp2cuda_temp_208) = __dadd_rn(csharp2cuda_temp_209, __dmul_rn(csharp2cuda_temp_211, csharp2cuda_temp_212)));
#line 330 "TransportModule.cs"
                                                    int* csharp2cuda_temp_206 = &(column);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_206));
                                                }
                                            }
#line 332 "TransportModule.cs"
#line 332 "TransportModule.cs"
                                            double* csharp2cuda_temp_213 = &((left_scale)[row]);
#line 332 "TransportModule.cs"
                                            double csharp2cuda_temp_214 = (b)[row];
#line 332 "TransportModule.cs"
                                            double csharp2cuda_temp_215 = __ddiv_rn(csharp2cuda_temp_214, sum);
                                            (*(csharp2cuda_temp_213) = csharp2cuda_temp_215);
                                        }
#line 327 "TransportModule.cs"
                                        int* csharp2cuda_temp_204 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_204));
                                    }
                                }
#line 334 "TransportModule.cs"
                                {
#line 334 "TransportModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
#line 334 "TransportModule.cs"
                                        int csharp2cuda_temp_217 = (first)->columns;
                                        if (!(((column) < (csharp2cuda_temp_217))))
                                            break;
#line 335 "TransportModule.cs"
                                        {
#line 336 "TransportModule.cs"
                                            double sum = 0.0;
#line 337 "TransportModule.cs"
                                            {
#line 337 "TransportModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
#line 337 "TransportModule.cs"
                                                    int csharp2cuda_temp_219 = (first)->rows;
                                                    if (!(((row) < (csharp2cuda_temp_219))))
                                                        break;
#line 338 "TransportModule.cs"
#line 338 "TransportModule.cs"
                                                    double* csharp2cuda_temp_220 = &(sum);
#line 338 "TransportModule.cs"
                                                    double csharp2cuda_temp_221 = *(csharp2cuda_temp_220);
#line 338 "TransportModule.cs"
                                                    int csharp2cuda_temp_222 = (first)->columns;
#line 338 "TransportModule.cs"
                                                    double csharp2cuda_temp_223 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_222), column)];
#line 338 "TransportModule.cs"
                                                    double csharp2cuda_temp_224 = (left_scale)[row];
                                                    (*(csharp2cuda_temp_220) = __dadd_rn(csharp2cuda_temp_221, __dmul_rn(csharp2cuda_temp_223, csharp2cuda_temp_224)));
#line 337 "TransportModule.cs"
                                                    int* csharp2cuda_temp_218 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_218));
                                                }
                                            }
#line 339 "TransportModule.cs"
#line 339 "TransportModule.cs"
                                            double* csharp2cuda_temp_225 = &((right_scale)[column]);
#line 339 "TransportModule.cs"
                                            double csharp2cuda_temp_226 = (c)[column];
#line 339 "TransportModule.cs"
                                            double csharp2cuda_temp_227 = __ddiv_rn(csharp2cuda_temp_226, sum);
                                            (*(csharp2cuda_temp_225) = csharp2cuda_temp_227);
                                        }
#line 334 "TransportModule.cs"
                                        int* csharp2cuda_temp_216 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_216));
                                    }
                                }
                            }
#line 325 "TransportModule.cs"
                            int* csharp2cuda_temp_203 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_203));
                        }
                    }
#line 342 "TransportModule.cs"
                    {
#line 342 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 342 "TransportModule.cs"
                            int csharp2cuda_temp_229 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_229))))
                                break;
#line 343 "TransportModule.cs"
                            {
#line 343 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 343 "TransportModule.cs"
                                    int csharp2cuda_temp_231 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_231))))
                                        break;
#line 344 "TransportModule.cs"
#line 344 "TransportModule.cs"
                                    int csharp2cuda_temp_232 = (first)->columns;
#line 344 "TransportModule.cs"
                                    double* csharp2cuda_temp_233 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_232), column)]);
#line 345 "TransportModule.cs"
                                    double csharp2cuda_temp_234 = (left_scale)[row];
#line 345 "TransportModule.cs"
                                    int csharp2cuda_temp_235 = (first)->columns;
#line 345 "TransportModule.cs"
                                    double csharp2cuda_temp_236 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_235), column)];
#line 346 "TransportModule.cs"
                                    double csharp2cuda_temp_237 = (right_scale)[column];
                                    (*(csharp2cuda_temp_233) = __dmul_rn(__dmul_rn(csharp2cuda_temp_234, csharp2cuda_temp_236), csharp2cuda_temp_237));
#line 343 "TransportModule.cs"
                                    int* csharp2cuda_temp_230 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_230));
                                }
                            }
#line 342 "TransportModule.cs"
                            int* csharp2cuda_temp_228 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_228));
                        }
                    }
#line 347 "TransportModule.cs"
                    break;
                }
#line 349 "TransportModule.cs"
            case 7:
#line 350 "TransportModule.cs"
#line 350 "TransportModule.cs"
                int csharp2cuda_temp_238 = (first)->count;
#line 350 "TransportModule.cs"
                bool csharp2cuda_temp_239;
#line 350 "TransportModule.cs"
                if (!(((csharp2cuda_temp_238) <= (0))))
                {
#line 350 "TransportModule.cs"
                    int csharp2cuda_temp_240 = (first)->count;
#line 350 "TransportModule.cs"
                    int csharp2cuda_temp_241 = (second)->count;
#line 350 "TransportModule.cs"
                    csharp2cuda_temp_239 = ((csharp2cuda_temp_240) != (csharp2cuda_temp_241));
                }
                else
                {
#line 350 "TransportModule.cs"
                    csharp2cuda_temp_239 = true;
                }
#line 350 "TransportModule.cs"
                bool csharp2cuda_temp_242;
#line 350 "TransportModule.cs"
                if (!(csharp2cuda_temp_239))
                {
#line 351 "TransportModule.cs"
                    double csharp2cuda_temp_243 = (third)->scalar_value;
#line 350 "TransportModule.cs"
                    csharp2cuda_temp_242 = ((csharp2cuda_temp_243) < (1.0));
                }
                else
                {
#line 350 "TransportModule.cs"
                    csharp2cuda_temp_242 = true;
                }
#line 350 "TransportModule.cs"
                bool csharp2cuda_temp_244;
#line 350 "TransportModule.cs"
                if (!(csharp2cuda_temp_242))
                {
#line 350 "TransportModule.cs"
                    csharp2cuda_temp_244 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 350 "TransportModule.cs"
                    csharp2cuda_temp_244 = true;
                }
                if (csharp2cuda_temp_244)
#line 352 "TransportModule.cs"
                {
#line 353 "TransportModule.cs"
#line 353 "TransportModule.cs"
                    int* csharp2cuda_temp_245 = &((output)->valid);
                    (*(csharp2cuda_temp_245) = 0);
#line 354 "TransportModule.cs"
                    break;
                }
#line 356 "TransportModule.cs"
                {
#line 357 "TransportModule.cs"
                    double* left_sorted = scratch;
#line 358 "TransportModule.cs"
                    int csharp2cuda_temp_246 = (first)->count;
#line 358 "TransportModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_246);
#line 359 "TransportModule.cs"
#line 359 "TransportModule.cs"
                    int csharp2cuda_temp_247 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_247, left_sorted, false);
#line 360 "TransportModule.cs"
#line 360 "TransportModule.cs"
                    int csharp2cuda_temp_248 = (second)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_248, right_sorted, false);
#line 361 "TransportModule.cs"
                    double sum = 0.0;
#line 362 "TransportModule.cs"
                    {
#line 362 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 362 "TransportModule.cs"
                            int csharp2cuda_temp_250 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_250))))
                                break;
#line 363 "TransportModule.cs"
#line 363 "TransportModule.cs"
                            double* csharp2cuda_temp_251 = &(sum);
#line 363 "TransportModule.cs"
                            double csharp2cuda_temp_252 = *(csharp2cuda_temp_251);
#line 364 "TransportModule.cs"
                            double csharp2cuda_temp_253 = (left_sorted)[index];
#line 364 "TransportModule.cs"
                            double csharp2cuda_temp_254 = (right_sorted)[index];
#line 365 "TransportModule.cs"
                            double csharp2cuda_temp_255 = (third)->scalar_value;
                            (*(csharp2cuda_temp_251) = __dadd_rn(csharp2cuda_temp_252, mathblocks_power(fabs(__dsub_rn(csharp2cuda_temp_253, csharp2cuda_temp_254)), csharp2cuda_temp_255)));
#line 362 "TransportModule.cs"
                            int* csharp2cuda_temp_249 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_249));
                        }
                    }
#line 366 "TransportModule.cs"
#line 366 "TransportModule.cs"
                    double* csharp2cuda_temp_256 = &((output)->scalar_value);
#line 367 "TransportModule.cs"
                    int csharp2cuda_temp_257 = (first)->count;
#line 367 "TransportModule.cs"
                    double csharp2cuda_temp_258 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_257)));
#line 368 "TransportModule.cs"
                    double csharp2cuda_temp_259 = (third)->scalar_value;
#line 368 "TransportModule.cs"
                    double csharp2cuda_temp_260 = __ddiv_rn(1.0, csharp2cuda_temp_259);
                    (*(csharp2cuda_temp_256) = mathblocks_power(csharp2cuda_temp_258, csharp2cuda_temp_260));
#line 369 "TransportModule.cs"
                    break;
                }
#line 371 "TransportModule.cs"
            case 8:
#line 372 "TransportModule.cs"
#line 372 "TransportModule.cs"
                int csharp2cuda_temp_261 = (first)->count;
#line 372 "TransportModule.cs"
                bool csharp2cuda_temp_262;
#line 372 "TransportModule.cs"
                if (!(((csharp2cuda_temp_261) <= (0))))
                {
#line 372 "TransportModule.cs"
                    int csharp2cuda_temp_263 = (first)->count;
#line 372 "TransportModule.cs"
                    int csharp2cuda_temp_264 = (second)->count;
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_262 = ((csharp2cuda_temp_263) != (csharp2cuda_temp_264));
                }
                else
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_262 = true;
                }
#line 372 "TransportModule.cs"
                bool csharp2cuda_temp_265;
#line 372 "TransportModule.cs"
                if (!(csharp2cuda_temp_262))
                {
#line 373 "TransportModule.cs"
                    int csharp2cuda_temp_266 = (third)->count;
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_265 = ((csharp2cuda_temp_266) <= (0));
                }
                else
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_265 = true;
                }
#line 372 "TransportModule.cs"
                bool csharp2cuda_temp_267;
#line 372 "TransportModule.cs"
                if (!(csharp2cuda_temp_265))
                {
#line 373 "TransportModule.cs"
                    int csharp2cuda_temp_268 = (third)->count;
#line 373 "TransportModule.cs"
                    int csharp2cuda_temp_269 = (fourth)->count;
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_267 = ((csharp2cuda_temp_268) != (csharp2cuda_temp_269));
                }
                else
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_267 = true;
                }
#line 372 "TransportModule.cs"
                bool csharp2cuda_temp_270;
#line 372 "TransportModule.cs"
                if (!(csharp2cuda_temp_267))
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_270 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_270 = true;
                }
#line 372 "TransportModule.cs"
                bool csharp2cuda_temp_271;
#line 372 "TransportModule.cs"
                if (!(csharp2cuda_temp_270))
                {
#line 374 "TransportModule.cs"
                    int csharp2cuda_temp_272 = (second)->count;
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_271 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_272)));
                }
                else
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_271 = true;
                }
#line 372 "TransportModule.cs"
                bool csharp2cuda_temp_273;
#line 372 "TransportModule.cs"
                if (!(csharp2cuda_temp_271))
                {
#line 375 "TransportModule.cs"
                    int csharp2cuda_temp_274 = (fourth)->count;
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_273 = (!(mathblocks_advanced_distribution(d, csharp2cuda_temp_274)));
                }
                else
                {
#line 372 "TransportModule.cs"
                    csharp2cuda_temp_273 = true;
                }
                if (csharp2cuda_temp_273)
#line 376 "TransportModule.cs"
                {
#line 377 "TransportModule.cs"
#line 377 "TransportModule.cs"
                    int* csharp2cuda_temp_275 = &((output)->valid);
                    (*(csharp2cuda_temp_275) = 0);
#line 378 "TransportModule.cs"
                    break;
                }
#line 380 "TransportModule.cs"
                {
#line 381 "TransportModule.cs"
                    int* left_order = ((int*)(scratch));
#line 382 "TransportModule.cs"
                    int csharp2cuda_temp_276 = (first)->count;
#line 382 "TransportModule.cs"
                    int* right_order = csharp2cuda_pointer_add(left_order, csharp2cuda_temp_276);
#line 383 "TransportModule.cs"
                    int csharp2cuda_temp_277 = (third)->count;
#line 383 "TransportModule.cs"
                    int* left_buffer = csharp2cuda_pointer_add(right_order, csharp2cuda_temp_277);
#line 384 "TransportModule.cs"
                    int csharp2cuda_temp_278 = (first)->count;
#line 384 "TransportModule.cs"
                    int* right_buffer = csharp2cuda_pointer_add(left_buffer, csharp2cuda_temp_278);
#line 385 "TransportModule.cs"
#line 385 "TransportModule.cs"
                    int csharp2cuda_temp_279 = (first)->count;
                    mathblocks_stable_index_order(a, csharp2cuda_temp_279, left_order, left_buffer);
#line 386 "TransportModule.cs"
#line 386 "TransportModule.cs"
                    int csharp2cuda_temp_280 = (third)->count;
                    mathblocks_stable_index_order(c, csharp2cuda_temp_280, right_order, right_buffer);
#line 387 "TransportModule.cs"
                    int left_index = 0;
#line 388 "TransportModule.cs"
                    int right_index = 0;
#line 389 "TransportModule.cs"
                    int csharp2cuda_temp_281 = (left_order)[0];
#line 389 "TransportModule.cs"
                    double left_remaining = (b)[csharp2cuda_temp_281];
#line 390 "TransportModule.cs"
                    int csharp2cuda_temp_282 = (right_order)[0];
#line 390 "TransportModule.cs"
                    double right_remaining = (d)[csharp2cuda_temp_282];
#line 391 "TransportModule.cs"
                    double total = 0.0;
#line 392 "TransportModule.cs"
                    while (true)
                    {
#line 392 "TransportModule.cs"
                        int csharp2cuda_temp_283 = (first)->count;
#line 392 "TransportModule.cs"
                        bool csharp2cuda_temp_284;
#line 392 "TransportModule.cs"
                        if (((left_index) < (csharp2cuda_temp_283)))
                        {
#line 392 "TransportModule.cs"
                            int csharp2cuda_temp_285 = (third)->count;
#line 392 "TransportModule.cs"
                            csharp2cuda_temp_284 = ((right_index) < (csharp2cuda_temp_285));
                        }
                        else
                        {
#line 392 "TransportModule.cs"
                            csharp2cuda_temp_284 = false;
                        }
                        if (!(csharp2cuda_temp_284))
                            break;
#line 393 "TransportModule.cs"
                        {
#line 394 "TransportModule.cs"
                            double csharp2cuda_temp_286;
#line 394 "TransportModule.cs"
                            if (((left_remaining) < (right_remaining)))
                            {
#line 394 "TransportModule.cs"
                                csharp2cuda_temp_286 = left_remaining;
                            }
                            else
                            {
#line 394 "TransportModule.cs"
                                csharp2cuda_temp_286 = right_remaining;
                            }
#line 394 "TransportModule.cs"
                            double amount = csharp2cuda_temp_286;
#line 397 "TransportModule.cs"
#line 397 "TransportModule.cs"
                            double* csharp2cuda_temp_287 = &(total);
#line 397 "TransportModule.cs"
                            double csharp2cuda_temp_288 = *(csharp2cuda_temp_287);
#line 398 "TransportModule.cs"
                            int csharp2cuda_temp_289 = (left_order)[left_index];
#line 398 "TransportModule.cs"
                            double csharp2cuda_temp_290 = (a)[csharp2cuda_temp_289];
#line 398 "TransportModule.cs"
                            int csharp2cuda_temp_291 = (right_order)[right_index];
#line 398 "TransportModule.cs"
                            double csharp2cuda_temp_292 = (c)[csharp2cuda_temp_291];
                            (*(csharp2cuda_temp_287) = __dadd_rn(csharp2cuda_temp_288, __dmul_rn(amount, fabs(__dsub_rn(csharp2cuda_temp_290, csharp2cuda_temp_292)))));
#line 399 "TransportModule.cs"
#line 399 "TransportModule.cs"
                            double* csharp2cuda_temp_293 = &(left_remaining);
#line 399 "TransportModule.cs"
                            double csharp2cuda_temp_294 = *(csharp2cuda_temp_293);
                            (*(csharp2cuda_temp_293) = __dsub_rn(csharp2cuda_temp_294, amount));
#line 400 "TransportModule.cs"
#line 400 "TransportModule.cs"
                            double* csharp2cuda_temp_295 = &(right_remaining);
#line 400 "TransportModule.cs"
                            double csharp2cuda_temp_296 = *(csharp2cuda_temp_295);
                            (*(csharp2cuda_temp_295) = __dsub_rn(csharp2cuda_temp_296, amount));
#line 401 "TransportModule.cs"
#line 401 "TransportModule.cs"
                            bool csharp2cuda_temp_297;
#line 401 "TransportModule.cs"
                            if (((left_remaining) == (0.0)))
                            {
#line 401 "TransportModule.cs"
                                int* csharp2cuda_temp_298 = &(left_index);
#line 401 "TransportModule.cs"
                                int csharp2cuda_temp_299 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_298));
#line 401 "TransportModule.cs"
                                int csharp2cuda_temp_300 = (first)->count;
#line 401 "TransportModule.cs"
                                csharp2cuda_temp_297 = ((csharp2cuda_temp_299) < (csharp2cuda_temp_300));
                            }
                            else
                            {
#line 401 "TransportModule.cs"
                                csharp2cuda_temp_297 = false;
                            }
                            if (csharp2cuda_temp_297)
                            {
#line 402 "TransportModule.cs"
#line 402 "TransportModule.cs"
                                double* csharp2cuda_temp_301 = &(left_remaining);
#line 402 "TransportModule.cs"
                                int csharp2cuda_temp_302 = (left_order)[left_index];
#line 402 "TransportModule.cs"
                                double csharp2cuda_temp_303 = (b)[csharp2cuda_temp_302];
                                (*(csharp2cuda_temp_301) = csharp2cuda_temp_303);
                            }
#line 403 "TransportModule.cs"
#line 403 "TransportModule.cs"
                            bool csharp2cuda_temp_304;
#line 403 "TransportModule.cs"
                            if (((right_remaining) == (0.0)))
                            {
#line 403 "TransportModule.cs"
                                int* csharp2cuda_temp_305 = &(right_index);
#line 403 "TransportModule.cs"
                                int csharp2cuda_temp_306 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_305));
#line 403 "TransportModule.cs"
                                int csharp2cuda_temp_307 = (third)->count;
#line 403 "TransportModule.cs"
                                csharp2cuda_temp_304 = ((csharp2cuda_temp_306) < (csharp2cuda_temp_307));
                            }
                            else
                            {
#line 403 "TransportModule.cs"
                                csharp2cuda_temp_304 = false;
                            }
                            if (csharp2cuda_temp_304)
                            {
#line 404 "TransportModule.cs"
#line 404 "TransportModule.cs"
                                double* csharp2cuda_temp_308 = &(right_remaining);
#line 404 "TransportModule.cs"
                                int csharp2cuda_temp_309 = (right_order)[right_index];
#line 404 "TransportModule.cs"
                                double csharp2cuda_temp_310 = (d)[csharp2cuda_temp_309];
                                (*(csharp2cuda_temp_308) = csharp2cuda_temp_310);
                            }
                        }
                    }
#line 406 "TransportModule.cs"
#line 406 "TransportModule.cs"
                    double* csharp2cuda_temp_311 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_311) = total);
#line 407 "TransportModule.cs"
                    break;
                }
#line 409 "TransportModule.cs"
            case 9:
            case 10:
#line 411 "TransportModule.cs"
#line 411 "TransportModule.cs"
                int csharp2cuda_temp_312 = (first)->rows;
#line 411 "TransportModule.cs"
                int csharp2cuda_temp_313 = (second)->columns;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_312, csharp2cuda_temp_313);
#line 412 "TransportModule.cs"
#line 412 "TransportModule.cs"
                int csharp2cuda_temp_314 = (first)->columns;
#line 412 "TransportModule.cs"
                int csharp2cuda_temp_315 = (second)->rows;
                if (((csharp2cuda_temp_314) != (csharp2cuda_temp_315)))
#line 413 "TransportModule.cs"
                {
#line 414 "TransportModule.cs"
#line 414 "TransportModule.cs"
                    int* csharp2cuda_temp_316 = &((output)->valid);
                    (*(csharp2cuda_temp_316) = 0);
#line 415 "TransportModule.cs"
                    break;
                }
#line 417 "TransportModule.cs"
                {
#line 417 "TransportModule.cs"
                    int row = 0;
                    while (true)
                    {
#line 417 "TransportModule.cs"
                        int csharp2cuda_temp_318 = (first)->rows;
                        if (!(((row) < (csharp2cuda_temp_318))))
                            break;
#line 418 "TransportModule.cs"
                        {
#line 418 "TransportModule.cs"
                            int column = 0;
                            while (true)
                            {
#line 418 "TransportModule.cs"
                                int csharp2cuda_temp_320 = (second)->columns;
                                if (!(((column) < (csharp2cuda_temp_320))))
                                    break;
#line 419 "TransportModule.cs"
                                {
#line 420 "TransportModule.cs"
                                    double csharp2cuda_temp_321;
#line 420 "TransportModule.cs"
                                    if (((opcode) == (9)))
                                    {
#line 420 "TransportModule.cs"
                                        csharp2cuda_temp_321 = (-(mathblocks_positive_infinity()));
                                    }
                                    else
                                    {
#line 420 "TransportModule.cs"
                                        csharp2cuda_temp_321 = mathblocks_positive_infinity();
                                    }
#line 420 "TransportModule.cs"
                                    double selected = csharp2cuda_temp_321;
#line 423 "TransportModule.cs"
                                    {
#line 423 "TransportModule.cs"
                                        int inner = 0;
                                        while (true)
                                        {
#line 423 "TransportModule.cs"
                                            int csharp2cuda_temp_323 = (first)->columns;
                                            if (!(((inner) < (csharp2cuda_temp_323))))
                                                break;
#line 424 "TransportModule.cs"
                                            {
#line 425 "TransportModule.cs"
                                                int csharp2cuda_temp_324 = (first)->columns;
#line 425 "TransportModule.cs"
                                                double csharp2cuda_temp_325 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_324), inner)];
#line 426 "TransportModule.cs"
                                                int csharp2cuda_temp_326 = (second)->columns;
#line 426 "TransportModule.cs"
                                                double csharp2cuda_temp_327 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_326), column)];
#line 425 "TransportModule.cs"
                                                double candidate = __dadd_rn(csharp2cuda_temp_325, csharp2cuda_temp_327);
#line 428 "TransportModule.cs"
#line 428 "TransportModule.cs"
                                                double* csharp2cuda_temp_328 = &(selected);
#line 428 "TransportModule.cs"
                                                double csharp2cuda_temp_329;
#line 428 "TransportModule.cs"
                                                if (((opcode) == (9)))
                                                {
#line 428 "TransportModule.cs"
                                                    csharp2cuda_temp_329 = mathblocks_maximum(selected, candidate);
                                                }
                                                else
                                                {
#line 428 "TransportModule.cs"
                                                    csharp2cuda_temp_329 = mathblocks_minimum(selected, candidate);
                                                }
                                                (*(csharp2cuda_temp_328) = csharp2cuda_temp_329);
                                            }
#line 423 "TransportModule.cs"
                                            int* csharp2cuda_temp_322 = &(inner);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_322));
                                        }
                                    }
#line 432 "TransportModule.cs"
#line 432 "TransportModule.cs"
                                    int csharp2cuda_temp_330 = (second)->columns;
#line 432 "TransportModule.cs"
                                    double* csharp2cuda_temp_331 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_330), column)]);
                                    (*(csharp2cuda_temp_331) = selected);
                                }
#line 418 "TransportModule.cs"
                                int* csharp2cuda_temp_319 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_319));
                            }
                        }
#line 417 "TransportModule.cs"
                        int* csharp2cuda_temp_317 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_317));
                    }
                }
#line 434 "TransportModule.cs"
                break;
        }
#line 437 "TransportModule.cs"
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_332 = (output)->valid;
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_333;
#line 437 "TransportModule.cs"
        if (csharp2cuda_temp_332)
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_333 = ((opcode) != (3));
        }
        else
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_333 = false;
        }
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_334;
#line 437 "TransportModule.cs"
        if (csharp2cuda_temp_333)
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_334 = ((opcode) != (4));
        }
        else
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_334 = false;
        }
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_335;
#line 437 "TransportModule.cs"
        if (csharp2cuda_temp_334)
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_335 = ((opcode) != (6));
        }
        else
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_335 = false;
        }
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_336;
#line 437 "TransportModule.cs"
        if (csharp2cuda_temp_335)
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_336 = ((opcode) != (9));
        }
        else
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_336 = false;
        }
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_337;
#line 437 "TransportModule.cs"
        if (csharp2cuda_temp_336)
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_337 = ((opcode) != (10));
        }
        else
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_337 = false;
        }
#line 437 "TransportModule.cs"
        bool csharp2cuda_temp_338;
#line 437 "TransportModule.cs"
        if (csharp2cuda_temp_337)
        {
#line 439 "TransportModule.cs"
            double csharp2cuda_temp_339 = (output)->scalar_value;
#line 437 "TransportModule.cs"
            csharp2cuda_temp_338 = (!(isfinite(csharp2cuda_temp_339)));
        }
        else
        {
#line 437 "TransportModule.cs"
            csharp2cuda_temp_338 = false;
        }
        if (csharp2cuda_temp_338)
#line 440 "TransportModule.cs"
        {
#line 441 "TransportModule.cs"
#line 441 "TransportModule.cs"
            int* csharp2cuda_temp_340 = &((output)->valid);
            (*(csharp2cuda_temp_340) = 0);
        }
#line 443 "TransportModule.cs"
#line 443 "TransportModule.cs"
        bool csharp2cuda_temp_341 = (output)->valid;
#line 443 "TransportModule.cs"
        bool csharp2cuda_temp_342;
#line 443 "TransportModule.cs"
        if (csharp2cuda_temp_341)
        {
#line 443 "TransportModule.cs"
            bool csharp2cuda_temp_343;
#line 443 "TransportModule.cs"
            if (!(((opcode) == (3))))
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_343 = ((opcode) == (4));
            }
            else
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_343 = true;
            }
#line 443 "TransportModule.cs"
            bool csharp2cuda_temp_344;
#line 443 "TransportModule.cs"
            if (!(csharp2cuda_temp_343))
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_344 = ((opcode) == (6));
            }
            else
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_344 = true;
            }
#line 443 "TransportModule.cs"
            bool csharp2cuda_temp_345;
#line 443 "TransportModule.cs"
            if (!(csharp2cuda_temp_344))
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_345 = ((opcode) == (9));
            }
            else
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_345 = true;
            }
#line 443 "TransportModule.cs"
            bool csharp2cuda_temp_346;
#line 443 "TransportModule.cs"
            if (!(csharp2cuda_temp_345))
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_346 = ((opcode) == (10));
            }
            else
            {
#line 443 "TransportModule.cs"
                csharp2cuda_temp_346 = true;
            }
#line 443 "TransportModule.cs"
            csharp2cuda_temp_342 = csharp2cuda_temp_346;
        }
        else
        {
#line 443 "TransportModule.cs"
            csharp2cuda_temp_342 = false;
        }
        if (csharp2cuda_temp_342)
        {
#line 444 "TransportModule.cs"
            {
#line 444 "TransportModule.cs"
                int index = 0;
                while (true)
                {
#line 444 "TransportModule.cs"
                    int csharp2cuda_temp_348 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_348))))
                        break;
#line 445 "TransportModule.cs"
#line 445 "TransportModule.cs"
                    double csharp2cuda_temp_349 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_349))))
                    {
#line 445 "TransportModule.cs"
#line 445 "TransportModule.cs"
                        int* csharp2cuda_temp_350 = &((output)->valid);
                        (*(csharp2cuda_temp_350) = 0);
                    }
#line 444 "TransportModule.cs"
                    int* csharp2cuda_temp_347 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_347));
                }
            }
        }
    }
}

#line 64 "TransportModule.cs"
__device__ double mathblocks_transport_mean_pairwise(
    const double* left,
    int left_count,
    const double* right,
    int right_count)
#line 70 "TransportModule.cs"
{
#line 71 "TransportModule.cs"
    double sum = 0.0;
#line 72 "TransportModule.cs"
    {
#line 72 "TransportModule.cs"
        int left_index = 0;
        while (true)
        {
            if (!(((left_index) < (left_count))))
                break;
#line 73 "TransportModule.cs"
            {
#line 73 "TransportModule.cs"
                int right_index = 0;
                while (true)
                {
                    if (!(((right_index) < (right_count))))
                        break;
#line 74 "TransportModule.cs"
#line 74 "TransportModule.cs"
                    double* csharp2cuda_temp_2 = &(sum);
#line 74 "TransportModule.cs"
                    double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 74 "TransportModule.cs"
                    double csharp2cuda_temp_4 = (left)[left_index];
#line 74 "TransportModule.cs"
                    double csharp2cuda_temp_5 = (right)[right_index];
                    (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, fabs(__dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5))));
#line 73 "TransportModule.cs"
                    int* csharp2cuda_temp_1 = &(right_index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 72 "TransportModule.cs"
            int* csharp2cuda_temp_0 = &(left_index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 75 "TransportModule.cs"
    return __ddiv_rn(sum, ((double)(csharp2cuda_i32_mul(left_count, right_count))));
}