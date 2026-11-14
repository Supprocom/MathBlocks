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

struct MathBlockDeviceType;

#line 30 "TypeRuleUnit.cs"
struct MathBlockDeviceType
{
    int kind;
    int rows;
    int columns;
    int unit_numerator0;
    int unit_numerator1;
    int unit_numerator2;
    int unit_numerator3;
    int unit_denominator0;
    int unit_denominator1;
    int unit_denominator2;
    int unit_denominator3;
};

#line 232 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_CheckOperands_23fc675e4357bd71(
    int* row,
    int start,
    MathBlockDeviceType* inputs,
    int count,
    int mode,
    int seriesMask);

#line 140 "TypeRuleUnit.cs"
__device__ void cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(MathBlockDeviceType* value, int kind);

#line 179 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_CombineUnit_6e4d2fcd23f06e4c(
    MathBlockDeviceType* left,
    MathBlockDeviceType* right,
    int rightSign,
    int exponentNumerator,
    int exponentDenominator,
    MathBlockDeviceType* target);

#line 315 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_Composed_c47f5cbbb56e7775(
    int* row,
    int start,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask);

#line 149 "TypeRuleUnit.cs"
__device__ void cs2cuda_global_namespace_MathBlockTypeRuleModule_CopyUnit_e45f8d38f29eb6ea(MathBlockDeviceType* source, MathBlockDeviceType* target);

#line 412 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_Core_367ffc9d1aef367e(
    int* row,
    int start,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask);

#line 457 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_ElementwiseForm_ba1101e991286add(
    int* row,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 54 "TypeRuleUnit.cs"
__device__ long long cs2cuda_global_namespace_MathBlockTypeRuleModule_GreatestCommonDivisor_8904907116a5352b(long long left, long long right);

#line 210 "TypeRuleUnit.cs"
__device__ MathBlockDeviceType cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(
    MathBlockDeviceType* inputs,
    int index,
    int mode,
    int seriesMask);

#line 166 "TypeRuleUnit.cs"
__device__ bool cs2cuda_global_namespace_MathBlockTypeRuleModule_IsDimensionless_218062d4a9810326(MathBlockDeviceType* value);

#line 430 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_LiftResult_bbd399c38824e4e5(
    MathBlockDeviceType* inputs,
    MathBlockDeviceType* sourceResult,
    int validity,
    int fillIndex,
    int rows,
    MathBlockDeviceType* output);

#line 269 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_MergeShape_465b8917d10391b0(
    MathBlockDeviceType* inputs,
    int checkMask,
    int outputMask,
    int mode,
    int seriesMask,
    int count,
    MathBlockDeviceType* output);

#line 552 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_ResolveStatus_cee4bdaf27ba1fb5(
    int* signature_row,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 122 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnitChecked_fa7acb8e9bbc530a(MathBlockDeviceType* value, int dimension, long long numerator, long long denominator);

#line 97 "TypeRuleUnit.cs"
__device__ void cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnit_9260a5921a632c79(MathBlockDeviceType* value, int dimension, int numerator, int denominator);

#line 86 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(MathBlockDeviceType* value, int dimension);

#line 75 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(MathBlockDeviceType* value, int dimension);

#line 155 "TypeRuleUnit.cs"
__device__ bool cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitsEqual_61fd1d4392d22a54(MathBlockDeviceType* left, MathBlockDeviceType* right);

#line 500 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_WindowForm_697d38b0e4d94f7f(
    int* row,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 10 "TypeRuleDeviceUnit.cs"
__device__ void mathblocks_type_resolve(
    const int* signature_row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 232 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_CheckOperands_23fc675e4357bd71(
    int* row,
    int start,
    MathBlockDeviceType* inputs,
    int count,
    int mode,
    int seriesMask)
#line 239 "TypeRuleUnit.cs"
{
#line 240 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[csharp2cuda_i32_add(start, 1)];
#line 240 "TypeRuleUnit.cs"
    int operandStart = csharp2cuda_i32_add(csharp2cuda_i32_add(start, 2), csharp2cuda_temp_0);
#line 241 "TypeRuleUnit.cs"
#line 241 "TypeRuleUnit.cs"
    int csharp2cuda_temp_1 = (row)[operandStart];
    if (((csharp2cuda_temp_1) != (count)))
    {
#line 242 "TypeRuleUnit.cs"
        return 1;
    }
#line 243 "TypeRuleUnit.cs"
    {
#line 243 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 244 "TypeRuleUnit.cs"
            {
#line 245 "TypeRuleUnit.cs"
                MathBlockDeviceType input = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, index, mode, seriesMask);
#line 246 "TypeRuleUnit.cs"
                int kind = (input).kind;
#line 247 "TypeRuleUnit.cs"
                int mask = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(operandStart, 1), csharp2cuda_i32_mul(index, 3))];
#line 248 "TypeRuleUnit.cs"
                int constraint = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(operandStart, 2), csharp2cuda_i32_mul(index, 3))];
#line 249 "TypeRuleUnit.cs"
#line 249 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_3;
#line 249 "TypeRuleUnit.cs"
                if (!(((kind) < (1))))
                {
#line 249 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = ((kind) > (31));
                }
                else
                {
#line 249 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = true;
                }
#line 249 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_4;
#line 249 "TypeRuleUnit.cs"
                if (!(csharp2cuda_temp_3))
                {
#line 249 "TypeRuleUnit.cs"
                    csharp2cuda_temp_4 = ((csharp2cuda_i32_and(csharp2cuda_i32_shr(mask, kind), 1)) == (0));
                }
                else
                {
#line 249 "TypeRuleUnit.cs"
                    csharp2cuda_temp_4 = true;
                }
                if (csharp2cuda_temp_4)
                {
#line 250 "TypeRuleUnit.cs"
                    return 2;
                }
#line 251 "TypeRuleUnit.cs"
                if (((constraint) == (csharp2cuda_i32_neg(2))))
#line 252 "TypeRuleUnit.cs"
                {
#line 253 "TypeRuleUnit.cs"
#line 253 "TypeRuleUnit.cs"
                    MathBlockDeviceType* csharp2cuda_temp_5 = &(input);
#line 253 "TypeRuleUnit.cs"
                    bool csharp2cuda_temp_6 = cs2cuda_global_namespace_MathBlockTypeRuleModule_IsDimensionless_218062d4a9810326(csharp2cuda_temp_5);
                    if ((!(csharp2cuda_temp_6)))
                    {
#line 254 "TypeRuleUnit.cs"
                        return 3;
                    }
                }
                else
                {
#line 256 "TypeRuleUnit.cs"
                    if (((constraint) >= (0)))
#line 257 "TypeRuleUnit.cs"
                    {
#line 258 "TypeRuleUnit.cs"
                        MathBlockDeviceType other = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, constraint, mode, seriesMask);
#line 259 "TypeRuleUnit.cs"
#line 259 "TypeRuleUnit.cs"
                        MathBlockDeviceType* csharp2cuda_temp_7 = &(input);
#line 259 "TypeRuleUnit.cs"
                        MathBlockDeviceType* csharp2cuda_temp_8 = &(other);
#line 259 "TypeRuleUnit.cs"
                        bool csharp2cuda_temp_9 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitsEqual_61fd1d4392d22a54(csharp2cuda_temp_7, csharp2cuda_temp_8);
                        if ((!(csharp2cuda_temp_9)))
                        {
#line 260 "TypeRuleUnit.cs"
                            return 4;
                        }
                    }
                }
            }
#line 243 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 263 "TypeRuleUnit.cs"
    return 0;
}

#line 140 "TypeRuleUnit.cs"
__device__ void cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(MathBlockDeviceType* value, int kind)
#line 141 "TypeRuleUnit.cs"
{
#line 142 "TypeRuleUnit.cs"
#line 142 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_0 = &((value)->kind);
    (*(csharp2cuda_temp_0) = kind);
#line 143 "TypeRuleUnit.cs"
#line 143 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_1 = &((value)->rows);
    (*(csharp2cuda_temp_1) = 0);
#line 144 "TypeRuleUnit.cs"
#line 144 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_2 = &((value)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 145 "TypeRuleUnit.cs"
    {
#line 145 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 146 "TypeRuleUnit.cs"
            cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnit_9260a5921a632c79(value, dimension, 0, 1);
#line 145 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_3 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
}

#line 179 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_CombineUnit_6e4d2fcd23f06e4c(
    MathBlockDeviceType* left,
    MathBlockDeviceType* right,
    int rightSign,
    int exponentNumerator,
    int exponentDenominator,
    MathBlockDeviceType* target)
#line 186 "TypeRuleUnit.cs"
{
#line 187 "TypeRuleUnit.cs"
    {
#line 187 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 188 "TypeRuleUnit.cs"
            {
#line 189 "TypeRuleUnit.cs"
                int csharp2cuda_temp_1 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(left, dimension);
#line 189 "TypeRuleUnit.cs"
                long long numerator = ((long long)(csharp2cuda_temp_1));
#line 190 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(left, dimension);
#line 190 "TypeRuleUnit.cs"
                long long denominator = ((long long)(csharp2cuda_temp_2));
#line 191 "TypeRuleUnit.cs"
                if (((((void*)(right))) != (((void*)(nullptr)))))
#line 192 "TypeRuleUnit.cs"
                {
#line 193 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_3 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(right, dimension);
#line 193 "TypeRuleUnit.cs"
                    long long rightNumerator = ((long long)(csharp2cuda_temp_3));
#line 194 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_4 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(right, dimension);
#line 194 "TypeRuleUnit.cs"
                    long long rightDenominator = ((long long)(csharp2cuda_temp_4));
#line 195 "TypeRuleUnit.cs"
                    long long sum = csharp2cuda_i64_add(csharp2cuda_i64_mul(numerator, rightDenominator), csharp2cuda_i64_mul(csharp2cuda_i64_mul(((long long)(rightSign)), rightNumerator), denominator));
#line 196 "TypeRuleUnit.cs"
                    long long product = csharp2cuda_i64_mul(denominator, rightDenominator);
#line 197 "TypeRuleUnit.cs"
#line 197 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_5 = cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnitChecked_fa7acb8e9bbc530a(target, dimension, sum, product);
                    if (((csharp2cuda_temp_5) == (0)))
                    {
#line 198 "TypeRuleUnit.cs"
                        return 0;
                    }
#line 199 "TypeRuleUnit.cs"
#line 199 "TypeRuleUnit.cs"
                    long long* csharp2cuda_temp_6 = &(numerator);
#line 199 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_7 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(target, dimension);
                    (*(csharp2cuda_temp_6) = ((long long)(csharp2cuda_temp_7)));
#line 200 "TypeRuleUnit.cs"
#line 200 "TypeRuleUnit.cs"
                    long long* csharp2cuda_temp_8 = &(denominator);
#line 200 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_9 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(target, dimension);
                    (*(csharp2cuda_temp_8) = ((long long)(csharp2cuda_temp_9)));
                }
#line 202 "TypeRuleUnit.cs"
#line 202 "TypeRuleUnit.cs"
                int csharp2cuda_temp_10 = cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnitChecked_fa7acb8e9bbc530a(target, dimension, csharp2cuda_i64_mul(numerator, ((long long)(exponentNumerator))), csharp2cuda_i64_mul(denominator, ((long long)(exponentDenominator))));
                if (((csharp2cuda_temp_10) == (0)))
                {
#line 203 "TypeRuleUnit.cs"
                    return 0;
                }
            }
#line 187 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 205 "TypeRuleUnit.cs"
    return 1;
}

#line 315 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_Composed_c47f5cbbb56e7775(
    int* row,
    int start,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask)
#line 323 "TypeRuleUnit.cs"
{
#line 324 "TypeRuleUnit.cs"
    int p = csharp2cuda_i32_add(start, 2);
#line 325 "TypeRuleUnit.cs"
    int outputKind = (row)[csharp2cuda_i32_add(p, 0)];
#line 326 "TypeRuleUnit.cs"
    if (((outputKind) <= (0)))
    {
#line 327 "TypeRuleUnit.cs"
#line 327 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &(outputKind);
#line 327 "TypeRuleUnit.cs"
        MathBlockDeviceType csharp2cuda_temp_1 = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, csharp2cuda_i32_neg(outputKind), mode, seriesMask);
#line 327 "TypeRuleUnit.cs"
        int csharp2cuda_temp_2 = (csharp2cuda_temp_1).kind;
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_2);
    }
#line 328 "TypeRuleUnit.cs"
    cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(output, outputKind);
#line 330 "TypeRuleUnit.cs"
    int shapeMode = (row)[csharp2cuda_i32_add(p, 1)];
#line 331 "TypeRuleUnit.cs"
#line 331 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_3;
#line 331 "TypeRuleUnit.cs"
    if (!(((shapeMode) == (2))))
    {
#line 331 "TypeRuleUnit.cs"
        csharp2cuda_temp_3 = ((shapeMode) == (4));
    }
    else
    {
#line 331 "TypeRuleUnit.cs"
        csharp2cuda_temp_3 = true;
    }
#line 331 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_4;
#line 331 "TypeRuleUnit.cs"
    if (!(csharp2cuda_temp_3))
    {
#line 331 "TypeRuleUnit.cs"
        csharp2cuda_temp_4 = ((shapeMode) == (7));
    }
    else
    {
#line 331 "TypeRuleUnit.cs"
        csharp2cuda_temp_4 = true;
    }
    if (csharp2cuda_temp_4)
#line 332 "TypeRuleUnit.cs"
    {
#line 333 "TypeRuleUnit.cs"
        int csharp2cuda_temp_5 = (row)[csharp2cuda_i32_add(p, 2)];
#line 333 "TypeRuleUnit.cs"
        int csharp2cuda_temp_6 = (row)[csharp2cuda_i32_add(p, 3)];
#line 333 "TypeRuleUnit.cs"
        int merged = cs2cuda_global_namespace_MathBlockTypeRuleModule_MergeShape_465b8917d10391b0(inputs, csharp2cuda_temp_5, csharp2cuda_temp_6, mode, seriesMask, count, output);
#line 334 "TypeRuleUnit.cs"
        if (((merged) != (0)))
        {
#line 335 "TypeRuleUnit.cs"
            return merged;
        }
#line 336 "TypeRuleUnit.cs"
        if (((shapeMode) == (4)))
        {
#line 337 "TypeRuleUnit.cs"
#line 337 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_7 = &((output)->columns);
            (*(csharp2cuda_temp_7) = 0);
        }
        else
        {
#line 338 "TypeRuleUnit.cs"
            if (((shapeMode) == (7)))
            {
#line 339 "TypeRuleUnit.cs"
#line 339 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_8 = &((output)->rows);
                (*(csharp2cuda_temp_8) = 0);
            }
        }
#line 340 "TypeRuleUnit.cs"
        if (((shapeMode) == (7)))
        {
#line 341 "TypeRuleUnit.cs"
#line 341 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_9 = &((output)->columns);
            (*(csharp2cuda_temp_9) = 0);
        }
    }
    else
    {
#line 343 "TypeRuleUnit.cs"
        if (((shapeMode) >= (1)))
#line 344 "TypeRuleUnit.cs"
        {
#line 345 "TypeRuleUnit.cs"
            int csharp2cuda_temp_10 = (row)[csharp2cuda_i32_add(p, 2)];
#line 345 "TypeRuleUnit.cs"
            MathBlockDeviceType shapeA = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, csharp2cuda_temp_10, mode, seriesMask);
#line 346 "TypeRuleUnit.cs"
            if (((shapeMode) == (1)))
#line 347 "TypeRuleUnit.cs"
            {
#line 348 "TypeRuleUnit.cs"
#line 348 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_11 = &((output)->rows);
#line 348 "TypeRuleUnit.cs"
                int csharp2cuda_temp_12 = (shapeA).rows;
                (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 349 "TypeRuleUnit.cs"
#line 349 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_13 = &((output)->columns);
#line 349 "TypeRuleUnit.cs"
                int csharp2cuda_temp_14 = (shapeA).columns;
                (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
            }
            else
            {
#line 351 "TypeRuleUnit.cs"
                if (((shapeMode) == (3)))
#line 352 "TypeRuleUnit.cs"
                {
#line 353 "TypeRuleUnit.cs"
#line 353 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_15 = &((output)->rows);
#line 353 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_16 = (shapeA).rows;
                    (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
                }
                else
                {
#line 355 "TypeRuleUnit.cs"
                    if (((shapeMode) == (5)))
#line 356 "TypeRuleUnit.cs"
                    {
#line 357 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_17 = (row)[csharp2cuda_i32_add(p, 3)];
#line 357 "TypeRuleUnit.cs"
                        MathBlockDeviceType shapeB = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, csharp2cuda_temp_17, mode, seriesMask);
#line 358 "TypeRuleUnit.cs"
#line 358 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_18 = (shapeA).rows;
#line 358 "TypeRuleUnit.cs"
                        bool csharp2cuda_temp_19;
#line 358 "TypeRuleUnit.cs"
                        if (((csharp2cuda_temp_18) > (0)))
                        {
#line 358 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_20 = (shapeB).rows;
#line 358 "TypeRuleUnit.cs"
                            csharp2cuda_temp_19 = ((csharp2cuda_temp_20) > (0));
                        }
                        else
                        {
#line 358 "TypeRuleUnit.cs"
                            csharp2cuda_temp_19 = false;
                        }
                        if (csharp2cuda_temp_19)
#line 359 "TypeRuleUnit.cs"
                        {
#line 360 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_21 = (shapeA).rows;
#line 360 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_22 = (shapeB).rows;
#line 360 "TypeRuleUnit.cs"
                            long long total = csharp2cuda_i64_add(((long long)(csharp2cuda_temp_21)), ((long long)(csharp2cuda_temp_22)));
#line 361 "TypeRuleUnit.cs"
                            if (((total) > (2147483647LL)))
                            {
#line 362 "TypeRuleUnit.cs"
                                return 6;
                            }
#line 363 "TypeRuleUnit.cs"
#line 363 "TypeRuleUnit.cs"
                            int* csharp2cuda_temp_23 = &((output)->rows);
                            (*(csharp2cuda_temp_23) = csharp2cuda_i32_from_bits(total));
                        }
                    }
                    else
                    {
#line 366 "TypeRuleUnit.cs"
                        if (((shapeMode) == (6)))
#line 367 "TypeRuleUnit.cs"
                        {
#line 368 "TypeRuleUnit.cs"
#line 368 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_24 = (shapeA).rows;
                            if (((csharp2cuda_temp_24) > (0)))
#line 369 "TypeRuleUnit.cs"
                            {
#line 370 "TypeRuleUnit.cs"
                                int csharp2cuda_temp_25 = (shapeA).rows;
#line 370 "TypeRuleUnit.cs"
                                int csharp2cuda_temp_26 = (row)[csharp2cuda_i32_add(p, 3)];
#line 370 "TypeRuleUnit.cs"
                                long long total = csharp2cuda_i64_add(((long long)(csharp2cuda_temp_25)), ((long long)(csharp2cuda_temp_26)));
#line 371 "TypeRuleUnit.cs"
                                if (((total) > (2147483647LL)))
                                {
#line 372 "TypeRuleUnit.cs"
                                    return 6;
                                }
#line 373 "TypeRuleUnit.cs"
#line 373 "TypeRuleUnit.cs"
                                int* csharp2cuda_temp_27 = &((output)->rows);
                                (*(csharp2cuda_temp_27) = csharp2cuda_i32_from_bits(total));
                            }
                        }
                        else
                        {
#line 376 "TypeRuleUnit.cs"
                            if (((shapeMode) == (9)))
#line 377 "TypeRuleUnit.cs"
                            {
#line 378 "TypeRuleUnit.cs"
#line 378 "TypeRuleUnit.cs"
                                int csharp2cuda_temp_28 = (shapeA).rows;
                                if (((csharp2cuda_temp_28) > (0)))
                                {
#line 379 "TypeRuleUnit.cs"
#line 379 "TypeRuleUnit.cs"
                                    int* csharp2cuda_temp_29 = &((output)->rows);
#line 379 "TypeRuleUnit.cs"
                                    int csharp2cuda_temp_30 = (shapeA).rows;
#line 379 "TypeRuleUnit.cs"
                                    int csharp2cuda_temp_31 = (row)[csharp2cuda_i32_add(p, 3)];
                                    (*(csharp2cuda_temp_29) = csharp2cuda_i32_from_bits(csharp2cuda_i64_add(((long long)(csharp2cuda_temp_30)), ((long long)(csharp2cuda_temp_31)))));
                                }
                            }
                            else
                            {
#line 381 "TypeRuleUnit.cs"
                                if (((shapeMode) == (8)))
#line 382 "TypeRuleUnit.cs"
                                {
#line 383 "TypeRuleUnit.cs"
#line 383 "TypeRuleUnit.cs"
                                    int* csharp2cuda_temp_32 = &((output)->rows);
                                    (*(csharp2cuda_temp_32) = 1);
#line 384 "TypeRuleUnit.cs"
#line 384 "TypeRuleUnit.cs"
                                    int csharp2cuda_temp_33 = (shapeA).rows;
                                    if (((csharp2cuda_temp_33) > (1)))
                                    {
#line 385 "TypeRuleUnit.cs"
#line 385 "TypeRuleUnit.cs"
                                        int* csharp2cuda_temp_34 = &((output)->rows);
#line 385 "TypeRuleUnit.cs"
                                        int csharp2cuda_temp_35 = (shapeA).rows;
                                        (*(csharp2cuda_temp_34) = csharp2cuda_i32_sub(csharp2cuda_temp_35, 1));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
#line 389 "TypeRuleUnit.cs"
    int unitMode = (row)[csharp2cuda_i32_add(p, 4)];
#line 390 "TypeRuleUnit.cs"
    if (((unitMode) == (0)))
    {
#line 391 "TypeRuleUnit.cs"
        return 0;
    }
#line 392 "TypeRuleUnit.cs"
    int csharp2cuda_temp_36 = (row)[csharp2cuda_i32_add(p, 5)];
#line 392 "TypeRuleUnit.cs"
    MathBlockDeviceType unitA = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, csharp2cuda_temp_36, mode, seriesMask);
#line 393 "TypeRuleUnit.cs"
    MathBlockDeviceType unitB;
#line 394 "TypeRuleUnit.cs"
#line 394 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_37 = &(unitB);
    cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(csharp2cuda_temp_37, 0);
#line 395 "TypeRuleUnit.cs"
    if (((unitMode) >= (3)))
    {
#line 396 "TypeRuleUnit.cs"
#line 396 "TypeRuleUnit.cs"
        MathBlockDeviceType* csharp2cuda_temp_38 = &(unitB);
#line 396 "TypeRuleUnit.cs"
        int csharp2cuda_temp_39 = (row)[csharp2cuda_i32_add(p, 6)];
#line 396 "TypeRuleUnit.cs"
        MathBlockDeviceType csharp2cuda_temp_40 = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, csharp2cuda_temp_39, mode, seriesMask);
        (*(csharp2cuda_temp_38) = csharp2cuda_temp_40);
    }
#line 397 "TypeRuleUnit.cs"
    int combined = 1;
#line 398 "TypeRuleUnit.cs"
    if (((unitMode) == (1)))
    {
#line 399 "TypeRuleUnit.cs"
#line 399 "TypeRuleUnit.cs"
        MathBlockDeviceType* csharp2cuda_temp_41 = &(unitA);
        cs2cuda_global_namespace_MathBlockTypeRuleModule_CopyUnit_e45f8d38f29eb6ea(csharp2cuda_temp_41, output);
    }
    else
    {
#line 400 "TypeRuleUnit.cs"
        if (((unitMode) == (2)))
        {
#line 401 "TypeRuleUnit.cs"
#line 401 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_42 = &(combined);
#line 401 "TypeRuleUnit.cs"
            MathBlockDeviceType* csharp2cuda_temp_43 = &(unitA);
#line 401 "TypeRuleUnit.cs"
            int csharp2cuda_temp_44 = (row)[csharp2cuda_i32_add(p, 7)];
#line 401 "TypeRuleUnit.cs"
            int csharp2cuda_temp_45 = (row)[csharp2cuda_i32_add(p, 8)];
#line 401 "TypeRuleUnit.cs"
            int csharp2cuda_temp_46 = cs2cuda_global_namespace_MathBlockTypeRuleModule_CombineUnit_6e4d2fcd23f06e4c(csharp2cuda_temp_43, ((MathBlockDeviceType*)(nullptr)), 1, csharp2cuda_temp_44, csharp2cuda_temp_45, output);
            (*(csharp2cuda_temp_42) = csharp2cuda_temp_46);
        }
        else
        {
#line 402 "TypeRuleUnit.cs"
            if (((unitMode) == (3)))
            {
#line 403 "TypeRuleUnit.cs"
#line 403 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_47 = &(combined);
#line 403 "TypeRuleUnit.cs"
                MathBlockDeviceType* csharp2cuda_temp_48 = &(unitA);
#line 403 "TypeRuleUnit.cs"
                MathBlockDeviceType* csharp2cuda_temp_49 = &(unitB);
#line 403 "TypeRuleUnit.cs"
                int csharp2cuda_temp_50 = cs2cuda_global_namespace_MathBlockTypeRuleModule_CombineUnit_6e4d2fcd23f06e4c(csharp2cuda_temp_48, csharp2cuda_temp_49, 1, 1, 1, output);
                (*(csharp2cuda_temp_47) = csharp2cuda_temp_50);
            }
            else
            {
#line 404 "TypeRuleUnit.cs"
                if (((unitMode) == (4)))
                {
#line 405 "TypeRuleUnit.cs"
#line 405 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_51 = &(combined);
#line 405 "TypeRuleUnit.cs"
                    MathBlockDeviceType* csharp2cuda_temp_52 = &(unitA);
#line 405 "TypeRuleUnit.cs"
                    MathBlockDeviceType* csharp2cuda_temp_53 = &(unitB);
#line 405 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_54 = cs2cuda_global_namespace_MathBlockTypeRuleModule_CombineUnit_6e4d2fcd23f06e4c(csharp2cuda_temp_52, csharp2cuda_temp_53, csharp2cuda_i32_neg(1), 1, 1, output);
                    (*(csharp2cuda_temp_51) = csharp2cuda_temp_54);
                }
            }
        }
    }
#line 406 "TypeRuleUnit.cs"
    if (((combined) == (0)))
    {
#line 407 "TypeRuleUnit.cs"
        return 6;
    }
#line 408 "TypeRuleUnit.cs"
    return 0;
}

#line 149 "TypeRuleUnit.cs"
__device__ void cs2cuda_global_namespace_MathBlockTypeRuleModule_CopyUnit_e45f8d38f29eb6ea(MathBlockDeviceType* source, MathBlockDeviceType* target)
#line 150 "TypeRuleUnit.cs"
{
#line 151 "TypeRuleUnit.cs"
    {
#line 151 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 152 "TypeRuleUnit.cs"
#line 152 "TypeRuleUnit.cs"
            int csharp2cuda_temp_1 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(source, dimension);
#line 152 "TypeRuleUnit.cs"
            int csharp2cuda_temp_2 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(source, dimension);
            cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnit_9260a5921a632c79(target, dimension, csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 151 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 412 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_Core_367ffc9d1aef367e(
    int* row,
    int start,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask)
#line 420 "TypeRuleUnit.cs"
{
#line 421 "TypeRuleUnit.cs"
    int checkedOperands = cs2cuda_global_namespace_MathBlockTypeRuleModule_CheckOperands_23fc675e4357bd71(row, start, inputs, count, mode, seriesMask);
#line 422 "TypeRuleUnit.cs"
    if (((checkedOperands) != (0)))
    {
#line 423 "TypeRuleUnit.cs"
        return checkedOperands;
    }
#line 424 "TypeRuleUnit.cs"
#line 424 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[start];
    if (((csharp2cuda_temp_0) == (1)))
    {
#line 425 "TypeRuleUnit.cs"
        return cs2cuda_global_namespace_MathBlockTypeRuleModule_Composed_c47f5cbbb56e7775(row, start, inputs, count, output, mode, seriesMask);
    }
#line 426 "TypeRuleUnit.cs"
    return 7;
}

#line 457 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_ElementwiseForm_ba1101e991286add(
    int* row,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 462 "TypeRuleUnit.cs"
{
#line 463 "TypeRuleUnit.cs"
    int validity = (row)[2];
#line 464 "TypeRuleUnit.cs"
    int source = 3;
#line 465 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[csharp2cuda_i32_add(source, 1)];
#line 465 "TypeRuleUnit.cs"
    int sourceArity = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(source, 2), csharp2cuda_temp_0)];
#line 466 "TypeRuleUnit.cs"
    if (((count) != (csharp2cuda_i32_sub(csharp2cuda_i32_add(sourceArity, 1), validity))))
    {
#line 467 "TypeRuleUnit.cs"
        return 1;
    }
#line 468 "TypeRuleUnit.cs"
    int rows = 0;
#line 469 "TypeRuleUnit.cs"
    int vectors = 0;
#line 470 "TypeRuleUnit.cs"
    int consistent = 1;
#line 471 "TypeRuleUnit.cs"
    {
#line 471 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (sourceArity))))
                break;
#line 472 "TypeRuleUnit.cs"
            {
#line 473 "TypeRuleUnit.cs"
#line 473 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = ((inputs)[index]).kind;
                if (((csharp2cuda_temp_2) != (4)))
                {
#line 474 "TypeRuleUnit.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 475 "TypeRuleUnit.cs"
#line 475 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_3 = &(vectors);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
#line 476 "TypeRuleUnit.cs"
                int length = ((inputs)[index]).rows;
#line 477 "TypeRuleUnit.cs"
                if (((length) > (0)))
#line 478 "TypeRuleUnit.cs"
                {
#line 479 "TypeRuleUnit.cs"
                    if (((rows) == (0)))
                    {
#line 480 "TypeRuleUnit.cs"
#line 480 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_4 = &(rows);
                        (*(csharp2cuda_temp_4) = length);
                    }
                    else
                    {
#line 481 "TypeRuleUnit.cs"
                        if (((rows) != (length)))
                        {
#line 482 "TypeRuleUnit.cs"
#line 482 "TypeRuleUnit.cs"
                            int* csharp2cuda_temp_5 = &(consistent);
                            (*(csharp2cuda_temp_5) = 0);
                        }
                    }
                }
            }
            csharp2cuda_for_continue_0:
#line 471 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 485 "TypeRuleUnit.cs"
    if (((vectors) == (0)))
    {
#line 486 "TypeRuleUnit.cs"
        return 7;
    }
#line 487 "TypeRuleUnit.cs"
    if (((consistent) == (0)))
    {
#line 488 "TypeRuleUnit.cs"
#line 488 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_6 = &(rows);
        (*(csharp2cuda_temp_6) = 0);
    }
#line 489 "TypeRuleUnit.cs"
    MathBlockDeviceType result;
#line 490 "TypeRuleUnit.cs"
#line 490 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_7 = &(result);
    cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(csharp2cuda_temp_7, 0);
#line 491 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_8 = &(result);
#line 491 "TypeRuleUnit.cs"
    int status = cs2cuda_global_namespace_MathBlockTypeRuleModule_Core_367ffc9d1aef367e(row, source, inputs, sourceArity, csharp2cuda_temp_8, 1, 0);
#line 492 "TypeRuleUnit.cs"
    if (((status) != (0)))
    {
#line 493 "TypeRuleUnit.cs"
        return status;
    }
#line 494 "TypeRuleUnit.cs"
#line 494 "TypeRuleUnit.cs"
    int csharp2cuda_temp_9 = (result).kind;
    if (((csharp2cuda_temp_9) != (1)))
    {
#line 495 "TypeRuleUnit.cs"
        return 2;
    }
#line 496 "TypeRuleUnit.cs"
#line 496 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_10 = &(result);
    return cs2cuda_global_namespace_MathBlockTypeRuleModule_LiftResult_bbd399c38824e4e5(inputs, csharp2cuda_temp_10, validity, sourceArity, rows, output);
}

#line 54 "TypeRuleUnit.cs"
__device__ long long cs2cuda_global_namespace_MathBlockTypeRuleModule_GreatestCommonDivisor_8904907116a5352b(long long left, long long right)
#line 55 "TypeRuleUnit.cs"
{
#line 56 "TypeRuleUnit.cs"
    if (((left) < (((long long)(0)))))
    {
#line 57 "TypeRuleUnit.cs"
#line 57 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_0 = &(left);
        (*(csharp2cuda_temp_0) = csharp2cuda_i64_neg(left));
    }
#line 58 "TypeRuleUnit.cs"
    if (((right) < (((long long)(0)))))
    {
#line 59 "TypeRuleUnit.cs"
#line 59 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_1 = &(right);
        (*(csharp2cuda_temp_1) = csharp2cuda_i64_neg(right));
    }
#line 60 "TypeRuleUnit.cs"
    if (((left) == (((long long)(0)))))
#line 61 "TypeRuleUnit.cs"
    {
#line 62 "TypeRuleUnit.cs"
        if (((right) == (((long long)(0)))))
        {
#line 63 "TypeRuleUnit.cs"
            return ((long long)(1));
        }
#line 64 "TypeRuleUnit.cs"
        return right;
    }
#line 66 "TypeRuleUnit.cs"
    while (true)
    {
        if (!(((right) != (((long long)(0))))))
            break;
#line 67 "TypeRuleUnit.cs"
        {
#line 68 "TypeRuleUnit.cs"
            long long next = csharp2cuda_i64_rem(left, right);
#line 69 "TypeRuleUnit.cs"
#line 69 "TypeRuleUnit.cs"
            long long* csharp2cuda_temp_2 = &(left);
            (*(csharp2cuda_temp_2) = right);
#line 70 "TypeRuleUnit.cs"
#line 70 "TypeRuleUnit.cs"
            long long* csharp2cuda_temp_3 = &(right);
            (*(csharp2cuda_temp_3) = next);
        }
    }
#line 72 "TypeRuleUnit.cs"
    return left;
}

#line 210 "TypeRuleUnit.cs"
__device__ MathBlockDeviceType cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(
    MathBlockDeviceType* inputs,
    int index,
    int mode,
    int seriesMask)
#line 215 "TypeRuleUnit.cs"
{
#line 216 "TypeRuleUnit.cs"
    MathBlockDeviceType value = (inputs)[index];
#line 217 "TypeRuleUnit.cs"
#line 217 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_0;
#line 217 "TypeRuleUnit.cs"
    if (((mode) == (1)))
    {
#line 217 "TypeRuleUnit.cs"
        int csharp2cuda_temp_1 = (value).kind;
#line 217 "TypeRuleUnit.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_1) == (4));
    }
    else
    {
#line 217 "TypeRuleUnit.cs"
        csharp2cuda_temp_0 = false;
    }
    if (csharp2cuda_temp_0)
#line 218 "TypeRuleUnit.cs"
    {
#line 219 "TypeRuleUnit.cs"
#line 219 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_2 = &((value).kind);
        (*(csharp2cuda_temp_2) = 1);
#line 220 "TypeRuleUnit.cs"
#line 220 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_3 = &((value).rows);
        (*(csharp2cuda_temp_3) = 0);
#line 221 "TypeRuleUnit.cs"
#line 221 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_4 = &((value).columns);
        (*(csharp2cuda_temp_4) = 0);
    }
    else
    {
#line 223 "TypeRuleUnit.cs"
#line 223 "TypeRuleUnit.cs"
        bool csharp2cuda_temp_5;
#line 223 "TypeRuleUnit.cs"
        if (((mode) == (2)))
        {
#line 223 "TypeRuleUnit.cs"
            csharp2cuda_temp_5 = ((csharp2cuda_i32_and(csharp2cuda_i32_shr(seriesMask, index), 1)) != (0));
        }
        else
        {
#line 223 "TypeRuleUnit.cs"
            csharp2cuda_temp_5 = false;
        }
        if (csharp2cuda_temp_5)
#line 224 "TypeRuleUnit.cs"
        {
#line 225 "TypeRuleUnit.cs"
#line 225 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_6 = &((value).rows);
            (*(csharp2cuda_temp_6) = 0);
#line 226 "TypeRuleUnit.cs"
#line 226 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_7 = &((value).columns);
            (*(csharp2cuda_temp_7) = 0);
        }
    }
#line 228 "TypeRuleUnit.cs"
    return value;
}

#line 166 "TypeRuleUnit.cs"
__device__ bool cs2cuda_global_namespace_MathBlockTypeRuleModule_IsDimensionless_218062d4a9810326(MathBlockDeviceType* value)
#line 167 "TypeRuleUnit.cs"
{
#line 168 "TypeRuleUnit.cs"
    {
#line 168 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 169 "TypeRuleUnit.cs"
            {
#line 170 "TypeRuleUnit.cs"
#line 170 "TypeRuleUnit.cs"
                int csharp2cuda_temp_1 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(value, dimension);
                if (((csharp2cuda_temp_1) != (0)))
                {
#line 171 "TypeRuleUnit.cs"
                    return false;
                }
            }
#line 168 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 173 "TypeRuleUnit.cs"
    return true;
}

#line 430 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_LiftResult_bbd399c38824e4e5(
    MathBlockDeviceType* inputs,
    MathBlockDeviceType* sourceResult,
    int validity,
    int fillIndex,
    int rows,
    MathBlockDeviceType* output)
#line 437 "TypeRuleUnit.cs"
{
#line 438 "TypeRuleUnit.cs"
    if (((validity) != (0)))
#line 439 "TypeRuleUnit.cs"
    {
#line 440 "TypeRuleUnit.cs"
        cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(output, 11);
#line 441 "TypeRuleUnit.cs"
#line 441 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &((output)->rows);
        (*(csharp2cuda_temp_0) = rows);
#line 442 "TypeRuleUnit.cs"
        return 0;
    }
#line 444 "TypeRuleUnit.cs"
    MathBlockDeviceType fill = (inputs)[fillIndex];
#line 445 "TypeRuleUnit.cs"
#line 445 "TypeRuleUnit.cs"
    int csharp2cuda_temp_1 = (fill).kind;
    if (((csharp2cuda_temp_1) != (1)))
    {
#line 446 "TypeRuleUnit.cs"
        return 2;
    }
#line 447 "TypeRuleUnit.cs"
#line 447 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_2 = &(fill);
#line 447 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_3 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitsEqual_61fd1d4392d22a54(csharp2cuda_temp_2, sourceResult);
    if ((!(csharp2cuda_temp_3)))
    {
#line 448 "TypeRuleUnit.cs"
        return 4;
    }
#line 449 "TypeRuleUnit.cs"
    cs2cuda_global_namespace_MathBlockTypeRuleModule_CopyUnit_e45f8d38f29eb6ea(sourceResult, output);
#line 450 "TypeRuleUnit.cs"
#line 450 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_4 = &((output)->kind);
    (*(csharp2cuda_temp_4) = 4);
#line 451 "TypeRuleUnit.cs"
#line 451 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_5 = &((output)->rows);
    (*(csharp2cuda_temp_5) = rows);
#line 452 "TypeRuleUnit.cs"
#line 452 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_6 = &((output)->columns);
    (*(csharp2cuda_temp_6) = 0);
#line 453 "TypeRuleUnit.cs"
    return 0;
}

#line 269 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_MergeShape_465b8917d10391b0(
    MathBlockDeviceType* inputs,
    int checkMask,
    int outputMask,
    int mode,
    int seriesMask,
    int count,
    MathBlockDeviceType* output)
#line 277 "TypeRuleUnit.cs"
{
#line 278 "TypeRuleUnit.cs"
    if (((outputMask) == (0)))
    {
#line 279 "TypeRuleUnit.cs"
#line 279 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &(outputMask);
        (*(csharp2cuda_temp_0) = checkMask);
    }
#line 280 "TypeRuleUnit.cs"
    int rows = 0;
#line 281 "TypeRuleUnit.cs"
    int columns = 0;
#line 282 "TypeRuleUnit.cs"
    int outputRows = 0;
#line 283 "TypeRuleUnit.cs"
    int outputColumns = 0;
#line 284 "TypeRuleUnit.cs"
    {
#line 284 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 285 "TypeRuleUnit.cs"
            {
#line 286 "TypeRuleUnit.cs"
                if (((csharp2cuda_i32_and(csharp2cuda_i32_shr(checkMask, index), 1)) == (0)))
                {
#line 287 "TypeRuleUnit.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 288 "TypeRuleUnit.cs"
                MathBlockDeviceType input = cs2cuda_global_namespace_MathBlockTypeRuleModule_Input_db1595f5c742dfbb(inputs, index, mode, seriesMask);
#line 289 "TypeRuleUnit.cs"
#line 289 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = (input).rows;
                if (((csharp2cuda_temp_2) != (0)))
#line 290 "TypeRuleUnit.cs"
                {
#line 291 "TypeRuleUnit.cs"
#line 291 "TypeRuleUnit.cs"
                    bool csharp2cuda_temp_3;
#line 291 "TypeRuleUnit.cs"
                    if (((rows) != (0)))
                    {
#line 291 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_4 = (input).rows;
#line 291 "TypeRuleUnit.cs"
                        csharp2cuda_temp_3 = ((rows) != (csharp2cuda_temp_4));
                    }
                    else
                    {
#line 291 "TypeRuleUnit.cs"
                        csharp2cuda_temp_3 = false;
                    }
                    if (csharp2cuda_temp_3)
                    {
#line 292 "TypeRuleUnit.cs"
                        return 5;
                    }
#line 293 "TypeRuleUnit.cs"
#line 293 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_5 = &(rows);
#line 293 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_6 = (input).rows;
                    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
                }
#line 295 "TypeRuleUnit.cs"
#line 295 "TypeRuleUnit.cs"
                int csharp2cuda_temp_7 = (input).columns;
                if (((csharp2cuda_temp_7) != (0)))
#line 296 "TypeRuleUnit.cs"
                {
#line 297 "TypeRuleUnit.cs"
#line 297 "TypeRuleUnit.cs"
                    bool csharp2cuda_temp_8;
#line 297 "TypeRuleUnit.cs"
                    if (((columns) != (0)))
                    {
#line 297 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_9 = (input).columns;
#line 297 "TypeRuleUnit.cs"
                        csharp2cuda_temp_8 = ((columns) != (csharp2cuda_temp_9));
                    }
                    else
                    {
#line 297 "TypeRuleUnit.cs"
                        csharp2cuda_temp_8 = false;
                    }
                    if (csharp2cuda_temp_8)
                    {
#line 298 "TypeRuleUnit.cs"
                        return 5;
                    }
#line 299 "TypeRuleUnit.cs"
#line 299 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_10 = &(columns);
#line 299 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_11 = (input).columns;
                    (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
                }
#line 301 "TypeRuleUnit.cs"
                if (((csharp2cuda_i32_and(csharp2cuda_i32_shr(outputMask, index), 1)) != (0)))
#line 302 "TypeRuleUnit.cs"
                {
#line 303 "TypeRuleUnit.cs"
                    if (((outputRows) == (0)))
                    {
#line 304 "TypeRuleUnit.cs"
#line 304 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_12 = &(outputRows);
#line 304 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_13 = (input).rows;
                        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
                    }
#line 305 "TypeRuleUnit.cs"
                    if (((outputColumns) == (0)))
                    {
#line 306 "TypeRuleUnit.cs"
#line 306 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_14 = &(outputColumns);
#line 306 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_15 = (input).columns;
                        (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                    }
                }
            }
            csharp2cuda_for_continue_0:
#line 284 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 309 "TypeRuleUnit.cs"
#line 309 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_16 = &((output)->rows);
    (*(csharp2cuda_temp_16) = outputRows);
#line 310 "TypeRuleUnit.cs"
#line 310 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_17 = &((output)->columns);
    (*(csharp2cuda_temp_17) = outputColumns);
#line 311 "TypeRuleUnit.cs"
    return 0;
}

#line 552 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_ResolveStatus_cee4bdaf27ba1fb5(
    int* signature_row,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 557 "TypeRuleUnit.cs"
{
#line 558 "TypeRuleUnit.cs"
    int rule = (signature_row)[0];
#line 559 "TypeRuleUnit.cs"
    int status = 7;
#line 560 "TypeRuleUnit.cs"
    if (((rule) == (2)))
    {
#line 561 "TypeRuleUnit.cs"
#line 561 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &(status);
#line 561 "TypeRuleUnit.cs"
        int csharp2cuda_temp_1 = cs2cuda_global_namespace_MathBlockTypeRuleModule_ElementwiseForm_ba1101e991286add(signature_row, inputs, count, output);
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
    }
    else
    {
#line 562 "TypeRuleUnit.cs"
        if (((rule) == (3)))
        {
#line 563 "TypeRuleUnit.cs"
#line 563 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_2 = &(status);
#line 563 "TypeRuleUnit.cs"
            int csharp2cuda_temp_3 = cs2cuda_global_namespace_MathBlockTypeRuleModule_WindowForm_697d38b0e4d94f7f(signature_row, inputs, count, output);
            (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
        }
        else
        {
#line 565 "TypeRuleUnit.cs"
#line 565 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_4 = &(status);
#line 565 "TypeRuleUnit.cs"
            int csharp2cuda_temp_5 = cs2cuda_global_namespace_MathBlockTypeRuleModule_Core_367ffc9d1aef367e(signature_row, 0, inputs, count, output, 0, 0);
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 566 "TypeRuleUnit.cs"
    if (((status) != (0)))
    {
#line 567 "TypeRuleUnit.cs"
        cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(output, csharp2cuda_i32_neg(1));
    }
#line 568 "TypeRuleUnit.cs"
    return status;
}

#line 122 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnitChecked_fa7acb8e9bbc530a(MathBlockDeviceType* value, int dimension, long long numerator, long long denominator)
#line 123 "TypeRuleUnit.cs"
{
#line 124 "TypeRuleUnit.cs"
    long long divisor = cs2cuda_global_namespace_MathBlockTypeRuleModule_GreatestCommonDivisor_8904907116a5352b(numerator, denominator);
#line 125 "TypeRuleUnit.cs"
#line 125 "TypeRuleUnit.cs"
    long long* csharp2cuda_temp_0 = &(numerator);
#line 125 "TypeRuleUnit.cs"
    long long csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
    (*(csharp2cuda_temp_0) = csharp2cuda_i64_div(csharp2cuda_temp_1, divisor));
#line 126 "TypeRuleUnit.cs"
#line 126 "TypeRuleUnit.cs"
    long long* csharp2cuda_temp_2 = &(denominator);
#line 126 "TypeRuleUnit.cs"
    long long csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
    (*(csharp2cuda_temp_2) = csharp2cuda_i64_div(csharp2cuda_temp_3, divisor));
#line 127 "TypeRuleUnit.cs"
    if (((denominator) < (((long long)(0)))))
#line 128 "TypeRuleUnit.cs"
    {
#line 129 "TypeRuleUnit.cs"
#line 129 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_4 = &(numerator);
        (*(csharp2cuda_temp_4) = csharp2cuda_i64_neg(numerator));
#line 130 "TypeRuleUnit.cs"
#line 130 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_5 = &(denominator);
        (*(csharp2cuda_temp_5) = csharp2cuda_i64_neg(denominator));
    }
#line 132 "TypeRuleUnit.cs"
#line 132 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_6;
#line 132 "TypeRuleUnit.cs"
    if (!(((numerator) < (csharp2cuda_i64_neg(2147483648LL)))))
    {
#line 132 "TypeRuleUnit.cs"
        csharp2cuda_temp_6 = ((numerator) > (2147483647LL));
    }
    else
    {
#line 132 "TypeRuleUnit.cs"
        csharp2cuda_temp_6 = true;
    }
#line 132 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_7;
#line 132 "TypeRuleUnit.cs"
    if (!(csharp2cuda_temp_6))
    {
#line 132 "TypeRuleUnit.cs"
        csharp2cuda_temp_7 = ((denominator) < (((long long)(1))));
    }
    else
    {
#line 132 "TypeRuleUnit.cs"
        csharp2cuda_temp_7 = true;
    }
#line 132 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_8;
#line 132 "TypeRuleUnit.cs"
    if (!(csharp2cuda_temp_7))
    {
#line 132 "TypeRuleUnit.cs"
        csharp2cuda_temp_8 = ((denominator) > (2147483647LL));
    }
    else
    {
#line 132 "TypeRuleUnit.cs"
        csharp2cuda_temp_8 = true;
    }
    if (csharp2cuda_temp_8)
    {
#line 133 "TypeRuleUnit.cs"
        return 0;
    }
#line 134 "TypeRuleUnit.cs"
    if (((numerator) == (((long long)(0)))))
    {
#line 135 "TypeRuleUnit.cs"
#line 135 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_9 = &(denominator);
        (*(csharp2cuda_temp_9) = ((long long)(1)));
    }
#line 136 "TypeRuleUnit.cs"
    cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnit_9260a5921a632c79(value, dimension, csharp2cuda_i32_from_bits(numerator), csharp2cuda_i32_from_bits(denominator));
#line 137 "TypeRuleUnit.cs"
    return 1;
}

#line 97 "TypeRuleUnit.cs"
__device__ void cs2cuda_global_namespace_MathBlockTypeRuleModule_SetUnit_9260a5921a632c79(MathBlockDeviceType* value, int dimension, int numerator, int denominator)
#line 98 "TypeRuleUnit.cs"
{
#line 99 "TypeRuleUnit.cs"
    if (((dimension) == (0)))
#line 100 "TypeRuleUnit.cs"
    {
#line 101 "TypeRuleUnit.cs"
#line 101 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &((value)->unit_numerator0);
        (*(csharp2cuda_temp_0) = numerator);
#line 102 "TypeRuleUnit.cs"
#line 102 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_1 = &((value)->unit_denominator0);
        (*(csharp2cuda_temp_1) = denominator);
    }
    else
    {
#line 104 "TypeRuleUnit.cs"
        if (((dimension) == (1)))
#line 105 "TypeRuleUnit.cs"
        {
#line 106 "TypeRuleUnit.cs"
#line 106 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_2 = &((value)->unit_numerator1);
            (*(csharp2cuda_temp_2) = numerator);
#line 107 "TypeRuleUnit.cs"
#line 107 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_3 = &((value)->unit_denominator1);
            (*(csharp2cuda_temp_3) = denominator);
        }
        else
        {
#line 109 "TypeRuleUnit.cs"
            if (((dimension) == (2)))
#line 110 "TypeRuleUnit.cs"
            {
#line 111 "TypeRuleUnit.cs"
#line 111 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_4 = &((value)->unit_numerator2);
                (*(csharp2cuda_temp_4) = numerator);
#line 112 "TypeRuleUnit.cs"
#line 112 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_5 = &((value)->unit_denominator2);
                (*(csharp2cuda_temp_5) = denominator);
            }
            else
#line 115 "TypeRuleUnit.cs"
            {
#line 116 "TypeRuleUnit.cs"
#line 116 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_6 = &((value)->unit_numerator3);
                (*(csharp2cuda_temp_6) = numerator);
#line 117 "TypeRuleUnit.cs"
#line 117 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_7 = &((value)->unit_denominator3);
                (*(csharp2cuda_temp_7) = denominator);
            }
        }
    }
}

#line 86 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(MathBlockDeviceType* value, int dimension)
#line 87 "TypeRuleUnit.cs"
{
#line 88 "TypeRuleUnit.cs"
    if (((dimension) == (0)))
    {
#line 89 "TypeRuleUnit.cs"
        return (value)->unit_denominator0;
    }
#line 90 "TypeRuleUnit.cs"
    if (((dimension) == (1)))
    {
#line 91 "TypeRuleUnit.cs"
        return (value)->unit_denominator1;
    }
#line 92 "TypeRuleUnit.cs"
    if (((dimension) == (2)))
    {
#line 93 "TypeRuleUnit.cs"
        return (value)->unit_denominator2;
    }
#line 94 "TypeRuleUnit.cs"
    return (value)->unit_denominator3;
}

#line 75 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(MathBlockDeviceType* value, int dimension)
#line 76 "TypeRuleUnit.cs"
{
#line 77 "TypeRuleUnit.cs"
    if (((dimension) == (0)))
    {
#line 78 "TypeRuleUnit.cs"
        return (value)->unit_numerator0;
    }
#line 79 "TypeRuleUnit.cs"
    if (((dimension) == (1)))
    {
#line 80 "TypeRuleUnit.cs"
        return (value)->unit_numerator1;
    }
#line 81 "TypeRuleUnit.cs"
    if (((dimension) == (2)))
    {
#line 82 "TypeRuleUnit.cs"
        return (value)->unit_numerator2;
    }
#line 83 "TypeRuleUnit.cs"
    return (value)->unit_numerator3;
}

#line 155 "TypeRuleUnit.cs"
__device__ bool cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitsEqual_61fd1d4392d22a54(MathBlockDeviceType* left, MathBlockDeviceType* right)
#line 156 "TypeRuleUnit.cs"
{
#line 157 "TypeRuleUnit.cs"
    {
#line 157 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 158 "TypeRuleUnit.cs"
            {
#line 159 "TypeRuleUnit.cs"
#line 159 "TypeRuleUnit.cs"
                int csharp2cuda_temp_1 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(left, dimension);
#line 159 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitNumerator_33ce368a9b11f062(right, dimension);
#line 159 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_3;
#line 159 "TypeRuleUnit.cs"
                if (!(((csharp2cuda_temp_1) != (csharp2cuda_temp_2))))
                {
#line 160 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_4 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(left, dimension);
#line 160 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_5 = cs2cuda_global_namespace_MathBlockTypeRuleModule_UnitDenominator_ebbd4adaf715b6b5(right, dimension);
#line 159 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = ((csharp2cuda_temp_4) != (csharp2cuda_temp_5));
                }
                else
                {
#line 159 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 161 "TypeRuleUnit.cs"
                    return false;
                }
            }
#line 157 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 163 "TypeRuleUnit.cs"
    return true;
}

#line 500 "TypeRuleUnit.cs"
__device__ int cs2cuda_global_namespace_MathBlockTypeRuleModule_WindowForm_697d38b0e4d94f7f(
    int* row,
    MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 505 "TypeRuleUnit.cs"
{
#line 506 "TypeRuleUnit.cs"
    int validity = (row)[2];
#line 507 "TypeRuleUnit.cs"
    int lastRow = (row)[3];
#line 508 "TypeRuleUnit.cs"
    int seriesMask = (row)[4];
#line 509 "TypeRuleUnit.cs"
    int source = 5;
#line 510 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[csharp2cuda_i32_add(source, 1)];
#line 510 "TypeRuleUnit.cs"
    int sourceArity = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(source, 2), csharp2cuda_temp_0)];
#line 511 "TypeRuleUnit.cs"
    if (((count) != (csharp2cuda_i32_sub(csharp2cuda_i32_add(sourceArity, 2), validity))))
    {
#line 512 "TypeRuleUnit.cs"
        return 1;
    }
#line 513 "TypeRuleUnit.cs"
    int rows = 0;
#line 514 "TypeRuleUnit.cs"
    int consistent = 1;
#line 515 "TypeRuleUnit.cs"
    {
#line 515 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (sourceArity))))
                break;
#line 516 "TypeRuleUnit.cs"
            {
#line 517 "TypeRuleUnit.cs"
                if (((csharp2cuda_i32_and(csharp2cuda_i32_shr(seriesMask, index), 1)) == (0)))
                {
#line 518 "TypeRuleUnit.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 519 "TypeRuleUnit.cs"
                int kind = ((inputs)[index]).kind;
#line 520 "TypeRuleUnit.cs"
#line 520 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_2;
#line 520 "TypeRuleUnit.cs"
                if (((kind) != (4)))
                {
#line 520 "TypeRuleUnit.cs"
                    csharp2cuda_temp_2 = ((kind) != (11));
                }
                else
                {
#line 520 "TypeRuleUnit.cs"
                    csharp2cuda_temp_2 = false;
                }
                if (csharp2cuda_temp_2)
                {
#line 521 "TypeRuleUnit.cs"
                    return 2;
                }
#line 522 "TypeRuleUnit.cs"
                int length = ((inputs)[index]).rows;
#line 523 "TypeRuleUnit.cs"
                if (((length) > (0)))
#line 524 "TypeRuleUnit.cs"
                {
#line 525 "TypeRuleUnit.cs"
                    if (((rows) == (0)))
                    {
#line 526 "TypeRuleUnit.cs"
#line 526 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_3 = &(rows);
                        (*(csharp2cuda_temp_3) = length);
                    }
                    else
                    {
#line 527 "TypeRuleUnit.cs"
                        if (((rows) != (length)))
                        {
#line 528 "TypeRuleUnit.cs"
#line 528 "TypeRuleUnit.cs"
                            int* csharp2cuda_temp_4 = &(consistent);
                            (*(csharp2cuda_temp_4) = 0);
                        }
                    }
                }
            }
            csharp2cuda_for_continue_0:
#line 515 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 531 "TypeRuleUnit.cs"
    if (((consistent) == (0)))
    {
#line 532 "TypeRuleUnit.cs"
#line 532 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_5 = &(rows);
        (*(csharp2cuda_temp_5) = 0);
    }
#line 533 "TypeRuleUnit.cs"
    MathBlockDeviceType result;
#line 534 "TypeRuleUnit.cs"
#line 534 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_6 = &(result);
    cs2cuda_global_namespace_MathBlockTypeRuleModule_Clear_b4f1dffbb6be6302(csharp2cuda_temp_6, 0);
#line 535 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_7 = &(result);
#line 535 "TypeRuleUnit.cs"
    int status = cs2cuda_global_namespace_MathBlockTypeRuleModule_Core_367ffc9d1aef367e(row, source, inputs, sourceArity, csharp2cuda_temp_7, 2, seriesMask);
#line 536 "TypeRuleUnit.cs"
    if (((status) != (0)))
    {
#line 537 "TypeRuleUnit.cs"
        return status;
    }
#line 538 "TypeRuleUnit.cs"
    int expectedKind = 1;
#line 539 "TypeRuleUnit.cs"
    if (((lastRow) != (0)))
    {
#line 540 "TypeRuleUnit.cs"
#line 540 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_8 = &(expectedKind);
        (*(csharp2cuda_temp_8) = 4);
    }
#line 541 "TypeRuleUnit.cs"
#line 541 "TypeRuleUnit.cs"
    int csharp2cuda_temp_9 = (result).kind;
    if (((csharp2cuda_temp_9) != (expectedKind)))
    {
#line 542 "TypeRuleUnit.cs"
        return 2;
    }
#line 543 "TypeRuleUnit.cs"
    MathBlockDeviceType width = (inputs)[sourceArity];
#line 544 "TypeRuleUnit.cs"
#line 544 "TypeRuleUnit.cs"
    int csharp2cuda_temp_10 = (width).kind;
    if (((csharp2cuda_temp_10) != (1)))
    {
#line 545 "TypeRuleUnit.cs"
        return 2;
    }
#line 546 "TypeRuleUnit.cs"
#line 546 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_11 = &(width);
#line 546 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_12 = cs2cuda_global_namespace_MathBlockTypeRuleModule_IsDimensionless_218062d4a9810326(csharp2cuda_temp_11);
    if ((!(csharp2cuda_temp_12)))
    {
#line 547 "TypeRuleUnit.cs"
        return 3;
    }
#line 548 "TypeRuleUnit.cs"
#line 548 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_13 = &(result);
    return cs2cuda_global_namespace_MathBlockTypeRuleModule_LiftResult_bbd399c38824e4e5(inputs, csharp2cuda_temp_13, validity, csharp2cuda_i32_add(sourceArity, 1), rows, output);
}

#line 10 "TypeRuleDeviceUnit.cs"
__device__ void mathblocks_type_resolve(
    const int* signature_row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 16 "TypeRuleDeviceUnit.cs"
{
#line 19 "TypeRuleDeviceUnit.cs"
    cs2cuda_global_namespace_MathBlockTypeRuleModule_ResolveStatus_cee4bdaf27ba1fb5(((int*)(((unsigned long long)(signature_row)))), ((MathBlockDeviceType*)(((unsigned long long)(inputs)))), count, output);
}