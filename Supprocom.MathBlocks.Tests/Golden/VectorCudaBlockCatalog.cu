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

#line 105 "VectorModule.cs"
__device__ double mathblocks_compensated_absolute_sum(const double* values, int count);

#line 85 "VectorModule.cs"
__device__ double mathblocks_compensated_product_sum(
    const double* first,
    const double* second,
    int count);

#line 68 "VectorModule.cs"
__device__ double mathblocks_compensated_sum(const double* values, int count);

#line 135 "VectorModule.cs"
__device__ void mathblocks_copy_and_sort(
    const MathBlockSlot* input,
    MathBlockSlot* output);

#line 47 "VectorModule.cs"
__device__ double mathblocks_maximum(double first, double second);

#line 35 "VectorModule.cs"
__device__ double mathblocks_minimum(double first, double second);

#line 59 "VectorModule.cs"
__device__ bool mathblocks_nonnegative_integer(double value, int* result);

#line 157 "VectorModule.cs"
__device__ double mathblocks_quantile(
    const MathBlockSlot* input,
    MathBlockSlot* output,
    double probability);

#line 122 "VectorModule.cs"
__device__ void mathblocks_set_vector_shape(MathBlockSlot* output, int count);

#line 176 "VectorModule.cs"
__device__ void mathblocks_vector_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 105 "VectorModule.cs"
__device__ double mathblocks_compensated_absolute_sum(const double* values, int count)
#line 107 "VectorModule.cs"
{
#line 108 "VectorModule.cs"
    double sum = 0.0;
#line 109 "VectorModule.cs"
    double correction = 0.0;
#line 110 "VectorModule.cs"
    {
#line 110 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 111 "VectorModule.cs"
            {
#line 112 "VectorModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 112 "VectorModule.cs"
                double value = fabs(csharp2cuda_temp_1);
#line 113 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 114 "VectorModule.cs"
#line 114 "VectorModule.cs"
                double* csharp2cuda_temp_2 = &(correction);
#line 114 "VectorModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 114 "VectorModule.cs"
                double csharp2cuda_temp_4;
#line 114 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 114 "VectorModule.cs"
                    csharp2cuda_temp_4 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 114 "VectorModule.cs"
                    csharp2cuda_temp_4 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 117 "VectorModule.cs"
#line 117 "VectorModule.cs"
                double* csharp2cuda_temp_5 = &(sum);
                (*(csharp2cuda_temp_5) = next);
            }
#line 110 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 119 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 85 "VectorModule.cs"
__device__ double mathblocks_compensated_product_sum(
    const double* first,
    const double* second,
    int count)
#line 90 "VectorModule.cs"
{
#line 91 "VectorModule.cs"
    double sum = 0.0;
#line 92 "VectorModule.cs"
    double correction = 0.0;
#line 93 "VectorModule.cs"
    {
#line 93 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 94 "VectorModule.cs"
            {
#line 95 "VectorModule.cs"
                double csharp2cuda_temp_1 = (first)[index];
#line 95 "VectorModule.cs"
                double csharp2cuda_temp_2 = (second)[index];
#line 95 "VectorModule.cs"
                double value = __dmul_rn(csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 96 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 97 "VectorModule.cs"
#line 97 "VectorModule.cs"
                double* csharp2cuda_temp_3 = &(correction);
#line 97 "VectorModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 97 "VectorModule.cs"
                double csharp2cuda_temp_5;
#line 97 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 97 "VectorModule.cs"
                    csharp2cuda_temp_5 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 97 "VectorModule.cs"
                    csharp2cuda_temp_5 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
#line 100 "VectorModule.cs"
#line 100 "VectorModule.cs"
                double* csharp2cuda_temp_6 = &(sum);
                (*(csharp2cuda_temp_6) = next);
            }
#line 93 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 102 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 68 "VectorModule.cs"
__device__ double mathblocks_compensated_sum(const double* values, int count)
#line 70 "VectorModule.cs"
{
#line 71 "VectorModule.cs"
    double sum = 0.0;
#line 72 "VectorModule.cs"
    double correction = 0.0;
#line 73 "VectorModule.cs"
    {
#line 73 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 74 "VectorModule.cs"
            {
#line 75 "VectorModule.cs"
                double value = (values)[index];
#line 76 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 77 "VectorModule.cs"
#line 77 "VectorModule.cs"
                double* csharp2cuda_temp_1 = &(correction);
#line 77 "VectorModule.cs"
                double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 77 "VectorModule.cs"
                double csharp2cuda_temp_3;
#line 77 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 77 "VectorModule.cs"
                    csharp2cuda_temp_3 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 77 "VectorModule.cs"
                    csharp2cuda_temp_3 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 80 "VectorModule.cs"
#line 80 "VectorModule.cs"
                double* csharp2cuda_temp_4 = &(sum);
                (*(csharp2cuda_temp_4) = next);
            }
#line 73 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 82 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 135 "VectorModule.cs"
__device__ void mathblocks_copy_and_sort(
    const MathBlockSlot* input,
    MathBlockSlot* output)
#line 139 "VectorModule.cs"
{
#line 140 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_0 = (output)->data_pointer;
#line 140 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 140 "VectorModule.cs"
    if (((csharp2cuda_temp_0) != (((unsigned long long)(0)))))
    {
#line 140 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->data_pointer;
    }
    else
    {
#line 140 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->scratch_pointer;
    }
#line 140 "VectorModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_1));
#line 143 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_2 = (input)->data_pointer;
#line 143 "VectorModule.cs"
    const double* source = ((double*)(csharp2cuda_temp_2));
#line 144 "VectorModule.cs"
    {
#line 144 "VectorModule.cs"
        int index = 0;
        while (true)
        {
#line 144 "VectorModule.cs"
            int csharp2cuda_temp_4 = (input)->count;
            if (!(((index) < (csharp2cuda_temp_4))))
                break;
#line 145 "VectorModule.cs"
            {
#line 146 "VectorModule.cs"
                double value = (source)[index];
#line 147 "VectorModule.cs"
                int position = index;
#line 148 "VectorModule.cs"
                while (true)
                {
#line 148 "VectorModule.cs"
                    bool csharp2cuda_temp_5;
#line 148 "VectorModule.cs"
                    if (((position) > (0)))
                    {
#line 148 "VectorModule.cs"
                        double csharp2cuda_temp_6 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 148 "VectorModule.cs"
                        csharp2cuda_temp_5 = ((csharp2cuda_temp_6) > (value));
                    }
                    else
                    {
#line 148 "VectorModule.cs"
                        csharp2cuda_temp_5 = false;
                    }
                    if (!(csharp2cuda_temp_5))
                        break;
#line 149 "VectorModule.cs"
                    {
#line 150 "VectorModule.cs"
#line 150 "VectorModule.cs"
                        double* csharp2cuda_temp_7 = &((scratch)[position]);
#line 150 "VectorModule.cs"
                        double csharp2cuda_temp_8 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 151 "VectorModule.cs"
#line 151 "VectorModule.cs"
                        int* csharp2cuda_temp_9 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_9));
                    }
                }
#line 153 "VectorModule.cs"
#line 153 "VectorModule.cs"
                double* csharp2cuda_temp_10 = &((scratch)[position]);
                (*(csharp2cuda_temp_10) = value);
            }
#line 144 "VectorModule.cs"
            int* csharp2cuda_temp_3 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
}

#line 47 "VectorModule.cs"
__device__ double mathblocks_maximum(double first, double second)
#line 49 "VectorModule.cs"
{
#line 50 "VectorModule.cs"
    if (((first) > (second)))
    {
#line 51 "VectorModule.cs"
        return first;
    }
#line 52 "VectorModule.cs"
    if (((second) > (first)))
    {
#line 53 "VectorModule.cs"
        return second;
    }
#line 54 "VectorModule.cs"
    if (((first) == (0.0)))
    {
#line 55 "VectorModule.cs"
#line 55 "VectorModule.cs"
        double csharp2cuda_temp_0;
#line 55 "VectorModule.cs"
        if (signbit(first))
        {
#line 55 "VectorModule.cs"
            csharp2cuda_temp_0 = second;
        }
        else
        {
#line 55 "VectorModule.cs"
            csharp2cuda_temp_0 = first;
        }
        return csharp2cuda_temp_0;
    }
#line 56 "VectorModule.cs"
    return first;
}

#line 35 "VectorModule.cs"
__device__ double mathblocks_minimum(double first, double second)
#line 37 "VectorModule.cs"
{
#line 38 "VectorModule.cs"
    if (((first) < (second)))
    {
#line 39 "VectorModule.cs"
        return first;
    }
#line 40 "VectorModule.cs"
    if (((second) < (first)))
    {
#line 41 "VectorModule.cs"
        return second;
    }
#line 42 "VectorModule.cs"
    if (((first) == (0.0)))
    {
#line 43 "VectorModule.cs"
#line 43 "VectorModule.cs"
        double csharp2cuda_temp_0;
#line 43 "VectorModule.cs"
        if (signbit(first))
        {
#line 43 "VectorModule.cs"
            csharp2cuda_temp_0 = first;
        }
        else
        {
#line 43 "VectorModule.cs"
            csharp2cuda_temp_0 = second;
        }
        return csharp2cuda_temp_0;
    }
#line 44 "VectorModule.cs"
    return first;
}

#line 59 "VectorModule.cs"
__device__ bool mathblocks_nonnegative_integer(double value, int* result)
#line 61 "VectorModule.cs"
{
#line 62 "VectorModule.cs"
#line 62 "VectorModule.cs"
    bool csharp2cuda_temp_0;
#line 62 "VectorModule.cs"
    if (!(((value) < (0.0))))
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_0 = ((value) > (2147483647.0));
    }
    else
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 62 "VectorModule.cs"
    bool csharp2cuda_temp_1;
#line 62 "VectorModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_1 = ((value) != (trunc(value)));
    }
    else
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 63 "VectorModule.cs"
        return false;
    }
#line 64 "VectorModule.cs"
#line 64 "VectorModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 65 "VectorModule.cs"
    return true;
}

#line 157 "VectorModule.cs"
__device__ double mathblocks_quantile(
    const MathBlockSlot* input,
    MathBlockSlot* output,
    double probability)
#line 162 "VectorModule.cs"
{
#line 163 "VectorModule.cs"
    mathblocks_copy_and_sort(input, output);
#line 164 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_0 = (output)->data_pointer;
#line 164 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 164 "VectorModule.cs"
    if (((csharp2cuda_temp_0) != (((unsigned long long)(0)))))
    {
#line 164 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->data_pointer;
    }
    else
    {
#line 164 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->scratch_pointer;
    }
#line 164 "VectorModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_1));
#line 167 "VectorModule.cs"
#line 167 "VectorModule.cs"
    int csharp2cuda_temp_2 = (input)->count;
    if (((csharp2cuda_temp_2) == (1)))
    {
#line 168 "VectorModule.cs"
        return (scratch)[0];
    }
#line 169 "VectorModule.cs"
    int csharp2cuda_temp_3 = (input)->count;
#line 169 "VectorModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(csharp2cuda_temp_3, 1))));
#line 170 "VectorModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 171 "VectorModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 172 "VectorModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 173 "VectorModule.cs"
#line 173 "VectorModule.cs"
    double csharp2cuda_temp_4 = (scratch)[lower];
#line 173 "VectorModule.cs"
    double csharp2cuda_temp_5 = (scratch)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_4, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_5, weight));
}

#line 122 "VectorModule.cs"
__device__ void mathblocks_set_vector_shape(MathBlockSlot* output, int count)
#line 124 "VectorModule.cs"
{
#line 125 "VectorModule.cs"
#line 125 "VectorModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 126 "VectorModule.cs"
#line 126 "VectorModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 127 "VectorModule.cs"
#line 127 "VectorModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 128 "VectorModule.cs"
#line 128 "VectorModule.cs"
    bool csharp2cuda_temp_3;
#line 128 "VectorModule.cs"
    if (!(((count) < (0))))
    {
#line 128 "VectorModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 128 "VectorModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 128 "VectorModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 129 "VectorModule.cs"
    {
#line 130 "VectorModule.cs"
#line 130 "VectorModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 131 "VectorModule.cs"
        return;
    }
}

#line 176 "VectorModule.cs"
__device__ void mathblocks_vector_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 182 "VectorModule.cs"
{
#line 183 "VectorModule.cs"
    int thread = threadIdx.x;
#line 184 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 184 "VectorModule.cs"
    if (((input_count) > (0)))
    {
#line 184 "VectorModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 184 "VectorModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 184 "VectorModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 185 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 185 "VectorModule.cs"
    if (((input_count) > (1)))
    {
#line 185 "VectorModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 185 "VectorModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 185 "VectorModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 186 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 186 "VectorModule.cs"
    if (((input_count) > (2)))
    {
#line 186 "VectorModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 186 "VectorModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 186 "VectorModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 188 "VectorModule.cs"
    if (((thread) == (0)))
#line 189 "VectorModule.cs"
    {
#line 190 "VectorModule.cs"
#line 190 "VectorModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 191 "VectorModule.cs"
#line 191 "VectorModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 192 "VectorModule.cs"
#line 192 "VectorModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 193 "VectorModule.cs"
#line 193 "VectorModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 194 "VectorModule.cs"
#line 194 "VectorModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 195 "VectorModule.cs"
#line 195 "VectorModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 195 "VectorModule.cs"
        bool csharp2cuda_temp_9;
#line 195 "VectorModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 195 "VectorModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 195 "VectorModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 196 "VectorModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 197 "VectorModule.cs"
#line 197 "VectorModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 197 "VectorModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 197 "VectorModule.cs"
            bool csharp2cuda_temp_12;
#line 197 "VectorModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 197 "VectorModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 197 "VectorModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 198 "VectorModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 199 "VectorModule.cs"
#line 199 "VectorModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 199 "VectorModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 199 "VectorModule.cs"
            bool csharp2cuda_temp_15;
#line 199 "VectorModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 199 "VectorModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 199 "VectorModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 201 "VectorModule.cs"
    __syncthreads();
#line 202 "VectorModule.cs"
#line 202 "VectorModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 203 "VectorModule.cs"
        return;
    }
#line 205 "VectorModule.cs"
    double* csharp2cuda_temp_17;
#line 205 "VectorModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 205 "VectorModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 205 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 205 "VectorModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 205 "VectorModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 206 "VectorModule.cs"
    double* csharp2cuda_temp_19;
#line 206 "VectorModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 206 "VectorModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 206 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 206 "VectorModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 206 "VectorModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 207 "VectorModule.cs"
    double* csharp2cuda_temp_21;
#line 207 "VectorModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 207 "VectorModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 207 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 207 "VectorModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 207 "VectorModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 208 "VectorModule.cs"
    int* csharp2cuda_temp_23;
#line 208 "VectorModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 208 "VectorModule.cs"
        csharp2cuda_temp_23 = ((int*)(nullptr));
    }
    else
    {
#line 208 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_24 = (first)->data_pointer;
#line 208 "VectorModule.cs"
        csharp2cuda_temp_23 = ((int*)(csharp2cuda_temp_24));
    }
#line 208 "VectorModule.cs"
    const int* boolean_a = csharp2cuda_temp_23;
#line 209 "VectorModule.cs"
    int* csharp2cuda_temp_25;
#line 209 "VectorModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 209 "VectorModule.cs"
        csharp2cuda_temp_25 = ((int*)(nullptr));
    }
    else
    {
#line 209 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_26 = (second)->data_pointer;
#line 209 "VectorModule.cs"
        csharp2cuda_temp_25 = ((int*)(csharp2cuda_temp_26));
    }
#line 209 "VectorModule.cs"
    const int* boolean_b = csharp2cuda_temp_25;
#line 210 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_27 = (output)->data_pointer;
#line 210 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_28;
#line 210 "VectorModule.cs"
    if (((csharp2cuda_temp_27) != (((unsigned long long)(0)))))
    {
#line 210 "VectorModule.cs"
        csharp2cuda_temp_28 = (output)->data_pointer;
    }
    else
    {
#line 210 "VectorModule.cs"
        csharp2cuda_temp_28 = (output)->scratch_pointer;
    }
#line 210 "VectorModule.cs"
    double* result = ((double*)(csharp2cuda_temp_28));
#line 213 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_29 = (output)->data_pointer;
#line 213 "VectorModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_29));
#line 215 "VectorModule.cs"
    switch (opcode)
    {
#line 217 "VectorModule.cs"
        case 0:
#line 218 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 218 "VectorModule.cs"
#line 218 "VectorModule.cs"
                int csharp2cuda_temp_30 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_30);
            }
#line 219 "VectorModule.cs"
            __syncthreads();
#line 220 "VectorModule.cs"
            {
#line 220 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 220 "VectorModule.cs"
                    bool csharp2cuda_temp_33 = (output)->valid;
#line 220 "VectorModule.cs"
                    bool csharp2cuda_temp_34;
#line 220 "VectorModule.cs"
                    if (csharp2cuda_temp_33)
                    {
#line 220 "VectorModule.cs"
                        int csharp2cuda_temp_35 = (first)->count;
#line 220 "VectorModule.cs"
                        csharp2cuda_temp_34 = ((index) < (csharp2cuda_temp_35));
                    }
                    else
                    {
#line 220 "VectorModule.cs"
                        csharp2cuda_temp_34 = false;
                    }
                    if (!(csharp2cuda_temp_34))
                        break;
#line 221 "VectorModule.cs"
#line 221 "VectorModule.cs"
                    double* csharp2cuda_temp_36 = &((result)[index]);
#line 221 "VectorModule.cs"
                    double csharp2cuda_temp_37 = (a)[index];
                    (*(csharp2cuda_temp_36) = fabs(csharp2cuda_temp_37));
#line 220 "VectorModule.cs"
                    int* csharp2cuda_temp_31 = &(index);
#line 220 "VectorModule.cs"
                    int csharp2cuda_temp_32 = *(csharp2cuda_temp_31);
                    (*(csharp2cuda_temp_31) = csharp2cuda_i32_add(csharp2cuda_temp_32, blockDim.x));
                }
            }
#line 222 "VectorModule.cs"
            break;
#line 223 "VectorModule.cs"
        case 1:
#line 224 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 224 "VectorModule.cs"
#line 224 "VectorModule.cs"
                int csharp2cuda_temp_38 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_38);
            }
#line 225 "VectorModule.cs"
            __syncthreads();
#line 226 "VectorModule.cs"
            {
#line 226 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 226 "VectorModule.cs"
                    bool csharp2cuda_temp_41 = (output)->valid;
#line 226 "VectorModule.cs"
                    bool csharp2cuda_temp_42;
#line 226 "VectorModule.cs"
                    if (csharp2cuda_temp_41)
                    {
#line 226 "VectorModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
#line 226 "VectorModule.cs"
                        csharp2cuda_temp_42 = ((index) < (csharp2cuda_temp_43));
                    }
                    else
                    {
#line 226 "VectorModule.cs"
                        csharp2cuda_temp_42 = false;
                    }
                    if (!(csharp2cuda_temp_42))
                        break;
#line 227 "VectorModule.cs"
                    {
#line 228 "VectorModule.cs"
#line 228 "VectorModule.cs"
                        double* csharp2cuda_temp_44 = &((result)[index]);
#line 228 "VectorModule.cs"
                        double csharp2cuda_temp_45 = (a)[index];
#line 228 "VectorModule.cs"
                        double csharp2cuda_temp_46 = (second)->scalar_value;
                        (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 229 "VectorModule.cs"
#line 229 "VectorModule.cs"
                        double csharp2cuda_temp_47 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_47))))
                        {
#line 229 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 226 "VectorModule.cs"
                    int* csharp2cuda_temp_39 = &(index);
#line 226 "VectorModule.cs"
                    int csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
                    (*(csharp2cuda_temp_39) = csharp2cuda_i32_add(csharp2cuda_temp_40, blockDim.x));
                }
            }
#line 231 "VectorModule.cs"
            break;
#line 232 "VectorModule.cs"
        case 2:
        case 9:
        case 26:
        case 47:
#line 236 "VectorModule.cs"
            if (((thread) == (0)))
#line 237 "VectorModule.cs"
            {
#line 238 "VectorModule.cs"
#line 238 "VectorModule.cs"
                int csharp2cuda_temp_48 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_48);
#line 239 "VectorModule.cs"
#line 239 "VectorModule.cs"
                int csharp2cuda_temp_49 = (first)->count;
#line 239 "VectorModule.cs"
                int csharp2cuda_temp_50 = (second)->count;
                if (((csharp2cuda_temp_49) != (csharp2cuda_temp_50)))
                {
#line 239 "VectorModule.cs"
#line 239 "VectorModule.cs"
                    int* csharp2cuda_temp_51 = &((output)->valid);
                    (*(csharp2cuda_temp_51) = 0);
                }
            }
#line 241 "VectorModule.cs"
            __syncthreads();
#line 242 "VectorModule.cs"
            {
#line 242 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 242 "VectorModule.cs"
                    bool csharp2cuda_temp_54 = (output)->valid;
#line 242 "VectorModule.cs"
                    bool csharp2cuda_temp_55;
#line 242 "VectorModule.cs"
                    if (csharp2cuda_temp_54)
                    {
#line 242 "VectorModule.cs"
                        int csharp2cuda_temp_56 = (first)->count;
#line 242 "VectorModule.cs"
                        csharp2cuda_temp_55 = ((index) < (csharp2cuda_temp_56));
                    }
                    else
                    {
#line 242 "VectorModule.cs"
                        csharp2cuda_temp_55 = false;
                    }
                    if (!(csharp2cuda_temp_55))
                        break;
#line 243 "VectorModule.cs"
                    {
#line 244 "VectorModule.cs"
                        double csharp2cuda_temp_57;
#line 244 "VectorModule.cs"
                        if (((opcode) == (2)))
                        {
#line 244 "VectorModule.cs"
                            double csharp2cuda_temp_58 = (a)[index];
#line 244 "VectorModule.cs"
                            double csharp2cuda_temp_59 = (b)[index];
#line 244 "VectorModule.cs"
                            csharp2cuda_temp_57 = __dadd_rn(csharp2cuda_temp_58, csharp2cuda_temp_59);
                        }
                        else
                        {
#line 245 "VectorModule.cs"
                            double csharp2cuda_temp_60;
#line 245 "VectorModule.cs"
                            if (((opcode) == (9)))
                            {
#line 245 "VectorModule.cs"
                                double csharp2cuda_temp_61 = (a)[index];
#line 245 "VectorModule.cs"
                                double csharp2cuda_temp_62 = (b)[index];
#line 245 "VectorModule.cs"
                                csharp2cuda_temp_60 = __ddiv_rn(csharp2cuda_temp_61, csharp2cuda_temp_62);
                            }
                            else
                            {
#line 246 "VectorModule.cs"
                                double csharp2cuda_temp_63;
#line 246 "VectorModule.cs"
                                if (((opcode) == (26)))
                                {
#line 246 "VectorModule.cs"
                                    double csharp2cuda_temp_64 = (a)[index];
#line 246 "VectorModule.cs"
                                    double csharp2cuda_temp_65 = (b)[index];
#line 246 "VectorModule.cs"
                                    csharp2cuda_temp_63 = __dmul_rn(csharp2cuda_temp_64, csharp2cuda_temp_65);
                                }
                                else
                                {
#line 247 "VectorModule.cs"
                                    double csharp2cuda_temp_66 = (a)[index];
#line 247 "VectorModule.cs"
                                    double csharp2cuda_temp_67 = (b)[index];
#line 246 "VectorModule.cs"
                                    csharp2cuda_temp_63 = __dsub_rn(csharp2cuda_temp_66, csharp2cuda_temp_67);
                                }
#line 245 "VectorModule.cs"
                                csharp2cuda_temp_60 = csharp2cuda_temp_63;
                            }
#line 244 "VectorModule.cs"
                            csharp2cuda_temp_57 = csharp2cuda_temp_60;
                        }
#line 244 "VectorModule.cs"
                        double value = csharp2cuda_temp_57;
#line 248 "VectorModule.cs"
#line 248 "VectorModule.cs"
                        double* csharp2cuda_temp_68 = &((result)[index]);
                        (*(csharp2cuda_temp_68) = value);
#line 249 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 249 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 242 "VectorModule.cs"
                    int* csharp2cuda_temp_52 = &(index);
#line 242 "VectorModule.cs"
                    int csharp2cuda_temp_53 = *(csharp2cuda_temp_52);
                    (*(csharp2cuda_temp_52) = csharp2cuda_i32_add(csharp2cuda_temp_53, blockDim.x));
                }
            }
#line 251 "VectorModule.cs"
            break;
#line 252 "VectorModule.cs"
        case 3:
#line 253 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 253 "VectorModule.cs"
#line 253 "VectorModule.cs"
                int csharp2cuda_temp_69 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_69, 1));
            }
#line 254 "VectorModule.cs"
            __syncthreads();
#line 255 "VectorModule.cs"
            {
#line 255 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 255 "VectorModule.cs"
                    bool csharp2cuda_temp_72 = (output)->valid;
#line 255 "VectorModule.cs"
                    bool csharp2cuda_temp_73;
#line 255 "VectorModule.cs"
                    if (csharp2cuda_temp_72)
                    {
#line 255 "VectorModule.cs"
                        int csharp2cuda_temp_74 = (first)->count;
#line 255 "VectorModule.cs"
                        csharp2cuda_temp_73 = ((index) < (csharp2cuda_temp_74));
                    }
                    else
                    {
#line 255 "VectorModule.cs"
                        csharp2cuda_temp_73 = false;
                    }
                    if (!(csharp2cuda_temp_73))
                        break;
#line 256 "VectorModule.cs"
#line 256 "VectorModule.cs"
                    double* csharp2cuda_temp_75 = &((result)[index]);
#line 256 "VectorModule.cs"
                    double csharp2cuda_temp_76 = (a)[index];
                    (*(csharp2cuda_temp_75) = csharp2cuda_temp_76);
#line 255 "VectorModule.cs"
                    int* csharp2cuda_temp_70 = &(index);
#line 255 "VectorModule.cs"
                    int csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
                    (*(csharp2cuda_temp_70) = csharp2cuda_i32_add(csharp2cuda_temp_71, blockDim.x));
                }
            }
#line 257 "VectorModule.cs"
#line 257 "VectorModule.cs"
            bool csharp2cuda_temp_77;
#line 257 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 257 "VectorModule.cs"
                csharp2cuda_temp_77 = (output)->valid;
            }
            else
            {
#line 257 "VectorModule.cs"
                csharp2cuda_temp_77 = false;
            }
            if (csharp2cuda_temp_77)
            {
#line 257 "VectorModule.cs"
#line 257 "VectorModule.cs"
                int csharp2cuda_temp_78 = (first)->count;
#line 257 "VectorModule.cs"
                double* csharp2cuda_temp_79 = &((result)[csharp2cuda_temp_78]);
#line 257 "VectorModule.cs"
                double csharp2cuda_temp_80 = (second)->scalar_value;
                (*(csharp2cuda_temp_79) = csharp2cuda_temp_80);
            }
#line 258 "VectorModule.cs"
            break;
#line 259 "VectorModule.cs"
        case 4:
        case 5:
#line 261 "VectorModule.cs"
            if (((thread) == (0)))
#line 262 "VectorModule.cs"
            {
#line 263 "VectorModule.cs"
#line 263 "VectorModule.cs"
                int csharp2cuda_temp_81 = (first)->count;
                if (((csharp2cuda_temp_81) <= (0)))
#line 264 "VectorModule.cs"
                {
#line 265 "VectorModule.cs"
#line 265 "VectorModule.cs"
                    int* csharp2cuda_temp_82 = &((output)->valid);
                    (*(csharp2cuda_temp_82) = 0);
#line 266 "VectorModule.cs"
                    break;
                }
#line 268 "VectorModule.cs"
                int selected = 0;
#line 269 "VectorModule.cs"
                {
#line 269 "VectorModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 269 "VectorModule.cs"
                        int csharp2cuda_temp_84 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_84))))
                            break;
#line 270 "VectorModule.cs"
#line 270 "VectorModule.cs"
                        bool csharp2cuda_temp_85;
#line 270 "VectorModule.cs"
                        if (((opcode) == (4)))
                        {
#line 270 "VectorModule.cs"
                            double csharp2cuda_temp_86 = (a)[index];
#line 270 "VectorModule.cs"
                            double csharp2cuda_temp_87 = (a)[selected];
#line 270 "VectorModule.cs"
                            csharp2cuda_temp_85 = ((csharp2cuda_temp_86) > (csharp2cuda_temp_87));
                        }
                        else
                        {
#line 270 "VectorModule.cs"
                            double csharp2cuda_temp_88 = (a)[index];
#line 270 "VectorModule.cs"
                            double csharp2cuda_temp_89 = (a)[selected];
#line 270 "VectorModule.cs"
                            csharp2cuda_temp_85 = ((csharp2cuda_temp_88) < (csharp2cuda_temp_89));
                        }
                        if (csharp2cuda_temp_85)
                        {
#line 270 "VectorModule.cs"
#line 270 "VectorModule.cs"
                            int* csharp2cuda_temp_90 = &(selected);
                            (*(csharp2cuda_temp_90) = index);
                        }
#line 269 "VectorModule.cs"
                        int* csharp2cuda_temp_83 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_83));
                    }
                }
#line 271 "VectorModule.cs"
#line 271 "VectorModule.cs"
                double* csharp2cuda_temp_91 = &((output)->scalar_value);
                (*(csharp2cuda_temp_91) = ((double)(selected)));
            }
#line 273 "VectorModule.cs"
            break;
#line 274 "VectorModule.cs"
        case 6:
#line 275 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 275 "VectorModule.cs"
#line 275 "VectorModule.cs"
                int csharp2cuda_temp_92 = (first)->count;
#line 275 "VectorModule.cs"
                int csharp2cuda_temp_93 = (second)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_92, csharp2cuda_temp_93));
            }
#line 276 "VectorModule.cs"
            __syncthreads();
#line 277 "VectorModule.cs"
            {
#line 277 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 277 "VectorModule.cs"
                    bool csharp2cuda_temp_96 = (output)->valid;
#line 277 "VectorModule.cs"
                    bool csharp2cuda_temp_97;
#line 277 "VectorModule.cs"
                    if (csharp2cuda_temp_96)
                    {
#line 277 "VectorModule.cs"
                        int csharp2cuda_temp_98 = (first)->count;
#line 277 "VectorModule.cs"
                        csharp2cuda_temp_97 = ((index) < (csharp2cuda_temp_98));
                    }
                    else
                    {
#line 277 "VectorModule.cs"
                        csharp2cuda_temp_97 = false;
                    }
                    if (!(csharp2cuda_temp_97))
                        break;
#line 278 "VectorModule.cs"
#line 278 "VectorModule.cs"
                    double* csharp2cuda_temp_99 = &((result)[index]);
#line 278 "VectorModule.cs"
                    double csharp2cuda_temp_100 = (a)[index];
                    (*(csharp2cuda_temp_99) = csharp2cuda_temp_100);
#line 277 "VectorModule.cs"
                    int* csharp2cuda_temp_94 = &(index);
#line 277 "VectorModule.cs"
                    int csharp2cuda_temp_95 = *(csharp2cuda_temp_94);
                    (*(csharp2cuda_temp_94) = csharp2cuda_i32_add(csharp2cuda_temp_95, blockDim.x));
                }
            }
#line 279 "VectorModule.cs"
            {
#line 279 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 279 "VectorModule.cs"
                    bool csharp2cuda_temp_103 = (output)->valid;
#line 279 "VectorModule.cs"
                    bool csharp2cuda_temp_104;
#line 279 "VectorModule.cs"
                    if (csharp2cuda_temp_103)
                    {
#line 279 "VectorModule.cs"
                        int csharp2cuda_temp_105 = (second)->count;
#line 279 "VectorModule.cs"
                        csharp2cuda_temp_104 = ((index) < (csharp2cuda_temp_105));
                    }
                    else
                    {
#line 279 "VectorModule.cs"
                        csharp2cuda_temp_104 = false;
                    }
                    if (!(csharp2cuda_temp_104))
                        break;
#line 280 "VectorModule.cs"
#line 280 "VectorModule.cs"
                    int csharp2cuda_temp_106 = (first)->count;
#line 280 "VectorModule.cs"
                    double* csharp2cuda_temp_107 = &((result)[csharp2cuda_i32_add(csharp2cuda_temp_106, index)]);
#line 280 "VectorModule.cs"
                    double csharp2cuda_temp_108 = (b)[index];
                    (*(csharp2cuda_temp_107) = csharp2cuda_temp_108);
#line 279 "VectorModule.cs"
                    int* csharp2cuda_temp_101 = &(index);
#line 279 "VectorModule.cs"
                    int csharp2cuda_temp_102 = *(csharp2cuda_temp_101);
                    (*(csharp2cuda_temp_101) = csharp2cuda_i32_add(csharp2cuda_temp_102, blockDim.x));
                }
            }
#line 281 "VectorModule.cs"
            break;
#line 282 "VectorModule.cs"
        case 7:
#line 283 "VectorModule.cs"
            if (((thread) == (0)))
#line 284 "VectorModule.cs"
            {
#line 285 "VectorModule.cs"
#line 285 "VectorModule.cs"
                int csharp2cuda_temp_109 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_109);
#line 286 "VectorModule.cs"
                double product = 1.0;
#line 287 "VectorModule.cs"
                {
#line 287 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 287 "VectorModule.cs"
                        bool csharp2cuda_temp_111 = (output)->valid;
#line 287 "VectorModule.cs"
                        bool csharp2cuda_temp_112;
#line 287 "VectorModule.cs"
                        if (csharp2cuda_temp_111)
                        {
#line 287 "VectorModule.cs"
                            int csharp2cuda_temp_113 = (first)->count;
#line 287 "VectorModule.cs"
                            csharp2cuda_temp_112 = ((index) < (csharp2cuda_temp_113));
                        }
                        else
                        {
#line 287 "VectorModule.cs"
                            csharp2cuda_temp_112 = false;
                        }
                        if (!(csharp2cuda_temp_112))
                            break;
#line 288 "VectorModule.cs"
                        {
#line 289 "VectorModule.cs"
#line 289 "VectorModule.cs"
                            double* csharp2cuda_temp_114 = &(product);
#line 289 "VectorModule.cs"
                            double csharp2cuda_temp_115 = *(csharp2cuda_temp_114);
#line 289 "VectorModule.cs"
                            double csharp2cuda_temp_116 = (a)[index];
                            (*(csharp2cuda_temp_114) = __dmul_rn(csharp2cuda_temp_115, csharp2cuda_temp_116));
#line 290 "VectorModule.cs"
#line 290 "VectorModule.cs"
                            double* csharp2cuda_temp_117 = &((result)[index]);
                            (*(csharp2cuda_temp_117) = product);
#line 291 "VectorModule.cs"
                            if ((!(isfinite(product))))
                            {
#line 291 "VectorModule.cs"
#line 291 "VectorModule.cs"
                                int* csharp2cuda_temp_118 = &((output)->valid);
                                (*(csharp2cuda_temp_118) = 0);
                            }
                        }
#line 287 "VectorModule.cs"
                        int* csharp2cuda_temp_110 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_110));
                    }
                }
            }
#line 294 "VectorModule.cs"
            break;
#line 295 "VectorModule.cs"
        case 8:
#line 296 "VectorModule.cs"
            if (((thread) == (0)))
#line 297 "VectorModule.cs"
            {
#line 298 "VectorModule.cs"
#line 298 "VectorModule.cs"
                int csharp2cuda_temp_119 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_119);
#line 299 "VectorModule.cs"
                double sum = 0.0;
#line 300 "VectorModule.cs"
                {
#line 300 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 300 "VectorModule.cs"
                        bool csharp2cuda_temp_121 = (output)->valid;
#line 300 "VectorModule.cs"
                        bool csharp2cuda_temp_122;
#line 300 "VectorModule.cs"
                        if (csharp2cuda_temp_121)
                        {
#line 300 "VectorModule.cs"
                            int csharp2cuda_temp_123 = (first)->count;
#line 300 "VectorModule.cs"
                            csharp2cuda_temp_122 = ((index) < (csharp2cuda_temp_123));
                        }
                        else
                        {
#line 300 "VectorModule.cs"
                            csharp2cuda_temp_122 = false;
                        }
                        if (!(csharp2cuda_temp_122))
                            break;
#line 301 "VectorModule.cs"
                        {
#line 302 "VectorModule.cs"
#line 302 "VectorModule.cs"
                            double* csharp2cuda_temp_124 = &(sum);
#line 302 "VectorModule.cs"
                            double csharp2cuda_temp_125 = *(csharp2cuda_temp_124);
#line 302 "VectorModule.cs"
                            double csharp2cuda_temp_126 = (a)[index];
                            (*(csharp2cuda_temp_124) = __dadd_rn(csharp2cuda_temp_125, csharp2cuda_temp_126));
#line 303 "VectorModule.cs"
#line 303 "VectorModule.cs"
                            double* csharp2cuda_temp_127 = &((result)[index]);
                            (*(csharp2cuda_temp_127) = sum);
#line 304 "VectorModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 304 "VectorModule.cs"
#line 304 "VectorModule.cs"
                                int* csharp2cuda_temp_128 = &((output)->valid);
                                (*(csharp2cuda_temp_128) = 0);
                            }
                        }
#line 300 "VectorModule.cs"
                        int* csharp2cuda_temp_120 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_120));
                    }
                }
            }
#line 307 "VectorModule.cs"
            break;
#line 308 "VectorModule.cs"
        case 10:
#line 309 "VectorModule.cs"
            if (((thread) == (0)))
#line 310 "VectorModule.cs"
            {
#line 311 "VectorModule.cs"
#line 311 "VectorModule.cs"
                int csharp2cuda_temp_129 = (first)->count;
#line 311 "VectorModule.cs"
                int csharp2cuda_temp_130 = (second)->count;
                if (((csharp2cuda_temp_129) != (csharp2cuda_temp_130)))
                {
#line 311 "VectorModule.cs"
#line 311 "VectorModule.cs"
                    int* csharp2cuda_temp_131 = &((output)->valid);
                    (*(csharp2cuda_temp_131) = 0);
                }
                else
#line 313 "VectorModule.cs"
                {
#line 314 "VectorModule.cs"
#line 314 "VectorModule.cs"
                    double* csharp2cuda_temp_132 = &((output)->scalar_value);
#line 314 "VectorModule.cs"
                    int csharp2cuda_temp_133 = (first)->count;
#line 314 "VectorModule.cs"
                    double csharp2cuda_temp_134 = mathblocks_compensated_product_sum(a, b, csharp2cuda_temp_133);
                    (*(csharp2cuda_temp_132) = csharp2cuda_temp_134);
#line 315 "VectorModule.cs"
#line 315 "VectorModule.cs"
                    double csharp2cuda_temp_135 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_135))))
                    {
#line 315 "VectorModule.cs"
#line 315 "VectorModule.cs"
                        int* csharp2cuda_temp_136 = &((output)->valid);
                        (*(csharp2cuda_temp_136) = 0);
                    }
                }
            }
#line 318 "VectorModule.cs"
            break;
#line 319 "VectorModule.cs"
        case 11:
        case 15:
        case 20:
#line 322 "VectorModule.cs"
            if (((thread) == (0)))
#line 323 "VectorModule.cs"
            {
#line 324 "VectorModule.cs"
#line 324 "VectorModule.cs"
                int csharp2cuda_temp_137 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_137);
#line 325 "VectorModule.cs"
#line 325 "VectorModule.cs"
                int csharp2cuda_temp_138 = (first)->count;
#line 325 "VectorModule.cs"
                int csharp2cuda_temp_139 = (second)->count;
                if (((csharp2cuda_temp_138) != (csharp2cuda_temp_139)))
                {
#line 325 "VectorModule.cs"
#line 325 "VectorModule.cs"
                    int* csharp2cuda_temp_140 = &((output)->valid);
                    (*(csharp2cuda_temp_140) = 0);
                }
            }
#line 327 "VectorModule.cs"
            __syncthreads();
#line 328 "VectorModule.cs"
            {
#line 328 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 328 "VectorModule.cs"
                    bool csharp2cuda_temp_143 = (output)->valid;
#line 328 "VectorModule.cs"
                    bool csharp2cuda_temp_144;
#line 328 "VectorModule.cs"
                    if (csharp2cuda_temp_143)
                    {
#line 328 "VectorModule.cs"
                        int csharp2cuda_temp_145 = (first)->count;
#line 328 "VectorModule.cs"
                        csharp2cuda_temp_144 = ((index) < (csharp2cuda_temp_145));
                    }
                    else
                    {
#line 328 "VectorModule.cs"
                        csharp2cuda_temp_144 = false;
                    }
                    if (!(csharp2cuda_temp_144))
                        break;
#line 329 "VectorModule.cs"
#line 329 "VectorModule.cs"
                    int* csharp2cuda_temp_146 = &((boolean_result)[index]);
#line 329 "VectorModule.cs"
                    bool csharp2cuda_temp_147;
#line 329 "VectorModule.cs"
                    if (((opcode) == (11)))
                    {
#line 329 "VectorModule.cs"
                        double csharp2cuda_temp_148 = (a)[index];
#line 329 "VectorModule.cs"
                        double csharp2cuda_temp_149 = (b)[index];
#line 329 "VectorModule.cs"
                        csharp2cuda_temp_147 = ((csharp2cuda_temp_148) == (csharp2cuda_temp_149));
                    }
                    else
                    {
#line 330 "VectorModule.cs"
                        bool csharp2cuda_temp_150;
#line 330 "VectorModule.cs"
                        if (((opcode) == (15)))
                        {
#line 330 "VectorModule.cs"
                            double csharp2cuda_temp_151 = (a)[index];
#line 330 "VectorModule.cs"
                            double csharp2cuda_temp_152 = (b)[index];
#line 330 "VectorModule.cs"
                            csharp2cuda_temp_150 = ((csharp2cuda_temp_151) > (csharp2cuda_temp_152));
                        }
                        else
                        {
#line 331 "VectorModule.cs"
                            double csharp2cuda_temp_153 = (a)[index];
#line 331 "VectorModule.cs"
                            double csharp2cuda_temp_154 = (b)[index];
#line 330 "VectorModule.cs"
                            csharp2cuda_temp_150 = ((csharp2cuda_temp_153) < (csharp2cuda_temp_154));
                        }
#line 329 "VectorModule.cs"
                        csharp2cuda_temp_147 = csharp2cuda_temp_150;
                    }
                    (*(csharp2cuda_temp_146) = csharp2cuda_temp_147);
#line 328 "VectorModule.cs"
                    int* csharp2cuda_temp_141 = &(index);
#line 328 "VectorModule.cs"
                    int csharp2cuda_temp_142 = *(csharp2cuda_temp_141);
                    (*(csharp2cuda_temp_141) = csharp2cuda_i32_add(csharp2cuda_temp_142, blockDim.x));
                }
            }
#line 332 "VectorModule.cs"
            break;
#line 333 "VectorModule.cs"
        case 12:
        case 27:
        case 44:
#line 336 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 336 "VectorModule.cs"
#line 336 "VectorModule.cs"
                int csharp2cuda_temp_155 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_155);
            }
#line 337 "VectorModule.cs"
            __syncthreads();
#line 338 "VectorModule.cs"
            {
#line 338 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 338 "VectorModule.cs"
                    bool csharp2cuda_temp_158 = (output)->valid;
#line 338 "VectorModule.cs"
                    bool csharp2cuda_temp_159;
#line 338 "VectorModule.cs"
                    if (csharp2cuda_temp_158)
                    {
#line 338 "VectorModule.cs"
                        int csharp2cuda_temp_160 = (first)->count;
#line 338 "VectorModule.cs"
                        csharp2cuda_temp_159 = ((index) < (csharp2cuda_temp_160));
                    }
                    else
                    {
#line 338 "VectorModule.cs"
                        csharp2cuda_temp_159 = false;
                    }
                    if (!(csharp2cuda_temp_159))
                        break;
#line 339 "VectorModule.cs"
                    {
#line 340 "VectorModule.cs"
                        double csharp2cuda_temp_161;
#line 340 "VectorModule.cs"
                        if (((opcode) == (12)))
                        {
#line 340 "VectorModule.cs"
                            double csharp2cuda_temp_162 = (a)[index];
#line 340 "VectorModule.cs"
                            csharp2cuda_temp_161 = mathblocks_exponential(csharp2cuda_temp_162);
                        }
                        else
                        {
#line 341 "VectorModule.cs"
                            double csharp2cuda_temp_163;
#line 341 "VectorModule.cs"
                            if (((opcode) == (27)))
                            {
#line 341 "VectorModule.cs"
                                double csharp2cuda_temp_164 = (a)[index];
#line 341 "VectorModule.cs"
                                csharp2cuda_temp_163 = mathblocks_natural_logarithm(csharp2cuda_temp_164);
                            }
                            else
                            {
#line 342 "VectorModule.cs"
                                double csharp2cuda_temp_165 = (a)[index];
#line 341 "VectorModule.cs"
                                csharp2cuda_temp_163 = mathblocks_square_root(csharp2cuda_temp_165);
                            }
#line 340 "VectorModule.cs"
                            csharp2cuda_temp_161 = csharp2cuda_temp_163;
                        }
#line 340 "VectorModule.cs"
                        double value = csharp2cuda_temp_161;
#line 343 "VectorModule.cs"
#line 343 "VectorModule.cs"
                        double* csharp2cuda_temp_166 = &((result)[index]);
                        (*(csharp2cuda_temp_166) = value);
#line 344 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 344 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 338 "VectorModule.cs"
                    int* csharp2cuda_temp_156 = &(index);
#line 338 "VectorModule.cs"
                    int csharp2cuda_temp_157 = *(csharp2cuda_temp_156);
                    (*(csharp2cuda_temp_156) = csharp2cuda_i32_add(csharp2cuda_temp_157, blockDim.x));
                }
            }
#line 346 "VectorModule.cs"
            break;
#line 347 "VectorModule.cs"
        case 13:
#line 348 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 348 "VectorModule.cs"
#line 348 "VectorModule.cs"
                int csharp2cuda_temp_167 = (second)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_167);
            }
#line 349 "VectorModule.cs"
            __syncthreads();
#line 350 "VectorModule.cs"
            {
#line 350 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 350 "VectorModule.cs"
                    bool csharp2cuda_temp_170 = (output)->valid;
#line 350 "VectorModule.cs"
                    bool csharp2cuda_temp_171;
#line 350 "VectorModule.cs"
                    if (csharp2cuda_temp_170)
                    {
#line 350 "VectorModule.cs"
                        int csharp2cuda_temp_172 = (second)->count;
#line 350 "VectorModule.cs"
                        csharp2cuda_temp_171 = ((index) < (csharp2cuda_temp_172));
                    }
                    else
                    {
#line 350 "VectorModule.cs"
                        csharp2cuda_temp_171 = false;
                    }
                    if (!(csharp2cuda_temp_171))
                        break;
#line 351 "VectorModule.cs"
                    {
#line 352 "VectorModule.cs"
                        int source_index = 0;
#line 353 "VectorModule.cs"
#line 353 "VectorModule.cs"
                        double csharp2cuda_temp_173 = (b)[index];
#line 353 "VectorModule.cs"
                        int* csharp2cuda_temp_174 = &(source_index);
#line 353 "VectorModule.cs"
                        bool csharp2cuda_temp_175 = mathblocks_nonnegative_integer(csharp2cuda_temp_173, csharp2cuda_temp_174);
#line 353 "VectorModule.cs"
                        bool csharp2cuda_temp_176;
#line 353 "VectorModule.cs"
                        if (!((!(csharp2cuda_temp_175))))
                        {
#line 353 "VectorModule.cs"
                            int csharp2cuda_temp_177 = (first)->count;
#line 353 "VectorModule.cs"
                            csharp2cuda_temp_176 = ((source_index) >= (csharp2cuda_temp_177));
                        }
                        else
                        {
#line 353 "VectorModule.cs"
                            csharp2cuda_temp_176 = true;
                        }
                        if (csharp2cuda_temp_176)
                        {
#line 354 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                        else
                        {
#line 356 "VectorModule.cs"
#line 356 "VectorModule.cs"
                            double* csharp2cuda_temp_178 = &((result)[index]);
#line 356 "VectorModule.cs"
                            double csharp2cuda_temp_179 = (a)[source_index];
                            (*(csharp2cuda_temp_178) = csharp2cuda_temp_179);
                        }
                    }
#line 350 "VectorModule.cs"
                    int* csharp2cuda_temp_168 = &(index);
#line 350 "VectorModule.cs"
                    int csharp2cuda_temp_169 = *(csharp2cuda_temp_168);
                    (*(csharp2cuda_temp_168) = csharp2cuda_i32_add(csharp2cuda_temp_169, blockDim.x));
                }
            }
#line 358 "VectorModule.cs"
            break;
#line 359 "VectorModule.cs"
        case 14:
#line 360 "VectorModule.cs"
            if (((thread) == (0)))
#line 361 "VectorModule.cs"
            {
#line 362 "VectorModule.cs"
#line 362 "VectorModule.cs"
                int csharp2cuda_temp_180 = (first)->count;
#line 362 "VectorModule.cs"
                bool csharp2cuda_temp_181;
#line 362 "VectorModule.cs"
                if (!(((csharp2cuda_temp_180) <= (0))))
                {
#line 362 "VectorModule.cs"
                    unsigned long long csharp2cuda_temp_182 = (output)->scratch_pointer;
#line 362 "VectorModule.cs"
                    csharp2cuda_temp_181 = ((csharp2cuda_temp_182) == (((unsigned long long)(0))));
                }
                else
                {
#line 362 "VectorModule.cs"
                    csharp2cuda_temp_181 = true;
                }
                if (csharp2cuda_temp_181)
#line 363 "VectorModule.cs"
                {
#line 364 "VectorModule.cs"
#line 364 "VectorModule.cs"
                    int* csharp2cuda_temp_183 = &((output)->valid);
                    (*(csharp2cuda_temp_183) = 0);
#line 365 "VectorModule.cs"
                    break;
                }
#line 367 "VectorModule.cs"
                {
#line 367 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 367 "VectorModule.cs"
                        int csharp2cuda_temp_185 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_185))))
                            break;
#line 368 "VectorModule.cs"
                        {
#line 369 "VectorModule.cs"
#line 369 "VectorModule.cs"
                            double* csharp2cuda_temp_186 = &((result)[index]);
#line 369 "VectorModule.cs"
                            double csharp2cuda_temp_187 = (a)[index];
                            (*(csharp2cuda_temp_186) = mathblocks_natural_logarithm(csharp2cuda_temp_187));
#line 370 "VectorModule.cs"
#line 370 "VectorModule.cs"
                            double csharp2cuda_temp_188 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_188))))
                            {
#line 370 "VectorModule.cs"
#line 370 "VectorModule.cs"
                                int* csharp2cuda_temp_189 = &((output)->valid);
                                (*(csharp2cuda_temp_189) = 0);
                            }
                        }
#line 367 "VectorModule.cs"
                        int* csharp2cuda_temp_184 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_184));
                    }
                }
#line 372 "VectorModule.cs"
                if ((output)->valid)
#line 373 "VectorModule.cs"
                {
#line 374 "VectorModule.cs"
#line 374 "VectorModule.cs"
                    double* csharp2cuda_temp_190 = &((output)->scalar_value);
#line 375 "VectorModule.cs"
                    int csharp2cuda_temp_191 = (first)->count;
#line 375 "VectorModule.cs"
                    double csharp2cuda_temp_192 = mathblocks_compensated_sum(result, csharp2cuda_temp_191);
#line 375 "VectorModule.cs"
                    int csharp2cuda_temp_193 = (first)->count;
#line 375 "VectorModule.cs"
                    double csharp2cuda_temp_194 = __ddiv_rn(csharp2cuda_temp_192, ((double)(csharp2cuda_temp_193)));
                    (*(csharp2cuda_temp_190) = mathblocks_exponential(csharp2cuda_temp_194));
#line 376 "VectorModule.cs"
#line 376 "VectorModule.cs"
                    double csharp2cuda_temp_195 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_195))))
                    {
#line 376 "VectorModule.cs"
#line 376 "VectorModule.cs"
                        int* csharp2cuda_temp_196 = &((output)->valid);
                        (*(csharp2cuda_temp_196) = 0);
                    }
                }
            }
#line 379 "VectorModule.cs"
            break;
#line 380 "VectorModule.cs"
        case 16:
#line 381 "VectorModule.cs"
            if (((thread) == (0)))
#line 382 "VectorModule.cs"
            {
#line 383 "VectorModule.cs"
                int index = 0;
#line 384 "VectorModule.cs"
#line 384 "VectorModule.cs"
                double csharp2cuda_temp_197 = (second)->scalar_value;
#line 384 "VectorModule.cs"
                int* csharp2cuda_temp_198 = &(index);
#line 384 "VectorModule.cs"
                bool csharp2cuda_temp_199 = mathblocks_nonnegative_integer(csharp2cuda_temp_197, csharp2cuda_temp_198);
#line 384 "VectorModule.cs"
                bool csharp2cuda_temp_200;
#line 384 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_199))))
                {
#line 384 "VectorModule.cs"
                    int csharp2cuda_temp_201 = (first)->count;
#line 384 "VectorModule.cs"
                    csharp2cuda_temp_200 = ((index) >= (csharp2cuda_temp_201));
                }
                else
                {
#line 384 "VectorModule.cs"
                    csharp2cuda_temp_200 = true;
                }
                if (csharp2cuda_temp_200)
                {
#line 385 "VectorModule.cs"
#line 385 "VectorModule.cs"
                    int* csharp2cuda_temp_202 = &((output)->valid);
                    (*(csharp2cuda_temp_202) = 0);
                }
                else
                {
#line 387 "VectorModule.cs"
#line 387 "VectorModule.cs"
                    double* csharp2cuda_temp_203 = &((output)->scalar_value);
#line 387 "VectorModule.cs"
                    double csharp2cuda_temp_204 = (a)[index];
                    (*(csharp2cuda_temp_203) = csharp2cuda_temp_204);
                }
            }
#line 389 "VectorModule.cs"
            break;
#line 390 "VectorModule.cs"
        case 17:
        case 18:
#line 392 "VectorModule.cs"
            if (((thread) == (0)))
#line 393 "VectorModule.cs"
            {
#line 394 "VectorModule.cs"
                double csharp2cuda_temp_205;
#line 394 "VectorModule.cs"
                if (((opcode) == (17)))
                {
#line 395 "VectorModule.cs"
                    int csharp2cuda_temp_206 = (first)->count;
#line 394 "VectorModule.cs"
                    csharp2cuda_temp_205 = mathblocks_compensated_absolute_sum(a, csharp2cuda_temp_206);
                }
                else
                {
#line 396 "VectorModule.cs"
                    int csharp2cuda_temp_207 = (first)->count;
#line 396 "VectorModule.cs"
                    double csharp2cuda_temp_208 = mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_207);
#line 394 "VectorModule.cs"
                    csharp2cuda_temp_205 = mathblocks_square_root(csharp2cuda_temp_208);
                }
#line 394 "VectorModule.cs"
                double norm = csharp2cuda_temp_205;
#line 397 "VectorModule.cs"
#line 397 "VectorModule.cs"
                double* csharp2cuda_temp_209 = &((output)->scalar_value);
                (*(csharp2cuda_temp_209) = norm);
#line 398 "VectorModule.cs"
                if ((!(isfinite(norm))))
                {
#line 398 "VectorModule.cs"
#line 398 "VectorModule.cs"
                    int* csharp2cuda_temp_210 = &((output)->valid);
                    (*(csharp2cuda_temp_210) = 0);
                }
            }
#line 400 "VectorModule.cs"
            break;
#line 401 "VectorModule.cs"
        case 19:
#line 402 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 402 "VectorModule.cs"
#line 402 "VectorModule.cs"
                double* csharp2cuda_temp_211 = &((output)->scalar_value);
#line 402 "VectorModule.cs"
                int csharp2cuda_temp_212 = (first)->count;
                (*(csharp2cuda_temp_211) = ((double)(csharp2cuda_temp_212)));
            }
#line 403 "VectorModule.cs"
            break;
#line 404 "VectorModule.cs"
        case 21:
#line 405 "VectorModule.cs"
            if (((thread) == (0)))
#line 406 "VectorModule.cs"
            {
#line 407 "VectorModule.cs"
                int count = 0;
#line 408 "VectorModule.cs"
#line 408 "VectorModule.cs"
                double csharp2cuda_temp_213 = (third)->scalar_value;
#line 408 "VectorModule.cs"
                int* csharp2cuda_temp_214 = &(count);
#line 408 "VectorModule.cs"
                bool csharp2cuda_temp_215 = mathblocks_nonnegative_integer(csharp2cuda_temp_213, csharp2cuda_temp_214);
#line 408 "VectorModule.cs"
                bool csharp2cuda_temp_216;
#line 408 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_215))))
                {
#line 408 "VectorModule.cs"
                    csharp2cuda_temp_216 = ((count) <= (0));
                }
                else
                {
#line 408 "VectorModule.cs"
                    csharp2cuda_temp_216 = true;
                }
#line 408 "VectorModule.cs"
                bool csharp2cuda_temp_217;
#line 408 "VectorModule.cs"
                if (!(csharp2cuda_temp_216))
                {
#line 408 "VectorModule.cs"
                    csharp2cuda_temp_217 = ((count) > (1000000));
                }
                else
                {
#line 408 "VectorModule.cs"
                    csharp2cuda_temp_217 = true;
                }
                if (csharp2cuda_temp_217)
                {
#line 409 "VectorModule.cs"
#line 409 "VectorModule.cs"
                    int* csharp2cuda_temp_218 = &((output)->valid);
                    (*(csharp2cuda_temp_218) = 0);
                }
                else
                {
#line 411 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, count);
                }
            }
#line 413 "VectorModule.cs"
            __syncthreads();
#line 414 "VectorModule.cs"
            if ((output)->valid)
#line 415 "VectorModule.cs"
            {
#line 416 "VectorModule.cs"
                double start = (first)->scalar_value;
#line 417 "VectorModule.cs"
                double end = (second)->scalar_value;
#line 418 "VectorModule.cs"
                int csharp2cuda_temp_219 = (output)->count;
#line 418 "VectorModule.cs"
                double csharp2cuda_temp_220;
#line 418 "VectorModule.cs"
                if (((csharp2cuda_temp_219) == (1)))
                {
#line 418 "VectorModule.cs"
                    csharp2cuda_temp_220 = 0.0;
                }
                else
                {
#line 418 "VectorModule.cs"
                    int csharp2cuda_temp_221 = (output)->count;
#line 418 "VectorModule.cs"
                    csharp2cuda_temp_220 = __ddiv_rn(__dsub_rn(end, start), ((double)(csharp2cuda_i32_sub(csharp2cuda_temp_221, 1))));
                }
#line 418 "VectorModule.cs"
                double step = csharp2cuda_temp_220;
#line 419 "VectorModule.cs"
                {
#line 419 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 419 "VectorModule.cs"
                        int csharp2cuda_temp_224 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_224))))
                            break;
#line 420 "VectorModule.cs"
#line 420 "VectorModule.cs"
                        double* csharp2cuda_temp_225 = &((result)[index]);
#line 420 "VectorModule.cs"
                        int csharp2cuda_temp_226 = (output)->count;
#line 420 "VectorModule.cs"
                        double csharp2cuda_temp_227;
#line 420 "VectorModule.cs"
                        if (((index) == (csharp2cuda_i32_sub(csharp2cuda_temp_226, 1))))
                        {
#line 420 "VectorModule.cs"
                            csharp2cuda_temp_227 = end;
                        }
                        else
                        {
#line 420 "VectorModule.cs"
                            csharp2cuda_temp_227 = __dadd_rn(start, __dmul_rn(step, ((double)(index))));
                        }
                        (*(csharp2cuda_temp_225) = csharp2cuda_temp_227);
#line 419 "VectorModule.cs"
                        int* csharp2cuda_temp_222 = &(index);
#line 419 "VectorModule.cs"
                        int csharp2cuda_temp_223 = *(csharp2cuda_temp_222);
                        (*(csharp2cuda_temp_222) = csharp2cuda_i32_add(csharp2cuda_temp_223, blockDim.x));
                    }
                }
            }
#line 422 "VectorModule.cs"
            break;
#line 423 "VectorModule.cs"
        case 22:
        case 25:
#line 425 "VectorModule.cs"
            if (((thread) == (0)))
#line 426 "VectorModule.cs"
            {
#line 427 "VectorModule.cs"
#line 427 "VectorModule.cs"
                int csharp2cuda_temp_228 = (first)->count;
                if (((csharp2cuda_temp_228) <= (0)))
#line 428 "VectorModule.cs"
                {
#line 429 "VectorModule.cs"
#line 429 "VectorModule.cs"
                    int* csharp2cuda_temp_229 = &((output)->valid);
                    (*(csharp2cuda_temp_229) = 0);
#line 430 "VectorModule.cs"
                    break;
                }
#line 432 "VectorModule.cs"
                double selected = (a)[0];
#line 433 "VectorModule.cs"
                {
#line 433 "VectorModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 433 "VectorModule.cs"
                        int csharp2cuda_temp_231 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_231))))
                            break;
#line 434 "VectorModule.cs"
#line 434 "VectorModule.cs"
                        double* csharp2cuda_temp_232 = &(selected);
#line 434 "VectorModule.cs"
                        double csharp2cuda_temp_233;
#line 434 "VectorModule.cs"
                        if (((opcode) == (22)))
                        {
#line 435 "VectorModule.cs"
                            double csharp2cuda_temp_234 = (a)[index];
#line 434 "VectorModule.cs"
                            csharp2cuda_temp_233 = mathblocks_maximum(selected, csharp2cuda_temp_234);
                        }
                        else
                        {
#line 436 "VectorModule.cs"
                            double csharp2cuda_temp_235 = (a)[index];
#line 434 "VectorModule.cs"
                            csharp2cuda_temp_233 = mathblocks_minimum(selected, csharp2cuda_temp_235);
                        }
                        (*(csharp2cuda_temp_232) = csharp2cuda_temp_233);
#line 433 "VectorModule.cs"
                        int* csharp2cuda_temp_230 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_230));
                    }
                }
#line 437 "VectorModule.cs"
#line 437 "VectorModule.cs"
                double* csharp2cuda_temp_236 = &((output)->scalar_value);
                (*(csharp2cuda_temp_236) = selected);
            }
#line 439 "VectorModule.cs"
            break;
#line 440 "VectorModule.cs"
        case 23:
        case 48:
#line 442 "VectorModule.cs"
            if (((thread) == (0)))
#line 443 "VectorModule.cs"
            {
#line 444 "VectorModule.cs"
                int csharp2cuda_temp_237 = (first)->count;
#line 444 "VectorModule.cs"
                double sum = mathblocks_compensated_sum(a, csharp2cuda_temp_237);
#line 445 "VectorModule.cs"
#line 445 "VectorModule.cs"
                double* csharp2cuda_temp_238 = &((output)->scalar_value);
#line 445 "VectorModule.cs"
                double csharp2cuda_temp_239;
#line 445 "VectorModule.cs"
                if (((opcode) == (23)))
                {
#line 445 "VectorModule.cs"
                    int csharp2cuda_temp_240 = (first)->count;
#line 445 "VectorModule.cs"
                    csharp2cuda_temp_239 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_240)));
                }
                else
                {
#line 445 "VectorModule.cs"
                    csharp2cuda_temp_239 = sum;
                }
                (*(csharp2cuda_temp_238) = csharp2cuda_temp_239);
#line 446 "VectorModule.cs"
#line 446 "VectorModule.cs"
                double csharp2cuda_temp_241 = (output)->scalar_value;
                if ((!(isfinite(csharp2cuda_temp_241))))
                {
#line 446 "VectorModule.cs"
#line 446 "VectorModule.cs"
                    int* csharp2cuda_temp_242 = &((output)->valid);
                    (*(csharp2cuda_temp_242) = 0);
                }
            }
#line 448 "VectorModule.cs"
            break;
#line 449 "VectorModule.cs"
        case 24:
        case 35:
#line 451 "VectorModule.cs"
            if (((thread) == (0)))
#line 452 "VectorModule.cs"
            {
#line 453 "VectorModule.cs"
                double csharp2cuda_temp_243;
#line 453 "VectorModule.cs"
                if (((opcode) == (24)))
                {
#line 453 "VectorModule.cs"
                    csharp2cuda_temp_243 = 0.5;
                }
                else
                {
#line 453 "VectorModule.cs"
                    csharp2cuda_temp_243 = (second)->scalar_value;
                }
#line 453 "VectorModule.cs"
                double probability = csharp2cuda_temp_243;
#line 454 "VectorModule.cs"
#line 454 "VectorModule.cs"
                int csharp2cuda_temp_244 = (first)->count;
#line 454 "VectorModule.cs"
                bool csharp2cuda_temp_245;
#line 454 "VectorModule.cs"
                if (!(((csharp2cuda_temp_244) <= (0))))
                {
#line 454 "VectorModule.cs"
                    unsigned long long csharp2cuda_temp_246 = (output)->scratch_pointer;
#line 454 "VectorModule.cs"
                    csharp2cuda_temp_245 = ((csharp2cuda_temp_246) == (((unsigned long long)(0))));
                }
                else
                {
#line 454 "VectorModule.cs"
                    csharp2cuda_temp_245 = true;
                }
#line 454 "VectorModule.cs"
                bool csharp2cuda_temp_247;
#line 454 "VectorModule.cs"
                if (!(csharp2cuda_temp_245))
                {
#line 454 "VectorModule.cs"
                    csharp2cuda_temp_247 = ((probability) < (0.0));
                }
                else
                {
#line 454 "VectorModule.cs"
                    csharp2cuda_temp_247 = true;
                }
#line 454 "VectorModule.cs"
                bool csharp2cuda_temp_248;
#line 454 "VectorModule.cs"
                if (!(csharp2cuda_temp_247))
                {
#line 454 "VectorModule.cs"
                    csharp2cuda_temp_248 = ((probability) > (1.0));
                }
                else
                {
#line 454 "VectorModule.cs"
                    csharp2cuda_temp_248 = true;
                }
                if (csharp2cuda_temp_248)
                {
#line 456 "VectorModule.cs"
#line 456 "VectorModule.cs"
                    int* csharp2cuda_temp_249 = &((output)->valid);
                    (*(csharp2cuda_temp_249) = 0);
                }
                else
#line 458 "VectorModule.cs"
                {
#line 459 "VectorModule.cs"
#line 459 "VectorModule.cs"
                    double* csharp2cuda_temp_250 = &((output)->scalar_value);
#line 459 "VectorModule.cs"
                    double csharp2cuda_temp_251 = mathblocks_quantile(first, output, probability);
                    (*(csharp2cuda_temp_250) = csharp2cuda_temp_251);
#line 460 "VectorModule.cs"
#line 460 "VectorModule.cs"
                    double csharp2cuda_temp_252 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_252))))
                    {
#line 460 "VectorModule.cs"
#line 460 "VectorModule.cs"
                        int* csharp2cuda_temp_253 = &((output)->valid);
                        (*(csharp2cuda_temp_253) = 0);
                    }
                }
            }
#line 463 "VectorModule.cs"
            break;
#line 464 "VectorModule.cs"
        case 28:
        case 29:
#line 466 "VectorModule.cs"
            if (((thread) == (0)))
#line 467 "VectorModule.cs"
            {
#line 468 "VectorModule.cs"
#line 468 "VectorModule.cs"
                int csharp2cuda_temp_254 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_254);
#line 469 "VectorModule.cs"
#line 469 "VectorModule.cs"
                double* csharp2cuda_temp_255 = &((output)->scalar_value);
#line 469 "VectorModule.cs"
                double csharp2cuda_temp_256;
#line 469 "VectorModule.cs"
                if (((opcode) == (28)))
                {
#line 470 "VectorModule.cs"
                    int csharp2cuda_temp_257 = (first)->count;
#line 469 "VectorModule.cs"
                    csharp2cuda_temp_256 = mathblocks_compensated_absolute_sum(a, csharp2cuda_temp_257);
                }
                else
                {
#line 471 "VectorModule.cs"
                    int csharp2cuda_temp_258 = (first)->count;
#line 471 "VectorModule.cs"
                    double csharp2cuda_temp_259 = mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_258);
#line 469 "VectorModule.cs"
                    csharp2cuda_temp_256 = mathblocks_square_root(csharp2cuda_temp_259);
                }
                (*(csharp2cuda_temp_255) = csharp2cuda_temp_256);
#line 472 "VectorModule.cs"
#line 472 "VectorModule.cs"
                double csharp2cuda_temp_260 = (output)->scalar_value;
#line 472 "VectorModule.cs"
                bool csharp2cuda_temp_261;
#line 472 "VectorModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_260)))))
                {
#line 472 "VectorModule.cs"
                    double csharp2cuda_temp_262 = (output)->scalar_value;
#line 472 "VectorModule.cs"
                    csharp2cuda_temp_261 = ((csharp2cuda_temp_262) == (0.0));
                }
                else
                {
#line 472 "VectorModule.cs"
                    csharp2cuda_temp_261 = true;
                }
                if (csharp2cuda_temp_261)
                {
#line 472 "VectorModule.cs"
#line 472 "VectorModule.cs"
                    int* csharp2cuda_temp_263 = &((output)->valid);
                    (*(csharp2cuda_temp_263) = 0);
                }
            }
#line 474 "VectorModule.cs"
            __syncthreads();
#line 475 "VectorModule.cs"
            {
#line 475 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 475 "VectorModule.cs"
                    bool csharp2cuda_temp_266 = (output)->valid;
#line 475 "VectorModule.cs"
                    bool csharp2cuda_temp_267;
#line 475 "VectorModule.cs"
                    if (csharp2cuda_temp_266)
                    {
#line 475 "VectorModule.cs"
                        int csharp2cuda_temp_268 = (first)->count;
#line 475 "VectorModule.cs"
                        csharp2cuda_temp_267 = ((index) < (csharp2cuda_temp_268));
                    }
                    else
                    {
#line 475 "VectorModule.cs"
                        csharp2cuda_temp_267 = false;
                    }
                    if (!(csharp2cuda_temp_267))
                        break;
#line 476 "VectorModule.cs"
                    {
#line 477 "VectorModule.cs"
#line 477 "VectorModule.cs"
                        double* csharp2cuda_temp_269 = &((result)[index]);
#line 477 "VectorModule.cs"
                        double csharp2cuda_temp_270 = (a)[index];
#line 477 "VectorModule.cs"
                        double csharp2cuda_temp_271 = (output)->scalar_value;
#line 477 "VectorModule.cs"
                        double csharp2cuda_temp_272 = __ddiv_rn(1.0, csharp2cuda_temp_271);
                        (*(csharp2cuda_temp_269) = __dmul_rn(csharp2cuda_temp_270, csharp2cuda_temp_272));
#line 478 "VectorModule.cs"
#line 478 "VectorModule.cs"
                        double csharp2cuda_temp_273 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_273))))
                        {
#line 478 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 475 "VectorModule.cs"
                    int* csharp2cuda_temp_264 = &(index);
#line 475 "VectorModule.cs"
                    int csharp2cuda_temp_265 = *(csharp2cuda_temp_264);
                    (*(csharp2cuda_temp_264) = csharp2cuda_i32_add(csharp2cuda_temp_265, blockDim.x));
                }
            }
#line 480 "VectorModule.cs"
            break;
#line 481 "VectorModule.cs"
        case 30:
#line 482 "VectorModule.cs"
            if (((thread) == (0)))
#line 483 "VectorModule.cs"
            {
#line 484 "VectorModule.cs"
                mathblocks_set_vector_shape(output, 2);
#line 485 "VectorModule.cs"
                if ((output)->valid)
#line 486 "VectorModule.cs"
                {
#line 487 "VectorModule.cs"
#line 487 "VectorModule.cs"
                    double* csharp2cuda_temp_274 = &((result)[0]);
#line 487 "VectorModule.cs"
                    double csharp2cuda_temp_275 = (first)->scalar_value;
                    (*(csharp2cuda_temp_274) = csharp2cuda_temp_275);
#line 488 "VectorModule.cs"
#line 488 "VectorModule.cs"
                    double* csharp2cuda_temp_276 = &((result)[1]);
#line 488 "VectorModule.cs"
                    double csharp2cuda_temp_277 = (second)->scalar_value;
                    (*(csharp2cuda_temp_276) = csharp2cuda_temp_277);
                }
            }
#line 491 "VectorModule.cs"
            break;
#line 492 "VectorModule.cs"
        case 31:
        case 41:
        case 45:
#line 495 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 495 "VectorModule.cs"
#line 495 "VectorModule.cs"
                int csharp2cuda_temp_278 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_278);
            }
#line 496 "VectorModule.cs"
            __syncthreads();
#line 497 "VectorModule.cs"
            {
#line 497 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 497 "VectorModule.cs"
                    bool csharp2cuda_temp_281 = (output)->valid;
#line 497 "VectorModule.cs"
                    bool csharp2cuda_temp_282;
#line 497 "VectorModule.cs"
                    if (csharp2cuda_temp_281)
                    {
#line 497 "VectorModule.cs"
                        int csharp2cuda_temp_283 = (first)->count;
#line 497 "VectorModule.cs"
                        csharp2cuda_temp_282 = ((index) < (csharp2cuda_temp_283));
                    }
                    else
                    {
#line 497 "VectorModule.cs"
                        csharp2cuda_temp_282 = false;
                    }
                    if (!(csharp2cuda_temp_282))
                        break;
#line 498 "VectorModule.cs"
                    {
#line 499 "VectorModule.cs"
                        double csharp2cuda_temp_284;
#line 499 "VectorModule.cs"
                        if (((opcode) == (31)))
                        {
#line 499 "VectorModule.cs"
                            double csharp2cuda_temp_285 = (a)[index];
#line 499 "VectorModule.cs"
                            csharp2cuda_temp_284 = mathblocks_maximum(csharp2cuda_temp_285, 0.0);
                        }
                        else
                        {
#line 500 "VectorModule.cs"
                            double csharp2cuda_temp_286;
#line 500 "VectorModule.cs"
                            if (((opcode) == (41)))
                            {
#line 500 "VectorModule.cs"
                                double csharp2cuda_temp_287 = (a)[index];
#line 500 "VectorModule.cs"
                                double csharp2cuda_temp_288 = (a)[index];
#line 500 "VectorModule.cs"
                                csharp2cuda_temp_286 = ((double)(csharp2cuda_i32_sub(((((csharp2cuda_temp_287) > (0.0))) ? 1 : 0), ((((csharp2cuda_temp_288) < (0.0))) ? 1 : 0))));
                            }
                            else
                            {
#line 501 "VectorModule.cs"
                                double csharp2cuda_temp_289 = (a)[index];
#line 501 "VectorModule.cs"
                                double csharp2cuda_temp_290 = (a)[index];
#line 500 "VectorModule.cs"
                                csharp2cuda_temp_286 = __dmul_rn(csharp2cuda_temp_289, csharp2cuda_temp_290);
                            }
#line 499 "VectorModule.cs"
                            csharp2cuda_temp_284 = csharp2cuda_temp_286;
                        }
#line 499 "VectorModule.cs"
                        double value = csharp2cuda_temp_284;
#line 502 "VectorModule.cs"
#line 502 "VectorModule.cs"
                        double* csharp2cuda_temp_291 = &((result)[index]);
                        (*(csharp2cuda_temp_291) = value);
#line 503 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 503 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 497 "VectorModule.cs"
                    int* csharp2cuda_temp_279 = &(index);
#line 497 "VectorModule.cs"
                    int csharp2cuda_temp_280 = *(csharp2cuda_temp_279);
                    (*(csharp2cuda_temp_279) = csharp2cuda_i32_add(csharp2cuda_temp_280, blockDim.x));
                }
            }
#line 505 "VectorModule.cs"
            break;
#line 506 "VectorModule.cs"
        case 32:
#line 507 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 507 "VectorModule.cs"
#line 507 "VectorModule.cs"
                int csharp2cuda_temp_292 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_292);
            }
#line 508 "VectorModule.cs"
            __syncthreads();
#line 509 "VectorModule.cs"
            {
#line 509 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 509 "VectorModule.cs"
                    bool csharp2cuda_temp_295 = (output)->valid;
#line 509 "VectorModule.cs"
                    bool csharp2cuda_temp_296;
#line 509 "VectorModule.cs"
                    if (csharp2cuda_temp_295)
                    {
#line 509 "VectorModule.cs"
                        int csharp2cuda_temp_297 = (first)->count;
#line 509 "VectorModule.cs"
                        csharp2cuda_temp_296 = ((index) < (csharp2cuda_temp_297));
                    }
                    else
                    {
#line 509 "VectorModule.cs"
                        csharp2cuda_temp_296 = false;
                    }
                    if (!(csharp2cuda_temp_296))
                        break;
#line 510 "VectorModule.cs"
                    {
#line 511 "VectorModule.cs"
#line 511 "VectorModule.cs"
                        double* csharp2cuda_temp_298 = &((result)[index]);
#line 511 "VectorModule.cs"
                        double csharp2cuda_temp_299 = (a)[index];
#line 511 "VectorModule.cs"
                        double csharp2cuda_temp_300 = (second)->scalar_value;
                        (*(csharp2cuda_temp_298) = mathblocks_power(csharp2cuda_temp_299, csharp2cuda_temp_300));
#line 512 "VectorModule.cs"
#line 512 "VectorModule.cs"
                        double csharp2cuda_temp_301 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_301))))
                        {
#line 512 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 509 "VectorModule.cs"
                    int* csharp2cuda_temp_293 = &(index);
#line 509 "VectorModule.cs"
                    int csharp2cuda_temp_294 = *(csharp2cuda_temp_293);
                    (*(csharp2cuda_temp_293) = csharp2cuda_i32_add(csharp2cuda_temp_294, blockDim.x));
                }
            }
#line 514 "VectorModule.cs"
            break;
#line 515 "VectorModule.cs"
        case 33:
#line 516 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 516 "VectorModule.cs"
#line 516 "VectorModule.cs"
                int csharp2cuda_temp_302 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_302, 1));
            }
#line 517 "VectorModule.cs"
            __syncthreads();
#line 518 "VectorModule.cs"
#line 518 "VectorModule.cs"
            bool csharp2cuda_temp_303;
#line 518 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 518 "VectorModule.cs"
                csharp2cuda_temp_303 = (output)->valid;
            }
            else
            {
#line 518 "VectorModule.cs"
                csharp2cuda_temp_303 = false;
            }
            if (csharp2cuda_temp_303)
            {
#line 518 "VectorModule.cs"
#line 518 "VectorModule.cs"
                double* csharp2cuda_temp_304 = &((result)[0]);
#line 518 "VectorModule.cs"
                double csharp2cuda_temp_305 = (second)->scalar_value;
                (*(csharp2cuda_temp_304) = csharp2cuda_temp_305);
            }
#line 519 "VectorModule.cs"
            {
#line 519 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 519 "VectorModule.cs"
                    bool csharp2cuda_temp_308 = (output)->valid;
#line 519 "VectorModule.cs"
                    bool csharp2cuda_temp_309;
#line 519 "VectorModule.cs"
                    if (csharp2cuda_temp_308)
                    {
#line 519 "VectorModule.cs"
                        int csharp2cuda_temp_310 = (first)->count;
#line 519 "VectorModule.cs"
                        csharp2cuda_temp_309 = ((index) < (csharp2cuda_temp_310));
                    }
                    else
                    {
#line 519 "VectorModule.cs"
                        csharp2cuda_temp_309 = false;
                    }
                    if (!(csharp2cuda_temp_309))
                        break;
#line 520 "VectorModule.cs"
#line 520 "VectorModule.cs"
                    double* csharp2cuda_temp_311 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 520 "VectorModule.cs"
                    double csharp2cuda_temp_312 = (a)[index];
                    (*(csharp2cuda_temp_311) = csharp2cuda_temp_312);
#line 519 "VectorModule.cs"
                    int* csharp2cuda_temp_306 = &(index);
#line 519 "VectorModule.cs"
                    int csharp2cuda_temp_307 = *(csharp2cuda_temp_306);
                    (*(csharp2cuda_temp_306) = csharp2cuda_i32_add(csharp2cuda_temp_307, blockDim.x));
                }
            }
#line 521 "VectorModule.cs"
            break;
#line 522 "VectorModule.cs"
        case 34:
#line 523 "VectorModule.cs"
            if (((thread) == (0)))
#line 524 "VectorModule.cs"
            {
#line 525 "VectorModule.cs"
                double product = 1.0;
#line 526 "VectorModule.cs"
                {
#line 526 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 526 "VectorModule.cs"
                        int csharp2cuda_temp_314 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_314))))
                            break;
#line 526 "VectorModule.cs"
#line 526 "VectorModule.cs"
                        double* csharp2cuda_temp_315 = &(product);
#line 526 "VectorModule.cs"
                        double csharp2cuda_temp_316 = *(csharp2cuda_temp_315);
#line 526 "VectorModule.cs"
                        double csharp2cuda_temp_317 = (a)[index];
                        (*(csharp2cuda_temp_315) = __dmul_rn(csharp2cuda_temp_316, csharp2cuda_temp_317));
#line 526 "VectorModule.cs"
                        int* csharp2cuda_temp_313 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_313));
                    }
                }
#line 527 "VectorModule.cs"
#line 527 "VectorModule.cs"
                double* csharp2cuda_temp_318 = &((output)->scalar_value);
                (*(csharp2cuda_temp_318) = product);
#line 528 "VectorModule.cs"
                if ((!(isfinite(product))))
                {
#line 528 "VectorModule.cs"
#line 528 "VectorModule.cs"
                    int* csharp2cuda_temp_319 = &((output)->valid);
                    (*(csharp2cuda_temp_319) = 0);
                }
            }
#line 530 "VectorModule.cs"
            break;
#line 531 "VectorModule.cs"
        case 36:
#line 532 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 532 "VectorModule.cs"
#line 532 "VectorModule.cs"
                int csharp2cuda_temp_320 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_320);
            }
#line 533 "VectorModule.cs"
            __syncthreads();
#line 534 "VectorModule.cs"
            {
#line 534 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 534 "VectorModule.cs"
                    bool csharp2cuda_temp_323 = (output)->valid;
#line 534 "VectorModule.cs"
                    bool csharp2cuda_temp_324;
#line 534 "VectorModule.cs"
                    if (csharp2cuda_temp_323)
                    {
#line 534 "VectorModule.cs"
                        int csharp2cuda_temp_325 = (first)->count;
#line 534 "VectorModule.cs"
                        csharp2cuda_temp_324 = ((index) < (csharp2cuda_temp_325));
                    }
                    else
                    {
#line 534 "VectorModule.cs"
                        csharp2cuda_temp_324 = false;
                    }
                    if (!(csharp2cuda_temp_324))
                        break;
#line 535 "VectorModule.cs"
                    {
#line 536 "VectorModule.cs"
                        int less = 0;
#line 537 "VectorModule.cs"
                        int equal = 0;
#line 538 "VectorModule.cs"
                        {
#line 538 "VectorModule.cs"
                            int other = 0;
                            while (true)
                            {
#line 538 "VectorModule.cs"
                                int csharp2cuda_temp_327 = (first)->count;
                                if (!(((other) < (csharp2cuda_temp_327))))
                                    break;
#line 539 "VectorModule.cs"
                                {
#line 540 "VectorModule.cs"
#line 540 "VectorModule.cs"
                                    double csharp2cuda_temp_328 = (a)[other];
#line 540 "VectorModule.cs"
                                    double csharp2cuda_temp_329 = (a)[index];
                                    if (((csharp2cuda_temp_328) < (csharp2cuda_temp_329)))
                                    {
#line 540 "VectorModule.cs"
#line 540 "VectorModule.cs"
                                        int* csharp2cuda_temp_330 = &(less);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_330));
                                    }
                                    else
                                    {
#line 541 "VectorModule.cs"
#line 541 "VectorModule.cs"
                                        double csharp2cuda_temp_331 = (a)[other];
#line 541 "VectorModule.cs"
                                        double csharp2cuda_temp_332 = (a)[index];
                                        if (((csharp2cuda_temp_331) == (csharp2cuda_temp_332)))
                                        {
#line 541 "VectorModule.cs"
#line 541 "VectorModule.cs"
                                            int* csharp2cuda_temp_333 = &(equal);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_333));
                                        }
                                    }
                                }
#line 538 "VectorModule.cs"
                                int* csharp2cuda_temp_326 = &(other);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_326));
                            }
                        }
#line 543 "VectorModule.cs"
#line 543 "VectorModule.cs"
                        double* csharp2cuda_temp_334 = &((result)[index]);
#line 543 "VectorModule.cs"
                        double csharp2cuda_temp_335 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
                        (*(csharp2cuda_temp_334) = __dadd_rn(((double)(less)), csharp2cuda_temp_335));
                    }
#line 534 "VectorModule.cs"
                    int* csharp2cuda_temp_321 = &(index);
#line 534 "VectorModule.cs"
                    int csharp2cuda_temp_322 = *(csharp2cuda_temp_321);
                    (*(csharp2cuda_temp_321) = csharp2cuda_i32_add(csharp2cuda_temp_322, blockDim.x));
                }
            }
#line 545 "VectorModule.cs"
            break;
#line 546 "VectorModule.cs"
        case 37:
#line 547 "VectorModule.cs"
            if (((thread) == (0)))
#line 548 "VectorModule.cs"
            {
#line 549 "VectorModule.cs"
                int count = 0;
#line 550 "VectorModule.cs"
#line 550 "VectorModule.cs"
                double csharp2cuda_temp_336 = (second)->scalar_value;
#line 550 "VectorModule.cs"
                int* csharp2cuda_temp_337 = &(count);
#line 550 "VectorModule.cs"
                bool csharp2cuda_temp_338 = mathblocks_nonnegative_integer(csharp2cuda_temp_336, csharp2cuda_temp_337);
#line 550 "VectorModule.cs"
                bool csharp2cuda_temp_339;
#line 550 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_338))))
                {
#line 550 "VectorModule.cs"
                    csharp2cuda_temp_339 = ((count) > (1000000));
                }
                else
                {
#line 550 "VectorModule.cs"
                    csharp2cuda_temp_339 = true;
                }
                if (csharp2cuda_temp_339)
                {
#line 551 "VectorModule.cs"
#line 551 "VectorModule.cs"
                    int* csharp2cuda_temp_340 = &((output)->valid);
                    (*(csharp2cuda_temp_340) = 0);
                }
                else
                {
#line 553 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, count);
                }
            }
#line 555 "VectorModule.cs"
            __syncthreads();
#line 556 "VectorModule.cs"
            {
#line 556 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 556 "VectorModule.cs"
                    bool csharp2cuda_temp_343 = (output)->valid;
#line 556 "VectorModule.cs"
                    bool csharp2cuda_temp_344;
#line 556 "VectorModule.cs"
                    if (csharp2cuda_temp_343)
                    {
#line 556 "VectorModule.cs"
                        int csharp2cuda_temp_345 = (output)->count;
#line 556 "VectorModule.cs"
                        csharp2cuda_temp_344 = ((index) < (csharp2cuda_temp_345));
                    }
                    else
                    {
#line 556 "VectorModule.cs"
                        csharp2cuda_temp_344 = false;
                    }
                    if (!(csharp2cuda_temp_344))
                        break;
#line 557 "VectorModule.cs"
#line 557 "VectorModule.cs"
                    double* csharp2cuda_temp_346 = &((result)[index]);
#line 557 "VectorModule.cs"
                    double csharp2cuda_temp_347 = (first)->scalar_value;
                    (*(csharp2cuda_temp_346) = csharp2cuda_temp_347);
#line 556 "VectorModule.cs"
                    int* csharp2cuda_temp_341 = &(index);
#line 556 "VectorModule.cs"
                    int csharp2cuda_temp_342 = *(csharp2cuda_temp_341);
                    (*(csharp2cuda_temp_341) = csharp2cuda_i32_add(csharp2cuda_temp_342, blockDim.x));
                }
            }
#line 558 "VectorModule.cs"
            break;
#line 559 "VectorModule.cs"
        case 38:
#line 560 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 560 "VectorModule.cs"
#line 560 "VectorModule.cs"
                int csharp2cuda_temp_348 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_348);
            }
#line 561 "VectorModule.cs"
            __syncthreads();
#line 562 "VectorModule.cs"
            {
#line 562 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 562 "VectorModule.cs"
                    bool csharp2cuda_temp_351 = (output)->valid;
#line 562 "VectorModule.cs"
                    bool csharp2cuda_temp_352;
#line 562 "VectorModule.cs"
                    if (csharp2cuda_temp_351)
                    {
#line 562 "VectorModule.cs"
                        int csharp2cuda_temp_353 = (first)->count;
#line 562 "VectorModule.cs"
                        csharp2cuda_temp_352 = ((index) < (csharp2cuda_temp_353));
                    }
                    else
                    {
#line 562 "VectorModule.cs"
                        csharp2cuda_temp_352 = false;
                    }
                    if (!(csharp2cuda_temp_352))
                        break;
#line 563 "VectorModule.cs"
#line 563 "VectorModule.cs"
                    double* csharp2cuda_temp_354 = &((result)[index]);
#line 563 "VectorModule.cs"
                    int csharp2cuda_temp_355 = (first)->count;
#line 563 "VectorModule.cs"
                    double csharp2cuda_temp_356 = (a)[csharp2cuda_i32_sub(csharp2cuda_i32_sub(csharp2cuda_temp_355, index), 1)];
                    (*(csharp2cuda_temp_354) = csharp2cuda_temp_356);
#line 562 "VectorModule.cs"
                    int* csharp2cuda_temp_349 = &(index);
#line 562 "VectorModule.cs"
                    int csharp2cuda_temp_350 = *(csharp2cuda_temp_349);
                    (*(csharp2cuda_temp_349) = csharp2cuda_i32_add(csharp2cuda_temp_350, blockDim.x));
                }
            }
#line 564 "VectorModule.cs"
            break;
#line 565 "VectorModule.cs"
        case 39:
#line 566 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 566 "VectorModule.cs"
#line 566 "VectorModule.cs"
                int csharp2cuda_temp_357 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_357);
            }
#line 567 "VectorModule.cs"
            __syncthreads();
#line 568 "VectorModule.cs"
            {
#line 568 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 568 "VectorModule.cs"
                    bool csharp2cuda_temp_360 = (output)->valid;
#line 568 "VectorModule.cs"
                    bool csharp2cuda_temp_361;
#line 568 "VectorModule.cs"
                    if (csharp2cuda_temp_360)
                    {
#line 568 "VectorModule.cs"
                        int csharp2cuda_temp_362 = (first)->count;
#line 568 "VectorModule.cs"
                        csharp2cuda_temp_361 = ((index) < (csharp2cuda_temp_362));
                    }
                    else
                    {
#line 568 "VectorModule.cs"
                        csharp2cuda_temp_361 = false;
                    }
                    if (!(csharp2cuda_temp_361))
                        break;
#line 569 "VectorModule.cs"
                    {
#line 570 "VectorModule.cs"
#line 570 "VectorModule.cs"
                        double* csharp2cuda_temp_363 = &((result)[index]);
#line 570 "VectorModule.cs"
                        double csharp2cuda_temp_364 = (a)[index];
#line 570 "VectorModule.cs"
                        double csharp2cuda_temp_365 = (second)->scalar_value;
                        (*(csharp2cuda_temp_363) = __dmul_rn(csharp2cuda_temp_364, csharp2cuda_temp_365));
#line 571 "VectorModule.cs"
#line 571 "VectorModule.cs"
                        double csharp2cuda_temp_366 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_366))))
                        {
#line 571 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 568 "VectorModule.cs"
                    int* csharp2cuda_temp_358 = &(index);
#line 568 "VectorModule.cs"
                    int csharp2cuda_temp_359 = *(csharp2cuda_temp_358);
                    (*(csharp2cuda_temp_358) = csharp2cuda_i32_add(csharp2cuda_temp_359, blockDim.x));
                }
            }
#line 573 "VectorModule.cs"
            break;
#line 574 "VectorModule.cs"
        case 40:
#line 575 "VectorModule.cs"
            if (((thread) == (0)))
#line 576 "VectorModule.cs"
            {
#line 577 "VectorModule.cs"
#line 577 "VectorModule.cs"
                int csharp2cuda_temp_367 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_367);
#line 578 "VectorModule.cs"
#line 578 "VectorModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
#line 578 "VectorModule.cs"
                int csharp2cuda_temp_369 = (second)->count;
#line 578 "VectorModule.cs"
                bool csharp2cuda_temp_370;
#line 578 "VectorModule.cs"
                if (!(((csharp2cuda_temp_368) != (csharp2cuda_temp_369))))
                {
#line 578 "VectorModule.cs"
                    int csharp2cuda_temp_371 = (first)->count;
#line 578 "VectorModule.cs"
                    int csharp2cuda_temp_372 = (third)->count;
#line 578 "VectorModule.cs"
                    csharp2cuda_temp_370 = ((csharp2cuda_temp_371) != (csharp2cuda_temp_372));
                }
                else
                {
#line 578 "VectorModule.cs"
                    csharp2cuda_temp_370 = true;
                }
                if (csharp2cuda_temp_370)
                {
#line 578 "VectorModule.cs"
#line 578 "VectorModule.cs"
                    int* csharp2cuda_temp_373 = &((output)->valid);
                    (*(csharp2cuda_temp_373) = 0);
                }
            }
#line 580 "VectorModule.cs"
            __syncthreads();
#line 581 "VectorModule.cs"
            {
#line 581 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 581 "VectorModule.cs"
                    bool csharp2cuda_temp_376 = (output)->valid;
#line 581 "VectorModule.cs"
                    bool csharp2cuda_temp_377;
#line 581 "VectorModule.cs"
                    if (csharp2cuda_temp_376)
                    {
#line 581 "VectorModule.cs"
                        int csharp2cuda_temp_378 = (first)->count;
#line 581 "VectorModule.cs"
                        csharp2cuda_temp_377 = ((index) < (csharp2cuda_temp_378));
                    }
                    else
                    {
#line 581 "VectorModule.cs"
                        csharp2cuda_temp_377 = false;
                    }
                    if (!(csharp2cuda_temp_377))
                        break;
#line 582 "VectorModule.cs"
#line 582 "VectorModule.cs"
                    double* csharp2cuda_temp_379 = &((result)[index]);
#line 582 "VectorModule.cs"
                    bool csharp2cuda_temp_380 = (boolean_a)[index];
#line 582 "VectorModule.cs"
                    double csharp2cuda_temp_381;
#line 582 "VectorModule.cs"
                    if (csharp2cuda_temp_380)
                    {
#line 582 "VectorModule.cs"
                        csharp2cuda_temp_381 = (b)[index];
                    }
                    else
                    {
#line 582 "VectorModule.cs"
                        csharp2cuda_temp_381 = (c)[index];
                    }
                    (*(csharp2cuda_temp_379) = csharp2cuda_temp_381);
#line 581 "VectorModule.cs"
                    int* csharp2cuda_temp_374 = &(index);
#line 581 "VectorModule.cs"
                    int csharp2cuda_temp_375 = *(csharp2cuda_temp_374);
                    (*(csharp2cuda_temp_374) = csharp2cuda_i32_add(csharp2cuda_temp_375, blockDim.x));
                }
            }
#line 583 "VectorModule.cs"
            break;
#line 584 "VectorModule.cs"
        case 42:
#line 585 "VectorModule.cs"
            if (((thread) == (0)))
#line 586 "VectorModule.cs"
            {
#line 587 "VectorModule.cs"
                int start = 0;
#line 588 "VectorModule.cs"
                int length = 0;
#line 589 "VectorModule.cs"
#line 589 "VectorModule.cs"
                double csharp2cuda_temp_382 = (second)->scalar_value;
#line 589 "VectorModule.cs"
                int* csharp2cuda_temp_383 = &(start);
#line 589 "VectorModule.cs"
                bool csharp2cuda_temp_384 = mathblocks_nonnegative_integer(csharp2cuda_temp_382, csharp2cuda_temp_383);
#line 589 "VectorModule.cs"
                bool csharp2cuda_temp_385;
#line 589 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_384))))
                {
#line 590 "VectorModule.cs"
                    double csharp2cuda_temp_386 = (third)->scalar_value;
#line 590 "VectorModule.cs"
                    int* csharp2cuda_temp_387 = &(length);
#line 590 "VectorModule.cs"
                    bool csharp2cuda_temp_388 = mathblocks_nonnegative_integer(csharp2cuda_temp_386, csharp2cuda_temp_387);
#line 589 "VectorModule.cs"
                    csharp2cuda_temp_385 = (!(csharp2cuda_temp_388));
                }
                else
                {
#line 589 "VectorModule.cs"
                    csharp2cuda_temp_385 = true;
                }
#line 589 "VectorModule.cs"
                bool csharp2cuda_temp_389;
#line 589 "VectorModule.cs"
                if (!(csharp2cuda_temp_385))
                {
#line 591 "VectorModule.cs"
                    int csharp2cuda_temp_390 = (first)->count;
#line 589 "VectorModule.cs"
                    csharp2cuda_temp_389 = ((start) > (csharp2cuda_temp_390));
                }
                else
                {
#line 589 "VectorModule.cs"
                    csharp2cuda_temp_389 = true;
                }
#line 589 "VectorModule.cs"
                bool csharp2cuda_temp_391;
#line 589 "VectorModule.cs"
                if (!(csharp2cuda_temp_389))
                {
#line 591 "VectorModule.cs"
                    int csharp2cuda_temp_392 = (first)->count;
#line 589 "VectorModule.cs"
                    csharp2cuda_temp_391 = ((length) > (csharp2cuda_i32_sub(csharp2cuda_temp_392, start)));
                }
                else
                {
#line 589 "VectorModule.cs"
                    csharp2cuda_temp_391 = true;
                }
                if (csharp2cuda_temp_391)
                {
#line 592 "VectorModule.cs"
#line 592 "VectorModule.cs"
                    int* csharp2cuda_temp_393 = &((output)->valid);
                    (*(csharp2cuda_temp_393) = 0);
                }
                else
                {
#line 594 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, length);
                }
            }
#line 596 "VectorModule.cs"
            __syncthreads();
#line 597 "VectorModule.cs"
            if ((output)->valid)
#line 598 "VectorModule.cs"
            {
#line 599 "VectorModule.cs"
                double csharp2cuda_temp_394 = (second)->scalar_value;
#line 599 "VectorModule.cs"
                int start = csharp2cuda_f64_to_i32(csharp2cuda_temp_394);
#line 600 "VectorModule.cs"
                {
#line 600 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 600 "VectorModule.cs"
                        int csharp2cuda_temp_397 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_397))))
                            break;
#line 601 "VectorModule.cs"
#line 601 "VectorModule.cs"
                        double* csharp2cuda_temp_398 = &((result)[index]);
#line 601 "VectorModule.cs"
                        double csharp2cuda_temp_399 = (a)[csharp2cuda_i32_add(start, index)];
                        (*(csharp2cuda_temp_398) = csharp2cuda_temp_399);
#line 600 "VectorModule.cs"
                        int* csharp2cuda_temp_395 = &(index);
#line 600 "VectorModule.cs"
                        int csharp2cuda_temp_396 = *(csharp2cuda_temp_395);
                        (*(csharp2cuda_temp_395) = csharp2cuda_i32_add(csharp2cuda_temp_396, blockDim.x));
                    }
                }
            }
#line 603 "VectorModule.cs"
            break;
#line 604 "VectorModule.cs"
        case 43:
#line 605 "VectorModule.cs"
            if (((thread) == (0)))
#line 606 "VectorModule.cs"
            {
#line 607 "VectorModule.cs"
#line 607 "VectorModule.cs"
                int csharp2cuda_temp_400 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_400);
#line 608 "VectorModule.cs"
                if ((output)->valid)
                {
#line 608 "VectorModule.cs"
                    mathblocks_copy_and_sort(first, output);
                }
            }
#line 610 "VectorModule.cs"
            break;
#line 611 "VectorModule.cs"
        case 46:
#line 612 "VectorModule.cs"
            if (((thread) == (0)))
#line 613 "VectorModule.cs"
            {
#line 614 "VectorModule.cs"
#line 614 "VectorModule.cs"
                int csharp2cuda_temp_401 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_401);
#line 615 "VectorModule.cs"
#line 615 "VectorModule.cs"
                bool csharp2cuda_temp_402 = (output)->valid;
#line 615 "VectorModule.cs"
                bool csharp2cuda_temp_403;
#line 615 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_402))))
                {
#line 615 "VectorModule.cs"
                    int csharp2cuda_temp_404 = (first)->count;
#line 615 "VectorModule.cs"
                    csharp2cuda_temp_403 = ((csharp2cuda_temp_404) <= (0));
                }
                else
                {
#line 615 "VectorModule.cs"
                    csharp2cuda_temp_403 = true;
                }
                if (csharp2cuda_temp_403)
#line 616 "VectorModule.cs"
                {
#line 617 "VectorModule.cs"
#line 617 "VectorModule.cs"
                    int* csharp2cuda_temp_405 = &((output)->valid);
                    (*(csharp2cuda_temp_405) = 0);
#line 618 "VectorModule.cs"
                    break;
                }
#line 620 "VectorModule.cs"
                int csharp2cuda_temp_406 = (first)->count;
#line 620 "VectorModule.cs"
                double csharp2cuda_temp_407 = mathblocks_compensated_sum(a, csharp2cuda_temp_406);
#line 620 "VectorModule.cs"
                int csharp2cuda_temp_408 = (first)->count;
#line 620 "VectorModule.cs"
                double mean = __ddiv_rn(csharp2cuda_temp_407, ((double)(csharp2cuda_temp_408)));
#line 621 "VectorModule.cs"
                double variance = 0.0;
#line 622 "VectorModule.cs"
                {
#line 622 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 622 "VectorModule.cs"
                        int csharp2cuda_temp_410 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_410))))
                            break;
#line 623 "VectorModule.cs"
                        {
#line 624 "VectorModule.cs"
                            double csharp2cuda_temp_411 = (a)[index];
#line 624 "VectorModule.cs"
                            double difference = __dsub_rn(csharp2cuda_temp_411, mean);
#line 625 "VectorModule.cs"
#line 625 "VectorModule.cs"
                            double* csharp2cuda_temp_412 = &(variance);
#line 625 "VectorModule.cs"
                            double csharp2cuda_temp_413 = *(csharp2cuda_temp_412);
                            (*(csharp2cuda_temp_412) = __dadd_rn(csharp2cuda_temp_413, __dmul_rn(difference, difference)));
                        }
#line 622 "VectorModule.cs"
                        int* csharp2cuda_temp_409 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_409));
                    }
                }
#line 627 "VectorModule.cs"
#line 627 "VectorModule.cs"
                double* csharp2cuda_temp_414 = &(variance);
#line 627 "VectorModule.cs"
                double csharp2cuda_temp_415 = *(csharp2cuda_temp_414);
#line 627 "VectorModule.cs"
                int csharp2cuda_temp_416 = (first)->count;
                (*(csharp2cuda_temp_414) = __ddiv_rn(csharp2cuda_temp_415, ((double)(csharp2cuda_temp_416))));
#line 628 "VectorModule.cs"
                double deviation = mathblocks_square_root(variance);
#line 629 "VectorModule.cs"
                {
#line 629 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 629 "VectorModule.cs"
                        int csharp2cuda_temp_418 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_418))))
                            break;
#line 630 "VectorModule.cs"
                        {
#line 631 "VectorModule.cs"
#line 631 "VectorModule.cs"
                            double* csharp2cuda_temp_419 = &((result)[index]);
#line 631 "VectorModule.cs"
                            double csharp2cuda_temp_420 = (a)[index];
#line 631 "VectorModule.cs"
                            double csharp2cuda_temp_421 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_420, mean), deviation);
                            (*(csharp2cuda_temp_419) = csharp2cuda_temp_421);
#line 632 "VectorModule.cs"
#line 632 "VectorModule.cs"
                            double csharp2cuda_temp_422 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_422))))
                            {
#line 632 "VectorModule.cs"
#line 632 "VectorModule.cs"
                                int* csharp2cuda_temp_423 = &((output)->valid);
                                (*(csharp2cuda_temp_423) = 0);
                            }
                        }
#line 629 "VectorModule.cs"
                        int* csharp2cuda_temp_417 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_417));
                    }
                }
            }
#line 635 "VectorModule.cs"
            break;
#line 636 "VectorModule.cs"
        case 49:
#line 637 "VectorModule.cs"
            if (((thread) == (0)))
#line 638 "VectorModule.cs"
            {
#line 639 "VectorModule.cs"
                int count = 0;
#line 640 "VectorModule.cs"
                {
#line 640 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 640 "VectorModule.cs"
                        int csharp2cuda_temp_425 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_425))))
                            break;
#line 641 "VectorModule.cs"
                        {
#line 642 "VectorModule.cs"
                            bool found = false;
#line 643 "VectorModule.cs"
                            {
#line 643 "VectorModule.cs"
                                int prior = 0;
                                while (true)
                                {
                                    if (!(((prior) < (count))))
                                        break;
#line 644 "VectorModule.cs"
#line 644 "VectorModule.cs"
                                    double csharp2cuda_temp_427 = (result)[prior];
#line 644 "VectorModule.cs"
                                    double csharp2cuda_temp_428 = (a)[index];
                                    if (((csharp2cuda_temp_427) == (csharp2cuda_temp_428)))
#line 644 "VectorModule.cs"
                                    {
#line 644 "VectorModule.cs"
#line 644 "VectorModule.cs"
                                        bool* csharp2cuda_temp_429 = &(found);
                                        (*(csharp2cuda_temp_429) = true);
#line 644 "VectorModule.cs"
                                        break;
                                    }
#line 643 "VectorModule.cs"
                                    int* csharp2cuda_temp_426 = &(prior);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_426));
                                }
                            }
#line 645 "VectorModule.cs"
                            if ((!(found)))
                            {
#line 645 "VectorModule.cs"
#line 645 "VectorModule.cs"
                                int* csharp2cuda_temp_430 = &(count);
#line 645 "VectorModule.cs"
                                int csharp2cuda_temp_431 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_430));
#line 645 "VectorModule.cs"
                                double* csharp2cuda_temp_432 = &((result)[csharp2cuda_temp_431]);
#line 645 "VectorModule.cs"
                                double csharp2cuda_temp_433 = (a)[index];
                                (*(csharp2cuda_temp_432) = csharp2cuda_temp_433);
                            }
                        }
#line 640 "VectorModule.cs"
                        int* csharp2cuda_temp_424 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_424));
                    }
                }
#line 647 "VectorModule.cs"
                mathblocks_set_vector_shape(output, count);
            }
#line 649 "VectorModule.cs"
            break;
#line 650 "VectorModule.cs"
        case 50:
        case 52:
        case 55:
#line 653 "VectorModule.cs"
            {
#line 654 "VectorModule.cs"
                if (((thread) == (0)))
#line 655 "VectorModule.cs"
                {
#line 656 "VectorModule.cs"
#line 656 "VectorModule.cs"
                    int* csharp2cuda_temp_434 = &((output)->boolean_value);
#line 656 "VectorModule.cs"
                    int csharp2cuda_temp_435;
#line 656 "VectorModule.cs"
                    if (((opcode) == (50)))
                    {
#line 656 "VectorModule.cs"
                        csharp2cuda_temp_435 = 1;
                    }
                    else
                    {
#line 656 "VectorModule.cs"
                        csharp2cuda_temp_435 = 0;
                    }
                    (*(csharp2cuda_temp_434) = csharp2cuda_temp_435);
#line 657 "VectorModule.cs"
#line 657 "VectorModule.cs"
                    double* csharp2cuda_temp_436 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_436) = 0.0);
                }
#line 659 "VectorModule.cs"
                __syncthreads();
#line 660 "VectorModule.cs"
                int local_count = 0;
#line 661 "VectorModule.cs"
                bool local_all = true;
#line 662 "VectorModule.cs"
                bool local_any = false;
#line 663 "VectorModule.cs"
                {
#line 663 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 663 "VectorModule.cs"
                        int csharp2cuda_temp_439 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_439))))
                            break;
#line 664 "VectorModule.cs"
                        {
#line 665 "VectorModule.cs"
                            int csharp2cuda_temp_440 = (boolean_a)[index];
#line 665 "VectorModule.cs"
                            bool value = ((csharp2cuda_temp_440) != (0));
#line 666 "VectorModule.cs"
                            if (value)
                            {
#line 666 "VectorModule.cs"
#line 666 "VectorModule.cs"
                                int* csharp2cuda_temp_441 = &(local_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_441));
                            }
#line 667 "VectorModule.cs"
#line 667 "VectorModule.cs"
                            bool* csharp2cuda_temp_442 = &(local_all);
#line 667 "VectorModule.cs"
                            bool csharp2cuda_temp_443;
#line 667 "VectorModule.cs"
                            if (local_all)
                            {
#line 667 "VectorModule.cs"
                                csharp2cuda_temp_443 = value;
                            }
                            else
                            {
#line 667 "VectorModule.cs"
                                csharp2cuda_temp_443 = false;
                            }
                            (*(csharp2cuda_temp_442) = csharp2cuda_temp_443);
#line 668 "VectorModule.cs"
#line 668 "VectorModule.cs"
                            bool* csharp2cuda_temp_444 = &(local_any);
#line 668 "VectorModule.cs"
                            bool csharp2cuda_temp_445;
#line 668 "VectorModule.cs"
                            if (!(local_any))
                            {
#line 668 "VectorModule.cs"
                                csharp2cuda_temp_445 = value;
                            }
                            else
                            {
#line 668 "VectorModule.cs"
                                csharp2cuda_temp_445 = true;
                            }
                            (*(csharp2cuda_temp_444) = csharp2cuda_temp_445);
                        }
#line 663 "VectorModule.cs"
                        int* csharp2cuda_temp_437 = &(index);
#line 663 "VectorModule.cs"
                        int csharp2cuda_temp_438 = *(csharp2cuda_temp_437);
                        (*(csharp2cuda_temp_437) = csharp2cuda_i32_add(csharp2cuda_temp_438, blockDim.x));
                    }
                }
#line 670 "VectorModule.cs"
#line 670 "VectorModule.cs"
                bool csharp2cuda_temp_446;
#line 670 "VectorModule.cs"
                if (((opcode) == (55)))
                {
#line 670 "VectorModule.cs"
                    csharp2cuda_temp_446 = ((local_count) != (0));
                }
                else
                {
#line 670 "VectorModule.cs"
                    csharp2cuda_temp_446 = false;
                }
                if (csharp2cuda_temp_446)
                {
#line 671 "VectorModule.cs"
                    atomicAdd(&((output)->boolean_value), local_count);
                }
                else
                {
#line 672 "VectorModule.cs"
#line 672 "VectorModule.cs"
                    bool csharp2cuda_temp_447;
#line 672 "VectorModule.cs"
                    if (((opcode) == (50)))
                    {
#line 672 "VectorModule.cs"
                        csharp2cuda_temp_447 = (!(local_all));
                    }
                    else
                    {
#line 672 "VectorModule.cs"
                        csharp2cuda_temp_447 = false;
                    }
                    if (csharp2cuda_temp_447)
                    {
#line 673 "VectorModule.cs"
                        atomicExch(&((output)->boolean_value), 0);
                    }
                    else
                    {
#line 674 "VectorModule.cs"
#line 674 "VectorModule.cs"
                        bool csharp2cuda_temp_448;
#line 674 "VectorModule.cs"
                        if (((opcode) == (52)))
                        {
#line 674 "VectorModule.cs"
                            csharp2cuda_temp_448 = local_any;
                        }
                        else
                        {
#line 674 "VectorModule.cs"
                            csharp2cuda_temp_448 = false;
                        }
                        if (csharp2cuda_temp_448)
                        {
#line 675 "VectorModule.cs"
                            atomicExch(&((output)->boolean_value), 1);
                        }
                    }
                }
#line 676 "VectorModule.cs"
                __syncthreads();
#line 677 "VectorModule.cs"
#line 677 "VectorModule.cs"
                bool csharp2cuda_temp_449;
#line 677 "VectorModule.cs"
                if (((thread) == (0)))
                {
#line 677 "VectorModule.cs"
                    csharp2cuda_temp_449 = ((opcode) == (55));
                }
                else
                {
#line 677 "VectorModule.cs"
                    csharp2cuda_temp_449 = false;
                }
                if (csharp2cuda_temp_449)
#line 678 "VectorModule.cs"
                {
#line 679 "VectorModule.cs"
#line 679 "VectorModule.cs"
                    double* csharp2cuda_temp_450 = &((output)->scalar_value);
#line 679 "VectorModule.cs"
                    int csharp2cuda_temp_451 = (output)->boolean_value;
                    (*(csharp2cuda_temp_450) = ((double)(csharp2cuda_temp_451)));
#line 680 "VectorModule.cs"
#line 680 "VectorModule.cs"
                    int* csharp2cuda_temp_452 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_452) = 0);
                }
#line 682 "VectorModule.cs"
                break;
            }
#line 684 "VectorModule.cs"
        case 51:
        case 54:
        case 57:
#line 687 "VectorModule.cs"
            if (((thread) == (0)))
#line 688 "VectorModule.cs"
            {
#line 689 "VectorModule.cs"
#line 689 "VectorModule.cs"
                int csharp2cuda_temp_453 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_453);
#line 690 "VectorModule.cs"
#line 690 "VectorModule.cs"
                int csharp2cuda_temp_454 = (first)->count;
#line 690 "VectorModule.cs"
                int csharp2cuda_temp_455 = (second)->count;
                if (((csharp2cuda_temp_454) != (csharp2cuda_temp_455)))
                {
#line 690 "VectorModule.cs"
#line 690 "VectorModule.cs"
                    int* csharp2cuda_temp_456 = &((output)->valid);
                    (*(csharp2cuda_temp_456) = 0);
                }
            }
#line 692 "VectorModule.cs"
            __syncthreads();
#line 693 "VectorModule.cs"
            {
#line 693 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 693 "VectorModule.cs"
                    bool csharp2cuda_temp_459 = (output)->valid;
#line 693 "VectorModule.cs"
                    bool csharp2cuda_temp_460;
#line 693 "VectorModule.cs"
                    if (csharp2cuda_temp_459)
                    {
#line 693 "VectorModule.cs"
                        int csharp2cuda_temp_461 = (first)->count;
#line 693 "VectorModule.cs"
                        csharp2cuda_temp_460 = ((index) < (csharp2cuda_temp_461));
                    }
                    else
                    {
#line 693 "VectorModule.cs"
                        csharp2cuda_temp_460 = false;
                    }
                    if (!(csharp2cuda_temp_460))
                        break;
#line 694 "VectorModule.cs"
#line 694 "VectorModule.cs"
                    int* csharp2cuda_temp_462 = &((boolean_result)[index]);
#line 694 "VectorModule.cs"
                    bool csharp2cuda_temp_463;
#line 694 "VectorModule.cs"
                    if (((opcode) == (51)))
                    {
#line 694 "VectorModule.cs"
                        bool csharp2cuda_temp_464 = (boolean_a)[index];
#line 694 "VectorModule.cs"
                        bool csharp2cuda_temp_465;
#line 694 "VectorModule.cs"
                        if (csharp2cuda_temp_464)
                        {
#line 694 "VectorModule.cs"
                            csharp2cuda_temp_465 = (boolean_b)[index];
                        }
                        else
                        {
#line 694 "VectorModule.cs"
                            csharp2cuda_temp_465 = false;
                        }
#line 694 "VectorModule.cs"
                        csharp2cuda_temp_463 = csharp2cuda_temp_465;
                    }
                    else
                    {
#line 695 "VectorModule.cs"
                        bool csharp2cuda_temp_466;
#line 695 "VectorModule.cs"
                        if (((opcode) == (54)))
                        {
#line 695 "VectorModule.cs"
                            bool csharp2cuda_temp_467 = (boolean_a)[index];
#line 695 "VectorModule.cs"
                            bool csharp2cuda_temp_468;
#line 695 "VectorModule.cs"
                            if (!(csharp2cuda_temp_467))
                            {
#line 695 "VectorModule.cs"
                                csharp2cuda_temp_468 = (boolean_b)[index];
                            }
                            else
                            {
#line 695 "VectorModule.cs"
                                csharp2cuda_temp_468 = true;
                            }
#line 695 "VectorModule.cs"
                            csharp2cuda_temp_466 = csharp2cuda_temp_468;
                        }
                        else
                        {
#line 696 "VectorModule.cs"
                            int csharp2cuda_temp_469 = (boolean_a)[index];
#line 696 "VectorModule.cs"
                            int csharp2cuda_temp_470 = (boolean_b)[index];
#line 695 "VectorModule.cs"
                            csharp2cuda_temp_466 = ((csharp2cuda_temp_469) != (csharp2cuda_temp_470));
                        }
#line 694 "VectorModule.cs"
                        csharp2cuda_temp_463 = csharp2cuda_temp_466;
                    }
                    (*(csharp2cuda_temp_462) = csharp2cuda_temp_463);
#line 693 "VectorModule.cs"
                    int* csharp2cuda_temp_457 = &(index);
#line 693 "VectorModule.cs"
                    int csharp2cuda_temp_458 = *(csharp2cuda_temp_457);
                    (*(csharp2cuda_temp_457) = csharp2cuda_i32_add(csharp2cuda_temp_458, blockDim.x));
                }
            }
#line 697 "VectorModule.cs"
            break;
#line 698 "VectorModule.cs"
        case 53:
#line 699 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 699 "VectorModule.cs"
#line 699 "VectorModule.cs"
                int csharp2cuda_temp_471 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_471);
            }
#line 700 "VectorModule.cs"
            __syncthreads();
#line 701 "VectorModule.cs"
            {
#line 701 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 701 "VectorModule.cs"
                    bool csharp2cuda_temp_474 = (output)->valid;
#line 701 "VectorModule.cs"
                    bool csharp2cuda_temp_475;
#line 701 "VectorModule.cs"
                    if (csharp2cuda_temp_474)
                    {
#line 701 "VectorModule.cs"
                        int csharp2cuda_temp_476 = (first)->count;
#line 701 "VectorModule.cs"
                        csharp2cuda_temp_475 = ((index) < (csharp2cuda_temp_476));
                    }
                    else
                    {
#line 701 "VectorModule.cs"
                        csharp2cuda_temp_475 = false;
                    }
                    if (!(csharp2cuda_temp_475))
                        break;
#line 702 "VectorModule.cs"
#line 702 "VectorModule.cs"
                    int* csharp2cuda_temp_477 = &((boolean_result)[index]);
#line 702 "VectorModule.cs"
                    bool csharp2cuda_temp_478 = (boolean_a)[index];
                    (*(csharp2cuda_temp_477) = (!(csharp2cuda_temp_478)));
#line 701 "VectorModule.cs"
                    int* csharp2cuda_temp_472 = &(index);
#line 701 "VectorModule.cs"
                    int csharp2cuda_temp_473 = *(csharp2cuda_temp_472);
                    (*(csharp2cuda_temp_472) = csharp2cuda_i32_add(csharp2cuda_temp_473, blockDim.x));
                }
            }
#line 703 "VectorModule.cs"
            break;
#line 704 "VectorModule.cs"
        case 56:
#line 705 "VectorModule.cs"
            if (((thread) == (0)))
#line 706 "VectorModule.cs"
            {
#line 707 "VectorModule.cs"
                int count = 0;
#line 708 "VectorModule.cs"
                {
#line 708 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 708 "VectorModule.cs"
                        int csharp2cuda_temp_480 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_480))))
                            break;
#line 709 "VectorModule.cs"
                        if ((boolean_a)[index])
                        {
#line 709 "VectorModule.cs"
#line 709 "VectorModule.cs"
                            int* csharp2cuda_temp_481 = &(count);
#line 709 "VectorModule.cs"
                            int csharp2cuda_temp_482 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_481));
#line 709 "VectorModule.cs"
                            double* csharp2cuda_temp_483 = &((result)[csharp2cuda_temp_482]);
                            (*(csharp2cuda_temp_483) = ((double)(index)));
                        }
#line 708 "VectorModule.cs"
                        int* csharp2cuda_temp_479 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_479));
                    }
                }
#line 710 "VectorModule.cs"
                mathblocks_set_vector_shape(output, count);
            }
#line 712 "VectorModule.cs"
            break;
#line 713 "VectorModule.cs"
        default:
#line 714 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 714 "VectorModule.cs"
#line 714 "VectorModule.cs"
                int* csharp2cuda_temp_484 = &((output)->valid);
                (*(csharp2cuda_temp_484) = 0);
            }
#line 715 "VectorModule.cs"
            break;
    }
}