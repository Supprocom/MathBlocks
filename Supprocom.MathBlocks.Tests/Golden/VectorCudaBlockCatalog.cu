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

#line 108 "VectorModule.cs"
__device__ double mathblocks_compensated_absolute_sum(const double* values, int count);

#line 88 "VectorModule.cs"
__device__ double mathblocks_compensated_product_sum(
    const double* first,
    const double* second,
    int count);

#line 71 "VectorModule.cs"
__device__ double mathblocks_compensated_sum(const double* values, int count);

#line 251 "VectorModule.cs"
__device__ void mathblocks_copy_and_sort(
    const MathBlockSlot* input,
    MathBlockSlot* output);

#line 50 "VectorModule.cs"
__device__ double mathblocks_maximum(double first, double second);

#line 38 "VectorModule.cs"
__device__ double mathblocks_minimum(double first, double second);

#line 62 "VectorModule.cs"
__device__ bool mathblocks_nonnegative_integer(double value, int* result);

#line 284 "VectorModule.cs"
__device__ double mathblocks_quantile(
    const MathBlockSlot* input,
    MathBlockSlot* output,
    double probability);

#line 265 "VectorModule.cs"
__device__ double mathblocks_quantile_values(
    const double* values,
    int count,
    double* sorted,
    double probability);

#line 125 "VectorModule.cs"
__device__ void mathblocks_set_vector_shape(MathBlockSlot* output, int count);

#line 193 "VectorModule.cs"
__device__ void mathblocks_sort_copy_values(
    const double* source,
    int count,
    double* sorted);

#line 214 "VectorModule.cs"
__device__ void mathblocks_stable_index_order(const double* keys, int count, int* order, int* buffer);

#line 143 "VectorModule.cs"
__device__ double* mathblocks_stable_merge_sort(double* values, double* buffer, int count, bool descending);

#line 176 "VectorModule.cs"
__device__ void mathblocks_stable_sort_into(
    const double* values,
    int count,
    double* result,
    double* buffer,
    bool descending);

#line 326 "VectorModule.cs"
__device__ bool mathblocks_vector_arg_extreme_value(
    const double* values,
    int count,
    bool maximum,
    double* value);

#line 379 "VectorModule.cs"
__device__ void mathblocks_vector_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 303 "VectorModule.cs"
__device__ bool mathblocks_vector_geometric_mean_value(
    const double* values,
    int count,
    double* logarithms,
    double* value);

#line 343 "VectorModule.cs"
__device__ double mathblocks_vector_rank_at(
    const double* values,
    int count,
    int position);

#line 359 "VectorModule.cs"
__device__ void mathblocks_vector_standardize_moments(
    const double* values,
    int count,
    double* mean,
    double* deviation);

#line 108 "VectorModule.cs"
__device__ double mathblocks_compensated_absolute_sum(const double* values, int count)
#line 110 "VectorModule.cs"
{
#line 111 "VectorModule.cs"
    double sum = 0.0;
#line 112 "VectorModule.cs"
    double correction = 0.0;
#line 113 "VectorModule.cs"
    {
#line 113 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 114 "VectorModule.cs"
            {
#line 115 "VectorModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 115 "VectorModule.cs"
                double value = fabs(csharp2cuda_temp_1);
#line 116 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 117 "VectorModule.cs"
#line 117 "VectorModule.cs"
                double* csharp2cuda_temp_2 = &(correction);
#line 117 "VectorModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 117 "VectorModule.cs"
                double csharp2cuda_temp_4;
#line 117 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 117 "VectorModule.cs"
                    csharp2cuda_temp_4 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 117 "VectorModule.cs"
                    csharp2cuda_temp_4 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 120 "VectorModule.cs"
#line 120 "VectorModule.cs"
                double* csharp2cuda_temp_5 = &(sum);
                (*(csharp2cuda_temp_5) = next);
            }
#line 113 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 122 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 88 "VectorModule.cs"
__device__ double mathblocks_compensated_product_sum(
    const double* first,
    const double* second,
    int count)
#line 93 "VectorModule.cs"
{
#line 94 "VectorModule.cs"
    double sum = 0.0;
#line 95 "VectorModule.cs"
    double correction = 0.0;
#line 96 "VectorModule.cs"
    {
#line 96 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 97 "VectorModule.cs"
            {
#line 98 "VectorModule.cs"
                double csharp2cuda_temp_1 = (first)[index];
#line 98 "VectorModule.cs"
                double csharp2cuda_temp_2 = (second)[index];
#line 98 "VectorModule.cs"
                double value = __dmul_rn(csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 99 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 100 "VectorModule.cs"
#line 100 "VectorModule.cs"
                double* csharp2cuda_temp_3 = &(correction);
#line 100 "VectorModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 100 "VectorModule.cs"
                double csharp2cuda_temp_5;
#line 100 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 100 "VectorModule.cs"
                    csharp2cuda_temp_5 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 100 "VectorModule.cs"
                    csharp2cuda_temp_5 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
#line 103 "VectorModule.cs"
#line 103 "VectorModule.cs"
                double* csharp2cuda_temp_6 = &(sum);
                (*(csharp2cuda_temp_6) = next);
            }
#line 96 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 105 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 71 "VectorModule.cs"
__device__ double mathblocks_compensated_sum(const double* values, int count)
#line 73 "VectorModule.cs"
{
#line 74 "VectorModule.cs"
    double sum = 0.0;
#line 75 "VectorModule.cs"
    double correction = 0.0;
#line 76 "VectorModule.cs"
    {
#line 76 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 77 "VectorModule.cs"
            {
#line 78 "VectorModule.cs"
                double value = (values)[index];
#line 79 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 80 "VectorModule.cs"
#line 80 "VectorModule.cs"
                double* csharp2cuda_temp_1 = &(correction);
#line 80 "VectorModule.cs"
                double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 80 "VectorModule.cs"
                double csharp2cuda_temp_3;
#line 80 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 80 "VectorModule.cs"
                    csharp2cuda_temp_3 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 80 "VectorModule.cs"
                    csharp2cuda_temp_3 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 83 "VectorModule.cs"
#line 83 "VectorModule.cs"
                double* csharp2cuda_temp_4 = &(sum);
                (*(csharp2cuda_temp_4) = next);
            }
#line 76 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 85 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 251 "VectorModule.cs"
__device__ void mathblocks_copy_and_sort(
    const MathBlockSlot* input,
    MathBlockSlot* output)
#line 255 "VectorModule.cs"
{
#line 256 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_0 = (output)->scratch_pointer;
#line 256 "VectorModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_0));
#line 257 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_1 = (input)->data_pointer;
#line 257 "VectorModule.cs"
    const double* source = ((double*)(csharp2cuda_temp_1));
#line 258 "VectorModule.cs"
#line 258 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_2 = (output)->data_pointer;
    if (((csharp2cuda_temp_2) != (((unsigned long long)(0)))))
    {
#line 259 "VectorModule.cs"
#line 259 "VectorModule.cs"
        int csharp2cuda_temp_3 = (input)->count;
#line 259 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_4 = (output)->data_pointer;
        mathblocks_stable_sort_into(source, csharp2cuda_temp_3, ((double*)(csharp2cuda_temp_4)), scratch, false);
    }
    else
    {
#line 261 "VectorModule.cs"
#line 261 "VectorModule.cs"
        int csharp2cuda_temp_5 = (input)->count;
#line 261 "VectorModule.cs"
        int csharp2cuda_temp_6 = (input)->count;
        mathblocks_stable_sort_into(source, csharp2cuda_temp_5, scratch, csharp2cuda_pointer_add(scratch, csharp2cuda_temp_6), false);
    }
}

#line 50 "VectorModule.cs"
__device__ double mathblocks_maximum(double first, double second)
#line 52 "VectorModule.cs"
{
#line 53 "VectorModule.cs"
    if (((first) > (second)))
    {
#line 54 "VectorModule.cs"
        return first;
    }
#line 55 "VectorModule.cs"
    if (((second) > (first)))
    {
#line 56 "VectorModule.cs"
        return second;
    }
#line 57 "VectorModule.cs"
    if (((first) == (0.0)))
    {
#line 58 "VectorModule.cs"
#line 58 "VectorModule.cs"
        double csharp2cuda_temp_0;
#line 58 "VectorModule.cs"
        if (signbit(first))
        {
#line 58 "VectorModule.cs"
            csharp2cuda_temp_0 = second;
        }
        else
        {
#line 58 "VectorModule.cs"
            csharp2cuda_temp_0 = first;
        }
        return csharp2cuda_temp_0;
    }
#line 59 "VectorModule.cs"
    return first;
}

#line 38 "VectorModule.cs"
__device__ double mathblocks_minimum(double first, double second)
#line 40 "VectorModule.cs"
{
#line 41 "VectorModule.cs"
    if (((first) < (second)))
    {
#line 42 "VectorModule.cs"
        return first;
    }
#line 43 "VectorModule.cs"
    if (((second) < (first)))
    {
#line 44 "VectorModule.cs"
        return second;
    }
#line 45 "VectorModule.cs"
    if (((first) == (0.0)))
    {
#line 46 "VectorModule.cs"
#line 46 "VectorModule.cs"
        double csharp2cuda_temp_0;
#line 46 "VectorModule.cs"
        if (signbit(first))
        {
#line 46 "VectorModule.cs"
            csharp2cuda_temp_0 = first;
        }
        else
        {
#line 46 "VectorModule.cs"
            csharp2cuda_temp_0 = second;
        }
        return csharp2cuda_temp_0;
    }
#line 47 "VectorModule.cs"
    return first;
}

#line 62 "VectorModule.cs"
__device__ bool mathblocks_nonnegative_integer(double value, int* result)
#line 64 "VectorModule.cs"
{
#line 65 "VectorModule.cs"
#line 65 "VectorModule.cs"
    bool csharp2cuda_temp_0;
#line 65 "VectorModule.cs"
    if (!(((value) < (0.0))))
    {
#line 65 "VectorModule.cs"
        csharp2cuda_temp_0 = ((value) > (2147483647.0));
    }
    else
    {
#line 65 "VectorModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 65 "VectorModule.cs"
    bool csharp2cuda_temp_1;
#line 65 "VectorModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 65 "VectorModule.cs"
        csharp2cuda_temp_1 = ((value) != (trunc(value)));
    }
    else
    {
#line 65 "VectorModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 66 "VectorModule.cs"
        return false;
    }
#line 67 "VectorModule.cs"
#line 67 "VectorModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 68 "VectorModule.cs"
    return true;
}

#line 284 "VectorModule.cs"
__device__ double mathblocks_quantile(
    const MathBlockSlot* input,
    MathBlockSlot* output,
    double probability)
#line 289 "VectorModule.cs"
{
#line 290 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_0 = (output)->scratch_pointer;
#line 290 "VectorModule.cs"
    double* sorted = ((double*)(csharp2cuda_temp_0));
#line 291 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_1 = (input)->data_pointer;
#line 291 "VectorModule.cs"
    const double* source = ((double*)(csharp2cuda_temp_1));
#line 292 "VectorModule.cs"
    int count = (input)->count;
#line 293 "VectorModule.cs"
    mathblocks_stable_sort_into(source, count, sorted, csharp2cuda_pointer_add(sorted, count), false);
#line 294 "VectorModule.cs"
    if (((count) == (1)))
    {
#line 295 "VectorModule.cs"
        return (sorted)[0];
    }
#line 296 "VectorModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 297 "VectorModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 298 "VectorModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 299 "VectorModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 300 "VectorModule.cs"
#line 300 "VectorModule.cs"
    double csharp2cuda_temp_2 = (sorted)[lower];
#line 300 "VectorModule.cs"
    double csharp2cuda_temp_3 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_2, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_3, weight));
}

#line 265 "VectorModule.cs"
__device__ double mathblocks_quantile_values(
    const double* values,
    int count,
    double* sorted,
    double probability)
#line 271 "VectorModule.cs"
{
#line 272 "VectorModule.cs"
    mathblocks_sort_copy_values(values, count, sorted);
#line 273 "VectorModule.cs"
    if (((count) == (1)))
    {
#line 274 "VectorModule.cs"
        return (sorted)[0];
    }
#line 275 "VectorModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 276 "VectorModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 277 "VectorModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 278 "VectorModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 279 "VectorModule.cs"
#line 279 "VectorModule.cs"
    double csharp2cuda_temp_0 = (sorted)[lower];
#line 279 "VectorModule.cs"
    double csharp2cuda_temp_1 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_0, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_1, weight));
}

#line 125 "VectorModule.cs"
__device__ void mathblocks_set_vector_shape(MathBlockSlot* output, int count)
#line 127 "VectorModule.cs"
{
#line 128 "VectorModule.cs"
#line 128 "VectorModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 129 "VectorModule.cs"
#line 129 "VectorModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 130 "VectorModule.cs"
#line 130 "VectorModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 131 "VectorModule.cs"
#line 131 "VectorModule.cs"
    bool csharp2cuda_temp_3;
#line 131 "VectorModule.cs"
    if (!(((count) < (0))))
    {
#line 131 "VectorModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 131 "VectorModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 131 "VectorModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 132 "VectorModule.cs"
    {
#line 133 "VectorModule.cs"
#line 133 "VectorModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 134 "VectorModule.cs"
        return;
    }
}

#line 193 "VectorModule.cs"
__device__ void mathblocks_sort_copy_values(
    const double* source,
    int count,
    double* sorted)
#line 198 "VectorModule.cs"
{
#line 199 "VectorModule.cs"
    {
#line 199 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 200 "VectorModule.cs"
            {
#line 201 "VectorModule.cs"
                double value = (source)[index];
#line 202 "VectorModule.cs"
                int position = index;
#line 203 "VectorModule.cs"
                while (true)
                {
#line 203 "VectorModule.cs"
                    bool csharp2cuda_temp_1;
#line 203 "VectorModule.cs"
                    if (((position) > (0)))
                    {
#line 203 "VectorModule.cs"
                        double csharp2cuda_temp_2 = (sorted)[csharp2cuda_i32_sub(position, 1)];
#line 203 "VectorModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (value));
                    }
                    else
                    {
#line 203 "VectorModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 204 "VectorModule.cs"
                    {
#line 205 "VectorModule.cs"
#line 205 "VectorModule.cs"
                        double* csharp2cuda_temp_3 = &((sorted)[position]);
#line 205 "VectorModule.cs"
                        double csharp2cuda_temp_4 = (sorted)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 206 "VectorModule.cs"
#line 206 "VectorModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 208 "VectorModule.cs"
#line 208 "VectorModule.cs"
                double* csharp2cuda_temp_6 = &((sorted)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 199 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 214 "VectorModule.cs"
__device__ void mathblocks_stable_index_order(const double* keys, int count, int* order, int* buffer)
#line 216 "VectorModule.cs"
{
#line 217 "VectorModule.cs"
    {
#line 217 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 218 "VectorModule.cs"
#line 218 "VectorModule.cs"
            int* csharp2cuda_temp_1 = &((order)[index]);
            (*(csharp2cuda_temp_1) = index);
#line 217 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 219 "VectorModule.cs"
    int* source = order;
#line 220 "VectorModule.cs"
    int* target = buffer;
#line 221 "VectorModule.cs"
    {
#line 221 "VectorModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 222 "VectorModule.cs"
            {
#line 223 "VectorModule.cs"
                {
#line 223 "VectorModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 224 "VectorModule.cs"
                        {
#line 225 "VectorModule.cs"
                            int csharp2cuda_temp_6;
#line 225 "VectorModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 225 "VectorModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 225 "VectorModule.cs"
                                csharp2cuda_temp_6 = count;
                            }
#line 225 "VectorModule.cs"
                            int middle = csharp2cuda_temp_6;
#line 226 "VectorModule.cs"
                            int csharp2cuda_temp_7;
#line 226 "VectorModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 226 "VectorModule.cs"
                                csharp2cuda_temp_7 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 226 "VectorModule.cs"
                                csharp2cuda_temp_7 = count;
                            }
#line 226 "VectorModule.cs"
                            int end = csharp2cuda_temp_7;
#line 227 "VectorModule.cs"
                            int left = start;
#line 228 "VectorModule.cs"
                            int right = middle;
#line 229 "VectorModule.cs"
                            int position = start;
#line 230 "VectorModule.cs"
                            while (true)
                            {
#line 230 "VectorModule.cs"
                                bool csharp2cuda_temp_8;
#line 230 "VectorModule.cs"
                                if (((left) < (middle)))
                                {
#line 230 "VectorModule.cs"
                                    csharp2cuda_temp_8 = ((right) < (end));
                                }
                                else
                                {
#line 230 "VectorModule.cs"
                                    csharp2cuda_temp_8 = false;
                                }
                                if (!(csharp2cuda_temp_8))
                                    break;
#line 231 "VectorModule.cs"
                                {
#line 232 "VectorModule.cs"
                                    int csharp2cuda_temp_9 = (source)[right];
#line 232 "VectorModule.cs"
                                    double csharp2cuda_temp_10 = (keys)[csharp2cuda_temp_9];
#line 232 "VectorModule.cs"
                                    int csharp2cuda_temp_11 = (source)[left];
#line 232 "VectorModule.cs"
                                    double csharp2cuda_temp_12 = (keys)[csharp2cuda_temp_11];
#line 232 "VectorModule.cs"
                                    bool take_right = ((csharp2cuda_temp_10) < (csharp2cuda_temp_12));
#line 233 "VectorModule.cs"
#line 233 "VectorModule.cs"
                                    int* csharp2cuda_temp_13 = &(position);
#line 233 "VectorModule.cs"
                                    int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 233 "VectorModule.cs"
                                    int* csharp2cuda_temp_15 = &((target)[csharp2cuda_temp_14]);
#line 233 "VectorModule.cs"
                                    int csharp2cuda_temp_16;
#line 233 "VectorModule.cs"
                                    if (take_right)
                                    {
#line 233 "VectorModule.cs"
                                        int* csharp2cuda_temp_17 = &(right);
#line 233 "VectorModule.cs"
                                        int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 233 "VectorModule.cs"
                                        csharp2cuda_temp_16 = (source)[csharp2cuda_temp_18];
                                    }
                                    else
                                    {
#line 233 "VectorModule.cs"
                                        int* csharp2cuda_temp_19 = &(left);
#line 233 "VectorModule.cs"
                                        int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 233 "VectorModule.cs"
                                        csharp2cuda_temp_16 = (source)[csharp2cuda_temp_20];
                                    }
                                    (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
                                }
                            }
#line 235 "VectorModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 236 "VectorModule.cs"
#line 236 "VectorModule.cs"
                                int* csharp2cuda_temp_21 = &(position);
#line 236 "VectorModule.cs"
                                int csharp2cuda_temp_22 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
#line 236 "VectorModule.cs"
                                int* csharp2cuda_temp_23 = &((target)[csharp2cuda_temp_22]);
#line 236 "VectorModule.cs"
                                int* csharp2cuda_temp_24 = &(left);
#line 236 "VectorModule.cs"
                                int csharp2cuda_temp_25 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
#line 236 "VectorModule.cs"
                                int csharp2cuda_temp_26 = (source)[csharp2cuda_temp_25];
                                (*(csharp2cuda_temp_23) = csharp2cuda_temp_26);
                            }
#line 237 "VectorModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 238 "VectorModule.cs"
#line 238 "VectorModule.cs"
                                int* csharp2cuda_temp_27 = &(position);
#line 238 "VectorModule.cs"
                                int csharp2cuda_temp_28 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 238 "VectorModule.cs"
                                int* csharp2cuda_temp_29 = &((target)[csharp2cuda_temp_28]);
#line 238 "VectorModule.cs"
                                int* csharp2cuda_temp_30 = &(right);
#line 238 "VectorModule.cs"
                                int csharp2cuda_temp_31 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_30));
#line 238 "VectorModule.cs"
                                int csharp2cuda_temp_32 = (source)[csharp2cuda_temp_31];
                                (*(csharp2cuda_temp_29) = csharp2cuda_temp_32);
                            }
                        }
#line 223 "VectorModule.cs"
                        int* csharp2cuda_temp_4 = &(start);
#line 223 "VectorModule.cs"
                        int csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
                        (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(csharp2cuda_temp_5, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 240 "VectorModule.cs"
                int* sorted = target;
#line 241 "VectorModule.cs"
#line 241 "VectorModule.cs"
                int** csharp2cuda_temp_33 = &(target);
                (*(csharp2cuda_temp_33) = source);
#line 242 "VectorModule.cs"
#line 242 "VectorModule.cs"
                int** csharp2cuda_temp_34 = &(source);
                (*(csharp2cuda_temp_34) = sorted);
            }
#line 221 "VectorModule.cs"
            int* csharp2cuda_temp_2 = &(width);
#line 221 "VectorModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, width));
        }
    }
#line 244 "VectorModule.cs"
    if (((((void*)(source))) != (((void*)(order)))))
    {
#line 245 "VectorModule.cs"
        {
#line 245 "VectorModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 246 "VectorModule.cs"
#line 246 "VectorModule.cs"
                int* csharp2cuda_temp_36 = &((order)[index]);
#line 246 "VectorModule.cs"
                int csharp2cuda_temp_37 = (source)[index];
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 245 "VectorModule.cs"
                int* csharp2cuda_temp_35 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
            }
        }
    }
}

#line 143 "VectorModule.cs"
__device__ double* mathblocks_stable_merge_sort(double* values, double* buffer, int count, bool descending)
#line 145 "VectorModule.cs"
{
#line 146 "VectorModule.cs"
    double* source = values;
#line 147 "VectorModule.cs"
    double* target = buffer;
#line 148 "VectorModule.cs"
    {
#line 148 "VectorModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 149 "VectorModule.cs"
            {
#line 150 "VectorModule.cs"
                {
#line 150 "VectorModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 151 "VectorModule.cs"
                        {
#line 152 "VectorModule.cs"
                            int csharp2cuda_temp_4;
#line 152 "VectorModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 152 "VectorModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 152 "VectorModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 152 "VectorModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 153 "VectorModule.cs"
                            int csharp2cuda_temp_5;
#line 153 "VectorModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 153 "VectorModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 153 "VectorModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 153 "VectorModule.cs"
                            int end = csharp2cuda_temp_5;
#line 154 "VectorModule.cs"
                            int left = start;
#line 155 "VectorModule.cs"
                            int right = middle;
#line 156 "VectorModule.cs"
                            int position = start;
#line 157 "VectorModule.cs"
                            while (true)
                            {
#line 157 "VectorModule.cs"
                                bool csharp2cuda_temp_6;
#line 157 "VectorModule.cs"
                                if (((left) < (middle)))
                                {
#line 157 "VectorModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 157 "VectorModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 158 "VectorModule.cs"
                                {
#line 159 "VectorModule.cs"
                                    bool csharp2cuda_temp_7;
#line 159 "VectorModule.cs"
                                    if (descending)
                                    {
#line 159 "VectorModule.cs"
                                        double csharp2cuda_temp_8 = (source)[right];
#line 159 "VectorModule.cs"
                                        double csharp2cuda_temp_9 = (source)[left];
#line 159 "VectorModule.cs"
                                        csharp2cuda_temp_7 = ((csharp2cuda_temp_8) > (csharp2cuda_temp_9));
                                    }
                                    else
                                    {
#line 159 "VectorModule.cs"
                                        double csharp2cuda_temp_10 = (source)[right];
#line 159 "VectorModule.cs"
                                        double csharp2cuda_temp_11 = (source)[left];
#line 159 "VectorModule.cs"
                                        csharp2cuda_temp_7 = ((csharp2cuda_temp_10) < (csharp2cuda_temp_11));
                                    }
#line 159 "VectorModule.cs"
                                    bool take_right = csharp2cuda_temp_7;
#line 160 "VectorModule.cs"
#line 160 "VectorModule.cs"
                                    int* csharp2cuda_temp_12 = &(position);
#line 160 "VectorModule.cs"
                                    int csharp2cuda_temp_13 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
#line 160 "VectorModule.cs"
                                    double* csharp2cuda_temp_14 = &((target)[csharp2cuda_temp_13]);
#line 160 "VectorModule.cs"
                                    double csharp2cuda_temp_15;
#line 160 "VectorModule.cs"
                                    if (take_right)
                                    {
#line 160 "VectorModule.cs"
                                        int* csharp2cuda_temp_16 = &(right);
#line 160 "VectorModule.cs"
                                        int csharp2cuda_temp_17 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
#line 160 "VectorModule.cs"
                                        csharp2cuda_temp_15 = (source)[csharp2cuda_temp_17];
                                    }
                                    else
                                    {
#line 160 "VectorModule.cs"
                                        int* csharp2cuda_temp_18 = &(left);
#line 160 "VectorModule.cs"
                                        int csharp2cuda_temp_19 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
#line 160 "VectorModule.cs"
                                        csharp2cuda_temp_15 = (source)[csharp2cuda_temp_19];
                                    }
                                    (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                                }
                            }
#line 162 "VectorModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 163 "VectorModule.cs"
#line 163 "VectorModule.cs"
                                int* csharp2cuda_temp_20 = &(position);
#line 163 "VectorModule.cs"
                                int csharp2cuda_temp_21 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
#line 163 "VectorModule.cs"
                                double* csharp2cuda_temp_22 = &((target)[csharp2cuda_temp_21]);
#line 163 "VectorModule.cs"
                                int* csharp2cuda_temp_23 = &(left);
#line 163 "VectorModule.cs"
                                int csharp2cuda_temp_24 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_23));
#line 163 "VectorModule.cs"
                                double csharp2cuda_temp_25 = (source)[csharp2cuda_temp_24];
                                (*(csharp2cuda_temp_22) = csharp2cuda_temp_25);
                            }
#line 164 "VectorModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 165 "VectorModule.cs"
#line 165 "VectorModule.cs"
                                int* csharp2cuda_temp_26 = &(position);
#line 165 "VectorModule.cs"
                                int csharp2cuda_temp_27 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_26));
#line 165 "VectorModule.cs"
                                double* csharp2cuda_temp_28 = &((target)[csharp2cuda_temp_27]);
#line 165 "VectorModule.cs"
                                int* csharp2cuda_temp_29 = &(right);
#line 165 "VectorModule.cs"
                                int csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
#line 165 "VectorModule.cs"
                                double csharp2cuda_temp_31 = (source)[csharp2cuda_temp_30];
                                (*(csharp2cuda_temp_28) = csharp2cuda_temp_31);
                            }
                        }
#line 150 "VectorModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 150 "VectorModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 167 "VectorModule.cs"
                double* sorted = target;
#line 168 "VectorModule.cs"
#line 168 "VectorModule.cs"
                double** csharp2cuda_temp_32 = &(target);
                (*(csharp2cuda_temp_32) = source);
#line 169 "VectorModule.cs"
#line 169 "VectorModule.cs"
                double** csharp2cuda_temp_33 = &(source);
                (*(csharp2cuda_temp_33) = sorted);
            }
#line 148 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 148 "VectorModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 171 "VectorModule.cs"
    return source;
}

#line 176 "VectorModule.cs"
__device__ void mathblocks_stable_sort_into(
    const double* values,
    int count,
    double* result,
    double* buffer,
    bool descending)
#line 183 "VectorModule.cs"
{
#line 184 "VectorModule.cs"
    {
#line 184 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 185 "VectorModule.cs"
#line 185 "VectorModule.cs"
            double* csharp2cuda_temp_1 = &((result)[index]);
#line 185 "VectorModule.cs"
            double csharp2cuda_temp_2 = (values)[index];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 184 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 186 "VectorModule.cs"
    double* sorted = mathblocks_stable_merge_sort(result, buffer, count, descending);
#line 187 "VectorModule.cs"
    if (((((void*)(sorted))) != (((void*)(result)))))
    {
#line 188 "VectorModule.cs"
        {
#line 188 "VectorModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 189 "VectorModule.cs"
#line 189 "VectorModule.cs"
                double* csharp2cuda_temp_4 = &((result)[index]);
#line 189 "VectorModule.cs"
                double csharp2cuda_temp_5 = (sorted)[index];
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
#line 188 "VectorModule.cs"
                int* csharp2cuda_temp_3 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
            }
        }
    }
}

#line 326 "VectorModule.cs"
__device__ bool mathblocks_vector_arg_extreme_value(
    const double* values,
    int count,
    bool maximum,
    double* value)
#line 332 "VectorModule.cs"
{
#line 333 "VectorModule.cs"
    if (((count) <= (0)))
    {
#line 334 "VectorModule.cs"
        return false;
    }
#line 335 "VectorModule.cs"
    int selected = 0;
#line 336 "VectorModule.cs"
    {
#line 336 "VectorModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 337 "VectorModule.cs"
#line 337 "VectorModule.cs"
            bool csharp2cuda_temp_1;
#line 337 "VectorModule.cs"
            if (maximum)
            {
#line 337 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
#line 337 "VectorModule.cs"
                double csharp2cuda_temp_3 = (values)[selected];
#line 337 "VectorModule.cs"
                csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (csharp2cuda_temp_3));
            }
            else
            {
#line 337 "VectorModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
#line 337 "VectorModule.cs"
                double csharp2cuda_temp_5 = (values)[selected];
#line 337 "VectorModule.cs"
                csharp2cuda_temp_1 = ((csharp2cuda_temp_4) < (csharp2cuda_temp_5));
            }
            if (csharp2cuda_temp_1)
            {
#line 337 "VectorModule.cs"
#line 337 "VectorModule.cs"
                int* csharp2cuda_temp_6 = &(selected);
                (*(csharp2cuda_temp_6) = index);
            }
#line 336 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 338 "VectorModule.cs"
#line 338 "VectorModule.cs"
    double* csharp2cuda_temp_7 = value;
    (*(csharp2cuda_temp_7) = ((double)(selected)));
#line 339 "VectorModule.cs"
    return true;
}

#line 379 "VectorModule.cs"
__device__ void mathblocks_vector_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 385 "VectorModule.cs"
{
#line 386 "VectorModule.cs"
    int thread = threadIdx.x;
#line 387 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 387 "VectorModule.cs"
    if (((input_count) > (0)))
    {
#line 387 "VectorModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 387 "VectorModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 387 "VectorModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 388 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 388 "VectorModule.cs"
    if (((input_count) > (1)))
    {
#line 388 "VectorModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 388 "VectorModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 388 "VectorModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 389 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 389 "VectorModule.cs"
    if (((input_count) > (2)))
    {
#line 389 "VectorModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 389 "VectorModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 389 "VectorModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 391 "VectorModule.cs"
    if (((thread) == (0)))
#line 392 "VectorModule.cs"
    {
#line 393 "VectorModule.cs"
#line 393 "VectorModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 394 "VectorModule.cs"
#line 394 "VectorModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 395 "VectorModule.cs"
#line 395 "VectorModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 396 "VectorModule.cs"
#line 396 "VectorModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 397 "VectorModule.cs"
#line 397 "VectorModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 398 "VectorModule.cs"
#line 398 "VectorModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 398 "VectorModule.cs"
        bool csharp2cuda_temp_9;
#line 398 "VectorModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 398 "VectorModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 398 "VectorModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 399 "VectorModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 400 "VectorModule.cs"
#line 400 "VectorModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 400 "VectorModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 400 "VectorModule.cs"
            bool csharp2cuda_temp_12;
#line 400 "VectorModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 400 "VectorModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 400 "VectorModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 401 "VectorModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 402 "VectorModule.cs"
#line 402 "VectorModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 402 "VectorModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 402 "VectorModule.cs"
            bool csharp2cuda_temp_15;
#line 402 "VectorModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 402 "VectorModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 402 "VectorModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 404 "VectorModule.cs"
    __syncthreads();
#line 405 "VectorModule.cs"
#line 405 "VectorModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 406 "VectorModule.cs"
        return;
    }
#line 408 "VectorModule.cs"
    double* csharp2cuda_temp_17;
#line 408 "VectorModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 408 "VectorModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 408 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 408 "VectorModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 408 "VectorModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 409 "VectorModule.cs"
    double* csharp2cuda_temp_19;
#line 409 "VectorModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 409 "VectorModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 409 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 409 "VectorModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 409 "VectorModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 410 "VectorModule.cs"
    double* csharp2cuda_temp_21;
#line 410 "VectorModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 410 "VectorModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 410 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 410 "VectorModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 410 "VectorModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 411 "VectorModule.cs"
    int* csharp2cuda_temp_23;
#line 411 "VectorModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 411 "VectorModule.cs"
        csharp2cuda_temp_23 = ((int*)(nullptr));
    }
    else
    {
#line 411 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_24 = (first)->data_pointer;
#line 411 "VectorModule.cs"
        csharp2cuda_temp_23 = ((int*)(csharp2cuda_temp_24));
    }
#line 411 "VectorModule.cs"
    const int* boolean_a = csharp2cuda_temp_23;
#line 412 "VectorModule.cs"
    int* csharp2cuda_temp_25;
#line 412 "VectorModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 412 "VectorModule.cs"
        csharp2cuda_temp_25 = ((int*)(nullptr));
    }
    else
    {
#line 412 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_26 = (second)->data_pointer;
#line 412 "VectorModule.cs"
        csharp2cuda_temp_25 = ((int*)(csharp2cuda_temp_26));
    }
#line 412 "VectorModule.cs"
    const int* boolean_b = csharp2cuda_temp_25;
#line 413 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_27 = (output)->data_pointer;
#line 413 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_28;
#line 413 "VectorModule.cs"
    if (((csharp2cuda_temp_27) != (((unsigned long long)(0)))))
    {
#line 413 "VectorModule.cs"
        csharp2cuda_temp_28 = (output)->data_pointer;
    }
    else
    {
#line 413 "VectorModule.cs"
        csharp2cuda_temp_28 = (output)->scratch_pointer;
    }
#line 413 "VectorModule.cs"
    double* result = ((double*)(csharp2cuda_temp_28));
#line 416 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_29 = (output)->data_pointer;
#line 416 "VectorModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_29));
#line 418 "VectorModule.cs"
    switch (opcode)
    {
#line 420 "VectorModule.cs"
        case 0:
#line 421 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 421 "VectorModule.cs"
#line 421 "VectorModule.cs"
                int csharp2cuda_temp_30 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_30);
            }
#line 422 "VectorModule.cs"
            __syncthreads();
#line 423 "VectorModule.cs"
            {
#line 423 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 423 "VectorModule.cs"
                    bool csharp2cuda_temp_33 = (output)->valid;
#line 423 "VectorModule.cs"
                    bool csharp2cuda_temp_34;
#line 423 "VectorModule.cs"
                    if (csharp2cuda_temp_33)
                    {
#line 423 "VectorModule.cs"
                        int csharp2cuda_temp_35 = (first)->count;
#line 423 "VectorModule.cs"
                        csharp2cuda_temp_34 = ((index) < (csharp2cuda_temp_35));
                    }
                    else
                    {
#line 423 "VectorModule.cs"
                        csharp2cuda_temp_34 = false;
                    }
                    if (!(csharp2cuda_temp_34))
                        break;
#line 424 "VectorModule.cs"
#line 424 "VectorModule.cs"
                    double* csharp2cuda_temp_36 = &((result)[index]);
#line 424 "VectorModule.cs"
                    double csharp2cuda_temp_37 = (a)[index];
                    (*(csharp2cuda_temp_36) = fabs(csharp2cuda_temp_37));
#line 423 "VectorModule.cs"
                    int* csharp2cuda_temp_31 = &(index);
#line 423 "VectorModule.cs"
                    int csharp2cuda_temp_32 = *(csharp2cuda_temp_31);
                    (*(csharp2cuda_temp_31) = csharp2cuda_i32_add(csharp2cuda_temp_32, blockDim.x));
                }
            }
#line 425 "VectorModule.cs"
            break;
#line 426 "VectorModule.cs"
        case 1:
#line 427 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 427 "VectorModule.cs"
#line 427 "VectorModule.cs"
                int csharp2cuda_temp_38 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_38);
            }
#line 428 "VectorModule.cs"
            __syncthreads();
#line 429 "VectorModule.cs"
            {
#line 429 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 429 "VectorModule.cs"
                    bool csharp2cuda_temp_41 = (output)->valid;
#line 429 "VectorModule.cs"
                    bool csharp2cuda_temp_42;
#line 429 "VectorModule.cs"
                    if (csharp2cuda_temp_41)
                    {
#line 429 "VectorModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
#line 429 "VectorModule.cs"
                        csharp2cuda_temp_42 = ((index) < (csharp2cuda_temp_43));
                    }
                    else
                    {
#line 429 "VectorModule.cs"
                        csharp2cuda_temp_42 = false;
                    }
                    if (!(csharp2cuda_temp_42))
                        break;
#line 430 "VectorModule.cs"
                    {
#line 431 "VectorModule.cs"
#line 431 "VectorModule.cs"
                        double* csharp2cuda_temp_44 = &((result)[index]);
#line 431 "VectorModule.cs"
                        double csharp2cuda_temp_45 = (a)[index];
#line 431 "VectorModule.cs"
                        double csharp2cuda_temp_46 = (second)->scalar_value;
                        (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 432 "VectorModule.cs"
#line 432 "VectorModule.cs"
                        double csharp2cuda_temp_47 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_47))))
                        {
#line 432 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 429 "VectorModule.cs"
                    int* csharp2cuda_temp_39 = &(index);
#line 429 "VectorModule.cs"
                    int csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
                    (*(csharp2cuda_temp_39) = csharp2cuda_i32_add(csharp2cuda_temp_40, blockDim.x));
                }
            }
#line 434 "VectorModule.cs"
            break;
#line 435 "VectorModule.cs"
        case 2:
        case 9:
        case 26:
        case 47:
#line 439 "VectorModule.cs"
            if (((thread) == (0)))
#line 440 "VectorModule.cs"
            {
#line 441 "VectorModule.cs"
#line 441 "VectorModule.cs"
                int csharp2cuda_temp_48 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_48);
#line 442 "VectorModule.cs"
#line 442 "VectorModule.cs"
                int csharp2cuda_temp_49 = (first)->count;
#line 442 "VectorModule.cs"
                int csharp2cuda_temp_50 = (second)->count;
                if (((csharp2cuda_temp_49) != (csharp2cuda_temp_50)))
                {
#line 442 "VectorModule.cs"
#line 442 "VectorModule.cs"
                    int* csharp2cuda_temp_51 = &((output)->valid);
                    (*(csharp2cuda_temp_51) = 0);
                }
            }
#line 444 "VectorModule.cs"
            __syncthreads();
#line 445 "VectorModule.cs"
            {
#line 445 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 445 "VectorModule.cs"
                    bool csharp2cuda_temp_54 = (output)->valid;
#line 445 "VectorModule.cs"
                    bool csharp2cuda_temp_55;
#line 445 "VectorModule.cs"
                    if (csharp2cuda_temp_54)
                    {
#line 445 "VectorModule.cs"
                        int csharp2cuda_temp_56 = (first)->count;
#line 445 "VectorModule.cs"
                        csharp2cuda_temp_55 = ((index) < (csharp2cuda_temp_56));
                    }
                    else
                    {
#line 445 "VectorModule.cs"
                        csharp2cuda_temp_55 = false;
                    }
                    if (!(csharp2cuda_temp_55))
                        break;
#line 446 "VectorModule.cs"
                    {
#line 447 "VectorModule.cs"
                        double csharp2cuda_temp_57;
#line 447 "VectorModule.cs"
                        if (((opcode) == (2)))
                        {
#line 447 "VectorModule.cs"
                            double csharp2cuda_temp_58 = (a)[index];
#line 447 "VectorModule.cs"
                            double csharp2cuda_temp_59 = (b)[index];
#line 447 "VectorModule.cs"
                            csharp2cuda_temp_57 = __dadd_rn(csharp2cuda_temp_58, csharp2cuda_temp_59);
                        }
                        else
                        {
#line 448 "VectorModule.cs"
                            double csharp2cuda_temp_60;
#line 448 "VectorModule.cs"
                            if (((opcode) == (9)))
                            {
#line 448 "VectorModule.cs"
                                double csharp2cuda_temp_61 = (a)[index];
#line 448 "VectorModule.cs"
                                double csharp2cuda_temp_62 = (b)[index];
#line 448 "VectorModule.cs"
                                csharp2cuda_temp_60 = __ddiv_rn(csharp2cuda_temp_61, csharp2cuda_temp_62);
                            }
                            else
                            {
#line 449 "VectorModule.cs"
                                double csharp2cuda_temp_63;
#line 449 "VectorModule.cs"
                                if (((opcode) == (26)))
                                {
#line 449 "VectorModule.cs"
                                    double csharp2cuda_temp_64 = (a)[index];
#line 449 "VectorModule.cs"
                                    double csharp2cuda_temp_65 = (b)[index];
#line 449 "VectorModule.cs"
                                    csharp2cuda_temp_63 = __dmul_rn(csharp2cuda_temp_64, csharp2cuda_temp_65);
                                }
                                else
                                {
#line 450 "VectorModule.cs"
                                    double csharp2cuda_temp_66 = (a)[index];
#line 450 "VectorModule.cs"
                                    double csharp2cuda_temp_67 = (b)[index];
#line 449 "VectorModule.cs"
                                    csharp2cuda_temp_63 = __dsub_rn(csharp2cuda_temp_66, csharp2cuda_temp_67);
                                }
#line 448 "VectorModule.cs"
                                csharp2cuda_temp_60 = csharp2cuda_temp_63;
                            }
#line 447 "VectorModule.cs"
                            csharp2cuda_temp_57 = csharp2cuda_temp_60;
                        }
#line 447 "VectorModule.cs"
                        double value = csharp2cuda_temp_57;
#line 451 "VectorModule.cs"
#line 451 "VectorModule.cs"
                        double* csharp2cuda_temp_68 = &((result)[index]);
                        (*(csharp2cuda_temp_68) = value);
#line 452 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 452 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 445 "VectorModule.cs"
                    int* csharp2cuda_temp_52 = &(index);
#line 445 "VectorModule.cs"
                    int csharp2cuda_temp_53 = *(csharp2cuda_temp_52);
                    (*(csharp2cuda_temp_52) = csharp2cuda_i32_add(csharp2cuda_temp_53, blockDim.x));
                }
            }
#line 454 "VectorModule.cs"
            break;
#line 455 "VectorModule.cs"
        case 3:
#line 456 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 456 "VectorModule.cs"
#line 456 "VectorModule.cs"
                int csharp2cuda_temp_69 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_69, 1));
            }
#line 457 "VectorModule.cs"
            __syncthreads();
#line 458 "VectorModule.cs"
            {
#line 458 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 458 "VectorModule.cs"
                    bool csharp2cuda_temp_72 = (output)->valid;
#line 458 "VectorModule.cs"
                    bool csharp2cuda_temp_73;
#line 458 "VectorModule.cs"
                    if (csharp2cuda_temp_72)
                    {
#line 458 "VectorModule.cs"
                        int csharp2cuda_temp_74 = (first)->count;
#line 458 "VectorModule.cs"
                        csharp2cuda_temp_73 = ((index) < (csharp2cuda_temp_74));
                    }
                    else
                    {
#line 458 "VectorModule.cs"
                        csharp2cuda_temp_73 = false;
                    }
                    if (!(csharp2cuda_temp_73))
                        break;
#line 459 "VectorModule.cs"
#line 459 "VectorModule.cs"
                    double* csharp2cuda_temp_75 = &((result)[index]);
#line 459 "VectorModule.cs"
                    double csharp2cuda_temp_76 = (a)[index];
                    (*(csharp2cuda_temp_75) = csharp2cuda_temp_76);
#line 458 "VectorModule.cs"
                    int* csharp2cuda_temp_70 = &(index);
#line 458 "VectorModule.cs"
                    int csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
                    (*(csharp2cuda_temp_70) = csharp2cuda_i32_add(csharp2cuda_temp_71, blockDim.x));
                }
            }
#line 460 "VectorModule.cs"
#line 460 "VectorModule.cs"
            bool csharp2cuda_temp_77;
#line 460 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 460 "VectorModule.cs"
                csharp2cuda_temp_77 = (output)->valid;
            }
            else
            {
#line 460 "VectorModule.cs"
                csharp2cuda_temp_77 = false;
            }
            if (csharp2cuda_temp_77)
            {
#line 460 "VectorModule.cs"
#line 460 "VectorModule.cs"
                int csharp2cuda_temp_78 = (first)->count;
#line 460 "VectorModule.cs"
                double* csharp2cuda_temp_79 = &((result)[csharp2cuda_temp_78]);
#line 460 "VectorModule.cs"
                double csharp2cuda_temp_80 = (second)->scalar_value;
                (*(csharp2cuda_temp_79) = csharp2cuda_temp_80);
            }
#line 461 "VectorModule.cs"
            break;
#line 462 "VectorModule.cs"
        case 4:
        case 5:
#line 464 "VectorModule.cs"
#line 464 "VectorModule.cs"
            bool csharp2cuda_temp_81;
#line 464 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 465 "VectorModule.cs"
                int csharp2cuda_temp_82 = (first)->count;
#line 465 "VectorModule.cs"
                double* csharp2cuda_temp_83 = &((output)->scalar_value);
#line 465 "VectorModule.cs"
                bool csharp2cuda_temp_84 = mathblocks_vector_arg_extreme_value(a, csharp2cuda_temp_82, ((opcode) == (4)), csharp2cuda_temp_83);
#line 464 "VectorModule.cs"
                csharp2cuda_temp_81 = (!(csharp2cuda_temp_84));
            }
            else
            {
#line 464 "VectorModule.cs"
                csharp2cuda_temp_81 = false;
            }
            if (csharp2cuda_temp_81)
            {
#line 466 "VectorModule.cs"
#line 466 "VectorModule.cs"
                int* csharp2cuda_temp_85 = &((output)->valid);
                (*(csharp2cuda_temp_85) = 0);
            }
#line 467 "VectorModule.cs"
            break;
#line 468 "VectorModule.cs"
        case 6:
#line 469 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 469 "VectorModule.cs"
#line 469 "VectorModule.cs"
                int csharp2cuda_temp_86 = (first)->count;
#line 469 "VectorModule.cs"
                int csharp2cuda_temp_87 = (second)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_86, csharp2cuda_temp_87));
            }
#line 470 "VectorModule.cs"
            __syncthreads();
#line 471 "VectorModule.cs"
            {
#line 471 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 471 "VectorModule.cs"
                    bool csharp2cuda_temp_90 = (output)->valid;
#line 471 "VectorModule.cs"
                    bool csharp2cuda_temp_91;
#line 471 "VectorModule.cs"
                    if (csharp2cuda_temp_90)
                    {
#line 471 "VectorModule.cs"
                        int csharp2cuda_temp_92 = (first)->count;
#line 471 "VectorModule.cs"
                        csharp2cuda_temp_91 = ((index) < (csharp2cuda_temp_92));
                    }
                    else
                    {
#line 471 "VectorModule.cs"
                        csharp2cuda_temp_91 = false;
                    }
                    if (!(csharp2cuda_temp_91))
                        break;
#line 472 "VectorModule.cs"
#line 472 "VectorModule.cs"
                    double* csharp2cuda_temp_93 = &((result)[index]);
#line 472 "VectorModule.cs"
                    double csharp2cuda_temp_94 = (a)[index];
                    (*(csharp2cuda_temp_93) = csharp2cuda_temp_94);
#line 471 "VectorModule.cs"
                    int* csharp2cuda_temp_88 = &(index);
#line 471 "VectorModule.cs"
                    int csharp2cuda_temp_89 = *(csharp2cuda_temp_88);
                    (*(csharp2cuda_temp_88) = csharp2cuda_i32_add(csharp2cuda_temp_89, blockDim.x));
                }
            }
#line 473 "VectorModule.cs"
            {
#line 473 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 473 "VectorModule.cs"
                    bool csharp2cuda_temp_97 = (output)->valid;
#line 473 "VectorModule.cs"
                    bool csharp2cuda_temp_98;
#line 473 "VectorModule.cs"
                    if (csharp2cuda_temp_97)
                    {
#line 473 "VectorModule.cs"
                        int csharp2cuda_temp_99 = (second)->count;
#line 473 "VectorModule.cs"
                        csharp2cuda_temp_98 = ((index) < (csharp2cuda_temp_99));
                    }
                    else
                    {
#line 473 "VectorModule.cs"
                        csharp2cuda_temp_98 = false;
                    }
                    if (!(csharp2cuda_temp_98))
                        break;
#line 474 "VectorModule.cs"
#line 474 "VectorModule.cs"
                    int csharp2cuda_temp_100 = (first)->count;
#line 474 "VectorModule.cs"
                    double* csharp2cuda_temp_101 = &((result)[csharp2cuda_i32_add(csharp2cuda_temp_100, index)]);
#line 474 "VectorModule.cs"
                    double csharp2cuda_temp_102 = (b)[index];
                    (*(csharp2cuda_temp_101) = csharp2cuda_temp_102);
#line 473 "VectorModule.cs"
                    int* csharp2cuda_temp_95 = &(index);
#line 473 "VectorModule.cs"
                    int csharp2cuda_temp_96 = *(csharp2cuda_temp_95);
                    (*(csharp2cuda_temp_95) = csharp2cuda_i32_add(csharp2cuda_temp_96, blockDim.x));
                }
            }
#line 475 "VectorModule.cs"
            break;
#line 476 "VectorModule.cs"
        case 7:
#line 477 "VectorModule.cs"
            if (((thread) == (0)))
#line 478 "VectorModule.cs"
            {
#line 479 "VectorModule.cs"
#line 479 "VectorModule.cs"
                int csharp2cuda_temp_103 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_103);
#line 480 "VectorModule.cs"
                double product = 1.0;
#line 481 "VectorModule.cs"
                {
#line 481 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 481 "VectorModule.cs"
                        bool csharp2cuda_temp_105 = (output)->valid;
#line 481 "VectorModule.cs"
                        bool csharp2cuda_temp_106;
#line 481 "VectorModule.cs"
                        if (csharp2cuda_temp_105)
                        {
#line 481 "VectorModule.cs"
                            int csharp2cuda_temp_107 = (first)->count;
#line 481 "VectorModule.cs"
                            csharp2cuda_temp_106 = ((index) < (csharp2cuda_temp_107));
                        }
                        else
                        {
#line 481 "VectorModule.cs"
                            csharp2cuda_temp_106 = false;
                        }
                        if (!(csharp2cuda_temp_106))
                            break;
#line 482 "VectorModule.cs"
                        {
#line 483 "VectorModule.cs"
#line 483 "VectorModule.cs"
                            double* csharp2cuda_temp_108 = &(product);
#line 483 "VectorModule.cs"
                            double csharp2cuda_temp_109 = *(csharp2cuda_temp_108);
#line 483 "VectorModule.cs"
                            double csharp2cuda_temp_110 = (a)[index];
                            (*(csharp2cuda_temp_108) = __dmul_rn(csharp2cuda_temp_109, csharp2cuda_temp_110));
#line 484 "VectorModule.cs"
#line 484 "VectorModule.cs"
                            double* csharp2cuda_temp_111 = &((result)[index]);
                            (*(csharp2cuda_temp_111) = product);
#line 485 "VectorModule.cs"
                            if ((!(isfinite(product))))
                            {
#line 485 "VectorModule.cs"
#line 485 "VectorModule.cs"
                                int* csharp2cuda_temp_112 = &((output)->valid);
                                (*(csharp2cuda_temp_112) = 0);
                            }
                        }
#line 481 "VectorModule.cs"
                        int* csharp2cuda_temp_104 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_104));
                    }
                }
            }
#line 488 "VectorModule.cs"
            break;
#line 489 "VectorModule.cs"
        case 8:
#line 490 "VectorModule.cs"
            if (((thread) == (0)))
#line 491 "VectorModule.cs"
            {
#line 492 "VectorModule.cs"
#line 492 "VectorModule.cs"
                int csharp2cuda_temp_113 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_113);
#line 493 "VectorModule.cs"
                double sum = 0.0;
#line 494 "VectorModule.cs"
                {
#line 494 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 494 "VectorModule.cs"
                        bool csharp2cuda_temp_115 = (output)->valid;
#line 494 "VectorModule.cs"
                        bool csharp2cuda_temp_116;
#line 494 "VectorModule.cs"
                        if (csharp2cuda_temp_115)
                        {
#line 494 "VectorModule.cs"
                            int csharp2cuda_temp_117 = (first)->count;
#line 494 "VectorModule.cs"
                            csharp2cuda_temp_116 = ((index) < (csharp2cuda_temp_117));
                        }
                        else
                        {
#line 494 "VectorModule.cs"
                            csharp2cuda_temp_116 = false;
                        }
                        if (!(csharp2cuda_temp_116))
                            break;
#line 495 "VectorModule.cs"
                        {
#line 496 "VectorModule.cs"
#line 496 "VectorModule.cs"
                            double* csharp2cuda_temp_118 = &(sum);
#line 496 "VectorModule.cs"
                            double csharp2cuda_temp_119 = *(csharp2cuda_temp_118);
#line 496 "VectorModule.cs"
                            double csharp2cuda_temp_120 = (a)[index];
                            (*(csharp2cuda_temp_118) = __dadd_rn(csharp2cuda_temp_119, csharp2cuda_temp_120));
#line 497 "VectorModule.cs"
#line 497 "VectorModule.cs"
                            double* csharp2cuda_temp_121 = &((result)[index]);
                            (*(csharp2cuda_temp_121) = sum);
#line 498 "VectorModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 498 "VectorModule.cs"
#line 498 "VectorModule.cs"
                                int* csharp2cuda_temp_122 = &((output)->valid);
                                (*(csharp2cuda_temp_122) = 0);
                            }
                        }
#line 494 "VectorModule.cs"
                        int* csharp2cuda_temp_114 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_114));
                    }
                }
            }
#line 501 "VectorModule.cs"
            break;
#line 502 "VectorModule.cs"
        case 10:
#line 503 "VectorModule.cs"
            if (((thread) == (0)))
#line 504 "VectorModule.cs"
            {
#line 505 "VectorModule.cs"
#line 505 "VectorModule.cs"
                int csharp2cuda_temp_123 = (first)->count;
#line 505 "VectorModule.cs"
                int csharp2cuda_temp_124 = (second)->count;
                if (((csharp2cuda_temp_123) != (csharp2cuda_temp_124)))
                {
#line 505 "VectorModule.cs"
#line 505 "VectorModule.cs"
                    int* csharp2cuda_temp_125 = &((output)->valid);
                    (*(csharp2cuda_temp_125) = 0);
                }
                else
#line 507 "VectorModule.cs"
                {
#line 508 "VectorModule.cs"
#line 508 "VectorModule.cs"
                    double* csharp2cuda_temp_126 = &((output)->scalar_value);
#line 508 "VectorModule.cs"
                    int csharp2cuda_temp_127 = (first)->count;
#line 508 "VectorModule.cs"
                    double csharp2cuda_temp_128 = mathblocks_compensated_product_sum(a, b, csharp2cuda_temp_127);
                    (*(csharp2cuda_temp_126) = csharp2cuda_temp_128);
#line 509 "VectorModule.cs"
#line 509 "VectorModule.cs"
                    double csharp2cuda_temp_129 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_129))))
                    {
#line 509 "VectorModule.cs"
#line 509 "VectorModule.cs"
                        int* csharp2cuda_temp_130 = &((output)->valid);
                        (*(csharp2cuda_temp_130) = 0);
                    }
                }
            }
#line 512 "VectorModule.cs"
            break;
#line 513 "VectorModule.cs"
        case 11:
        case 15:
        case 20:
#line 516 "VectorModule.cs"
            if (((thread) == (0)))
#line 517 "VectorModule.cs"
            {
#line 518 "VectorModule.cs"
#line 518 "VectorModule.cs"
                int csharp2cuda_temp_131 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_131);
#line 519 "VectorModule.cs"
#line 519 "VectorModule.cs"
                int csharp2cuda_temp_132 = (first)->count;
#line 519 "VectorModule.cs"
                int csharp2cuda_temp_133 = (second)->count;
                if (((csharp2cuda_temp_132) != (csharp2cuda_temp_133)))
                {
#line 519 "VectorModule.cs"
#line 519 "VectorModule.cs"
                    int* csharp2cuda_temp_134 = &((output)->valid);
                    (*(csharp2cuda_temp_134) = 0);
                }
            }
#line 521 "VectorModule.cs"
            __syncthreads();
#line 522 "VectorModule.cs"
            {
#line 522 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 522 "VectorModule.cs"
                    bool csharp2cuda_temp_137 = (output)->valid;
#line 522 "VectorModule.cs"
                    bool csharp2cuda_temp_138;
#line 522 "VectorModule.cs"
                    if (csharp2cuda_temp_137)
                    {
#line 522 "VectorModule.cs"
                        int csharp2cuda_temp_139 = (first)->count;
#line 522 "VectorModule.cs"
                        csharp2cuda_temp_138 = ((index) < (csharp2cuda_temp_139));
                    }
                    else
                    {
#line 522 "VectorModule.cs"
                        csharp2cuda_temp_138 = false;
                    }
                    if (!(csharp2cuda_temp_138))
                        break;
#line 523 "VectorModule.cs"
#line 523 "VectorModule.cs"
                    int* csharp2cuda_temp_140 = &((boolean_result)[index]);
#line 523 "VectorModule.cs"
                    bool csharp2cuda_temp_141;
#line 523 "VectorModule.cs"
                    if (((opcode) == (11)))
                    {
#line 523 "VectorModule.cs"
                        double csharp2cuda_temp_142 = (a)[index];
#line 523 "VectorModule.cs"
                        double csharp2cuda_temp_143 = (b)[index];
#line 523 "VectorModule.cs"
                        csharp2cuda_temp_141 = ((csharp2cuda_temp_142) == (csharp2cuda_temp_143));
                    }
                    else
                    {
#line 524 "VectorModule.cs"
                        bool csharp2cuda_temp_144;
#line 524 "VectorModule.cs"
                        if (((opcode) == (15)))
                        {
#line 524 "VectorModule.cs"
                            double csharp2cuda_temp_145 = (a)[index];
#line 524 "VectorModule.cs"
                            double csharp2cuda_temp_146 = (b)[index];
#line 524 "VectorModule.cs"
                            csharp2cuda_temp_144 = ((csharp2cuda_temp_145) > (csharp2cuda_temp_146));
                        }
                        else
                        {
#line 525 "VectorModule.cs"
                            double csharp2cuda_temp_147 = (a)[index];
#line 525 "VectorModule.cs"
                            double csharp2cuda_temp_148 = (b)[index];
#line 524 "VectorModule.cs"
                            csharp2cuda_temp_144 = ((csharp2cuda_temp_147) < (csharp2cuda_temp_148));
                        }
#line 523 "VectorModule.cs"
                        csharp2cuda_temp_141 = csharp2cuda_temp_144;
                    }
                    (*(csharp2cuda_temp_140) = csharp2cuda_temp_141);
#line 522 "VectorModule.cs"
                    int* csharp2cuda_temp_135 = &(index);
#line 522 "VectorModule.cs"
                    int csharp2cuda_temp_136 = *(csharp2cuda_temp_135);
                    (*(csharp2cuda_temp_135) = csharp2cuda_i32_add(csharp2cuda_temp_136, blockDim.x));
                }
            }
#line 526 "VectorModule.cs"
            break;
#line 527 "VectorModule.cs"
        case 12:
        case 27:
        case 44:
#line 530 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 530 "VectorModule.cs"
#line 530 "VectorModule.cs"
                int csharp2cuda_temp_149 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_149);
            }
#line 531 "VectorModule.cs"
            __syncthreads();
#line 532 "VectorModule.cs"
            {
#line 532 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 532 "VectorModule.cs"
                    bool csharp2cuda_temp_152 = (output)->valid;
#line 532 "VectorModule.cs"
                    bool csharp2cuda_temp_153;
#line 532 "VectorModule.cs"
                    if (csharp2cuda_temp_152)
                    {
#line 532 "VectorModule.cs"
                        int csharp2cuda_temp_154 = (first)->count;
#line 532 "VectorModule.cs"
                        csharp2cuda_temp_153 = ((index) < (csharp2cuda_temp_154));
                    }
                    else
                    {
#line 532 "VectorModule.cs"
                        csharp2cuda_temp_153 = false;
                    }
                    if (!(csharp2cuda_temp_153))
                        break;
#line 533 "VectorModule.cs"
                    {
#line 534 "VectorModule.cs"
                        double csharp2cuda_temp_155;
#line 534 "VectorModule.cs"
                        if (((opcode) == (12)))
                        {
#line 534 "VectorModule.cs"
                            double csharp2cuda_temp_156 = (a)[index];
#line 534 "VectorModule.cs"
                            csharp2cuda_temp_155 = mathblocks_exponential(csharp2cuda_temp_156);
                        }
                        else
                        {
#line 535 "VectorModule.cs"
                            double csharp2cuda_temp_157;
#line 535 "VectorModule.cs"
                            if (((opcode) == (27)))
                            {
#line 535 "VectorModule.cs"
                                double csharp2cuda_temp_158 = (a)[index];
#line 535 "VectorModule.cs"
                                csharp2cuda_temp_157 = mathblocks_natural_logarithm(csharp2cuda_temp_158);
                            }
                            else
                            {
#line 536 "VectorModule.cs"
                                double csharp2cuda_temp_159 = (a)[index];
#line 535 "VectorModule.cs"
                                csharp2cuda_temp_157 = mathblocks_square_root(csharp2cuda_temp_159);
                            }
#line 534 "VectorModule.cs"
                            csharp2cuda_temp_155 = csharp2cuda_temp_157;
                        }
#line 534 "VectorModule.cs"
                        double value = csharp2cuda_temp_155;
#line 537 "VectorModule.cs"
#line 537 "VectorModule.cs"
                        double* csharp2cuda_temp_160 = &((result)[index]);
                        (*(csharp2cuda_temp_160) = value);
#line 538 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 538 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 532 "VectorModule.cs"
                    int* csharp2cuda_temp_150 = &(index);
#line 532 "VectorModule.cs"
                    int csharp2cuda_temp_151 = *(csharp2cuda_temp_150);
                    (*(csharp2cuda_temp_150) = csharp2cuda_i32_add(csharp2cuda_temp_151, blockDim.x));
                }
            }
#line 540 "VectorModule.cs"
            break;
#line 541 "VectorModule.cs"
        case 13:
#line 542 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 542 "VectorModule.cs"
#line 542 "VectorModule.cs"
                int csharp2cuda_temp_161 = (second)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_161);
            }
#line 543 "VectorModule.cs"
            __syncthreads();
#line 544 "VectorModule.cs"
            {
#line 544 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 544 "VectorModule.cs"
                    bool csharp2cuda_temp_164 = (output)->valid;
#line 544 "VectorModule.cs"
                    bool csharp2cuda_temp_165;
#line 544 "VectorModule.cs"
                    if (csharp2cuda_temp_164)
                    {
#line 544 "VectorModule.cs"
                        int csharp2cuda_temp_166 = (second)->count;
#line 544 "VectorModule.cs"
                        csharp2cuda_temp_165 = ((index) < (csharp2cuda_temp_166));
                    }
                    else
                    {
#line 544 "VectorModule.cs"
                        csharp2cuda_temp_165 = false;
                    }
                    if (!(csharp2cuda_temp_165))
                        break;
#line 545 "VectorModule.cs"
                    {
#line 546 "VectorModule.cs"
                        int source_index = 0;
#line 547 "VectorModule.cs"
#line 547 "VectorModule.cs"
                        double csharp2cuda_temp_167 = (b)[index];
#line 547 "VectorModule.cs"
                        int* csharp2cuda_temp_168 = &(source_index);
#line 547 "VectorModule.cs"
                        bool csharp2cuda_temp_169 = mathblocks_nonnegative_integer(csharp2cuda_temp_167, csharp2cuda_temp_168);
#line 547 "VectorModule.cs"
                        bool csharp2cuda_temp_170;
#line 547 "VectorModule.cs"
                        if (!((!(csharp2cuda_temp_169))))
                        {
#line 547 "VectorModule.cs"
                            int csharp2cuda_temp_171 = (first)->count;
#line 547 "VectorModule.cs"
                            csharp2cuda_temp_170 = ((source_index) >= (csharp2cuda_temp_171));
                        }
                        else
                        {
#line 547 "VectorModule.cs"
                            csharp2cuda_temp_170 = true;
                        }
                        if (csharp2cuda_temp_170)
                        {
#line 548 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                        else
                        {
#line 550 "VectorModule.cs"
#line 550 "VectorModule.cs"
                            double* csharp2cuda_temp_172 = &((result)[index]);
#line 550 "VectorModule.cs"
                            double csharp2cuda_temp_173 = (a)[source_index];
                            (*(csharp2cuda_temp_172) = csharp2cuda_temp_173);
                        }
                    }
#line 544 "VectorModule.cs"
                    int* csharp2cuda_temp_162 = &(index);
#line 544 "VectorModule.cs"
                    int csharp2cuda_temp_163 = *(csharp2cuda_temp_162);
                    (*(csharp2cuda_temp_162) = csharp2cuda_i32_add(csharp2cuda_temp_163, blockDim.x));
                }
            }
#line 552 "VectorModule.cs"
            break;
#line 553 "VectorModule.cs"
        case 14:
#line 554 "VectorModule.cs"
#line 554 "VectorModule.cs"
            bool csharp2cuda_temp_174;
#line 554 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 555 "VectorModule.cs"
                unsigned long long csharp2cuda_temp_175 = (output)->scratch_pointer;
#line 555 "VectorModule.cs"
                bool csharp2cuda_temp_176;
#line 555 "VectorModule.cs"
                if (!(((csharp2cuda_temp_175) == (((unsigned long long)(0))))))
                {
#line 556 "VectorModule.cs"
                    int csharp2cuda_temp_177 = (first)->count;
#line 556 "VectorModule.cs"
                    double* csharp2cuda_temp_178 = &((output)->scalar_value);
#line 556 "VectorModule.cs"
                    bool csharp2cuda_temp_179 = mathblocks_vector_geometric_mean_value(a, csharp2cuda_temp_177, result, csharp2cuda_temp_178);
#line 555 "VectorModule.cs"
                    csharp2cuda_temp_176 = (!(csharp2cuda_temp_179));
                }
                else
                {
#line 555 "VectorModule.cs"
                    csharp2cuda_temp_176 = true;
                }
#line 554 "VectorModule.cs"
                csharp2cuda_temp_174 = csharp2cuda_temp_176;
            }
            else
            {
#line 554 "VectorModule.cs"
                csharp2cuda_temp_174 = false;
            }
            if (csharp2cuda_temp_174)
            {
#line 557 "VectorModule.cs"
#line 557 "VectorModule.cs"
                int* csharp2cuda_temp_180 = &((output)->valid);
                (*(csharp2cuda_temp_180) = 0);
            }
#line 558 "VectorModule.cs"
            break;
#line 559 "VectorModule.cs"
        case 16:
#line 560 "VectorModule.cs"
            if (((thread) == (0)))
#line 561 "VectorModule.cs"
            {
#line 562 "VectorModule.cs"
                int index = 0;
#line 563 "VectorModule.cs"
#line 563 "VectorModule.cs"
                double csharp2cuda_temp_181 = (second)->scalar_value;
#line 563 "VectorModule.cs"
                int* csharp2cuda_temp_182 = &(index);
#line 563 "VectorModule.cs"
                bool csharp2cuda_temp_183 = mathblocks_nonnegative_integer(csharp2cuda_temp_181, csharp2cuda_temp_182);
#line 563 "VectorModule.cs"
                bool csharp2cuda_temp_184;
#line 563 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_183))))
                {
#line 563 "VectorModule.cs"
                    int csharp2cuda_temp_185 = (first)->count;
#line 563 "VectorModule.cs"
                    csharp2cuda_temp_184 = ((index) >= (csharp2cuda_temp_185));
                }
                else
                {
#line 563 "VectorModule.cs"
                    csharp2cuda_temp_184 = true;
                }
                if (csharp2cuda_temp_184)
                {
#line 564 "VectorModule.cs"
#line 564 "VectorModule.cs"
                    int* csharp2cuda_temp_186 = &((output)->valid);
                    (*(csharp2cuda_temp_186) = 0);
                }
                else
                {
#line 566 "VectorModule.cs"
#line 566 "VectorModule.cs"
                    double* csharp2cuda_temp_187 = &((output)->scalar_value);
#line 566 "VectorModule.cs"
                    double csharp2cuda_temp_188 = (a)[index];
                    (*(csharp2cuda_temp_187) = csharp2cuda_temp_188);
                }
            }
#line 568 "VectorModule.cs"
            break;
#line 569 "VectorModule.cs"
        case 17:
        case 18:
#line 571 "VectorModule.cs"
            if (((thread) == (0)))
#line 572 "VectorModule.cs"
            {
#line 573 "VectorModule.cs"
                double csharp2cuda_temp_189;
#line 573 "VectorModule.cs"
                if (((opcode) == (17)))
                {
#line 574 "VectorModule.cs"
                    int csharp2cuda_temp_190 = (first)->count;
#line 573 "VectorModule.cs"
                    csharp2cuda_temp_189 = mathblocks_compensated_absolute_sum(a, csharp2cuda_temp_190);
                }
                else
                {
#line 575 "VectorModule.cs"
                    int csharp2cuda_temp_191 = (first)->count;
#line 575 "VectorModule.cs"
                    double csharp2cuda_temp_192 = mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_191);
#line 573 "VectorModule.cs"
                    csharp2cuda_temp_189 = mathblocks_square_root(csharp2cuda_temp_192);
                }
#line 573 "VectorModule.cs"
                double norm = csharp2cuda_temp_189;
#line 576 "VectorModule.cs"
#line 576 "VectorModule.cs"
                double* csharp2cuda_temp_193 = &((output)->scalar_value);
                (*(csharp2cuda_temp_193) = norm);
#line 577 "VectorModule.cs"
                if ((!(isfinite(norm))))
                {
#line 577 "VectorModule.cs"
#line 577 "VectorModule.cs"
                    int* csharp2cuda_temp_194 = &((output)->valid);
                    (*(csharp2cuda_temp_194) = 0);
                }
            }
#line 579 "VectorModule.cs"
            break;
#line 580 "VectorModule.cs"
        case 19:
#line 581 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 581 "VectorModule.cs"
#line 581 "VectorModule.cs"
                double* csharp2cuda_temp_195 = &((output)->scalar_value);
#line 581 "VectorModule.cs"
                int csharp2cuda_temp_196 = (first)->count;
                (*(csharp2cuda_temp_195) = ((double)(csharp2cuda_temp_196)));
            }
#line 582 "VectorModule.cs"
            break;
#line 583 "VectorModule.cs"
        case 21:
#line 584 "VectorModule.cs"
            if (((thread) == (0)))
#line 585 "VectorModule.cs"
            {
#line 586 "VectorModule.cs"
                int count = 0;
#line 587 "VectorModule.cs"
#line 587 "VectorModule.cs"
                double csharp2cuda_temp_197 = (third)->scalar_value;
#line 587 "VectorModule.cs"
                int* csharp2cuda_temp_198 = &(count);
#line 587 "VectorModule.cs"
                bool csharp2cuda_temp_199 = mathblocks_nonnegative_integer(csharp2cuda_temp_197, csharp2cuda_temp_198);
#line 587 "VectorModule.cs"
                bool csharp2cuda_temp_200;
#line 587 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_199))))
                {
#line 587 "VectorModule.cs"
                    csharp2cuda_temp_200 = ((count) <= (0));
                }
                else
                {
#line 587 "VectorModule.cs"
                    csharp2cuda_temp_200 = true;
                }
#line 587 "VectorModule.cs"
                bool csharp2cuda_temp_201;
#line 587 "VectorModule.cs"
                if (!(csharp2cuda_temp_200))
                {
#line 587 "VectorModule.cs"
                    csharp2cuda_temp_201 = ((count) > (1000000));
                }
                else
                {
#line 587 "VectorModule.cs"
                    csharp2cuda_temp_201 = true;
                }
                if (csharp2cuda_temp_201)
                {
#line 588 "VectorModule.cs"
#line 588 "VectorModule.cs"
                    int* csharp2cuda_temp_202 = &((output)->valid);
                    (*(csharp2cuda_temp_202) = 0);
                }
                else
                {
#line 590 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, count);
                }
            }
#line 592 "VectorModule.cs"
            __syncthreads();
#line 593 "VectorModule.cs"
            if ((output)->valid)
#line 594 "VectorModule.cs"
            {
#line 595 "VectorModule.cs"
                double start = (first)->scalar_value;
#line 596 "VectorModule.cs"
                double end = (second)->scalar_value;
#line 597 "VectorModule.cs"
                int csharp2cuda_temp_203 = (output)->count;
#line 597 "VectorModule.cs"
                double csharp2cuda_temp_204;
#line 597 "VectorModule.cs"
                if (((csharp2cuda_temp_203) == (1)))
                {
#line 597 "VectorModule.cs"
                    csharp2cuda_temp_204 = 0.0;
                }
                else
                {
#line 597 "VectorModule.cs"
                    int csharp2cuda_temp_205 = (output)->count;
#line 597 "VectorModule.cs"
                    csharp2cuda_temp_204 = __ddiv_rn(__dsub_rn(end, start), ((double)(csharp2cuda_i32_sub(csharp2cuda_temp_205, 1))));
                }
#line 597 "VectorModule.cs"
                double step = csharp2cuda_temp_204;
#line 598 "VectorModule.cs"
                {
#line 598 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 598 "VectorModule.cs"
                        int csharp2cuda_temp_208 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_208))))
                            break;
#line 599 "VectorModule.cs"
                        {
#line 600 "VectorModule.cs"
#line 600 "VectorModule.cs"
                            double* csharp2cuda_temp_209 = &((result)[index]);
#line 600 "VectorModule.cs"
                            int csharp2cuda_temp_210 = (output)->count;
#line 600 "VectorModule.cs"
                            double csharp2cuda_temp_211;
#line 600 "VectorModule.cs"
                            if (((index) == (csharp2cuda_i32_sub(csharp2cuda_temp_210, 1))))
                            {
#line 600 "VectorModule.cs"
                                csharp2cuda_temp_211 = end;
                            }
                            else
                            {
#line 600 "VectorModule.cs"
                                csharp2cuda_temp_211 = __dadd_rn(start, __dmul_rn(step, ((double)(index))));
                            }
                            (*(csharp2cuda_temp_209) = csharp2cuda_temp_211);
#line 601 "VectorModule.cs"
#line 601 "VectorModule.cs"
                            double csharp2cuda_temp_212 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_212))))
                            {
#line 601 "VectorModule.cs"
                                atomicExch(&((output)->valid), 0);
                            }
                        }
#line 598 "VectorModule.cs"
                        int* csharp2cuda_temp_206 = &(index);
#line 598 "VectorModule.cs"
                        int csharp2cuda_temp_207 = *(csharp2cuda_temp_206);
                        (*(csharp2cuda_temp_206) = csharp2cuda_i32_add(csharp2cuda_temp_207, blockDim.x));
                    }
                }
            }
#line 604 "VectorModule.cs"
            break;
#line 605 "VectorModule.cs"
        case 22:
        case 25:
#line 607 "VectorModule.cs"
            if (((thread) == (0)))
#line 608 "VectorModule.cs"
            {
#line 609 "VectorModule.cs"
#line 609 "VectorModule.cs"
                int csharp2cuda_temp_213 = (first)->count;
                if (((csharp2cuda_temp_213) <= (0)))
#line 610 "VectorModule.cs"
                {
#line 611 "VectorModule.cs"
#line 611 "VectorModule.cs"
                    int* csharp2cuda_temp_214 = &((output)->valid);
                    (*(csharp2cuda_temp_214) = 0);
#line 612 "VectorModule.cs"
                    break;
                }
#line 614 "VectorModule.cs"
                double selected = (a)[0];
#line 615 "VectorModule.cs"
                {
#line 615 "VectorModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 615 "VectorModule.cs"
                        int csharp2cuda_temp_216 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_216))))
                            break;
#line 616 "VectorModule.cs"
#line 616 "VectorModule.cs"
                        double* csharp2cuda_temp_217 = &(selected);
#line 616 "VectorModule.cs"
                        double csharp2cuda_temp_218;
#line 616 "VectorModule.cs"
                        if (((opcode) == (22)))
                        {
#line 617 "VectorModule.cs"
                            double csharp2cuda_temp_219 = (a)[index];
#line 616 "VectorModule.cs"
                            csharp2cuda_temp_218 = mathblocks_maximum(selected, csharp2cuda_temp_219);
                        }
                        else
                        {
#line 618 "VectorModule.cs"
                            double csharp2cuda_temp_220 = (a)[index];
#line 616 "VectorModule.cs"
                            csharp2cuda_temp_218 = mathblocks_minimum(selected, csharp2cuda_temp_220);
                        }
                        (*(csharp2cuda_temp_217) = csharp2cuda_temp_218);
#line 615 "VectorModule.cs"
                        int* csharp2cuda_temp_215 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_215));
                    }
                }
#line 619 "VectorModule.cs"
#line 619 "VectorModule.cs"
                double* csharp2cuda_temp_221 = &((output)->scalar_value);
                (*(csharp2cuda_temp_221) = selected);
            }
#line 621 "VectorModule.cs"
            break;
#line 622 "VectorModule.cs"
        case 23:
        case 48:
#line 624 "VectorModule.cs"
            if (((thread) == (0)))
#line 625 "VectorModule.cs"
            {
#line 626 "VectorModule.cs"
                int csharp2cuda_temp_222 = (first)->count;
#line 626 "VectorModule.cs"
                double sum = mathblocks_compensated_sum(a, csharp2cuda_temp_222);
#line 627 "VectorModule.cs"
#line 627 "VectorModule.cs"
                double* csharp2cuda_temp_223 = &((output)->scalar_value);
#line 627 "VectorModule.cs"
                double csharp2cuda_temp_224;
#line 627 "VectorModule.cs"
                if (((opcode) == (23)))
                {
#line 627 "VectorModule.cs"
                    int csharp2cuda_temp_225 = (first)->count;
#line 627 "VectorModule.cs"
                    csharp2cuda_temp_224 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_225)));
                }
                else
                {
#line 627 "VectorModule.cs"
                    csharp2cuda_temp_224 = sum;
                }
                (*(csharp2cuda_temp_223) = csharp2cuda_temp_224);
#line 628 "VectorModule.cs"
#line 628 "VectorModule.cs"
                double csharp2cuda_temp_226 = (output)->scalar_value;
                if ((!(isfinite(csharp2cuda_temp_226))))
                {
#line 628 "VectorModule.cs"
#line 628 "VectorModule.cs"
                    int* csharp2cuda_temp_227 = &((output)->valid);
                    (*(csharp2cuda_temp_227) = 0);
                }
            }
#line 630 "VectorModule.cs"
            break;
#line 631 "VectorModule.cs"
        case 24:
        case 35:
#line 633 "VectorModule.cs"
            if (((thread) == (0)))
#line 634 "VectorModule.cs"
            {
#line 635 "VectorModule.cs"
                double csharp2cuda_temp_228;
#line 635 "VectorModule.cs"
                if (((opcode) == (24)))
                {
#line 635 "VectorModule.cs"
                    csharp2cuda_temp_228 = 0.5;
                }
                else
                {
#line 635 "VectorModule.cs"
                    csharp2cuda_temp_228 = (second)->scalar_value;
                }
#line 635 "VectorModule.cs"
                double probability = csharp2cuda_temp_228;
#line 636 "VectorModule.cs"
#line 636 "VectorModule.cs"
                int csharp2cuda_temp_229 = (first)->count;
#line 636 "VectorModule.cs"
                bool csharp2cuda_temp_230;
#line 636 "VectorModule.cs"
                if (!(((csharp2cuda_temp_229) <= (0))))
                {
#line 636 "VectorModule.cs"
                    unsigned long long csharp2cuda_temp_231 = (output)->scratch_pointer;
#line 636 "VectorModule.cs"
                    csharp2cuda_temp_230 = ((csharp2cuda_temp_231) == (((unsigned long long)(0))));
                }
                else
                {
#line 636 "VectorModule.cs"
                    csharp2cuda_temp_230 = true;
                }
#line 636 "VectorModule.cs"
                bool csharp2cuda_temp_232;
#line 636 "VectorModule.cs"
                if (!(csharp2cuda_temp_230))
                {
#line 636 "VectorModule.cs"
                    csharp2cuda_temp_232 = ((probability) < (0.0));
                }
                else
                {
#line 636 "VectorModule.cs"
                    csharp2cuda_temp_232 = true;
                }
#line 636 "VectorModule.cs"
                bool csharp2cuda_temp_233;
#line 636 "VectorModule.cs"
                if (!(csharp2cuda_temp_232))
                {
#line 636 "VectorModule.cs"
                    csharp2cuda_temp_233 = ((probability) > (1.0));
                }
                else
                {
#line 636 "VectorModule.cs"
                    csharp2cuda_temp_233 = true;
                }
                if (csharp2cuda_temp_233)
                {
#line 638 "VectorModule.cs"
#line 638 "VectorModule.cs"
                    int* csharp2cuda_temp_234 = &((output)->valid);
                    (*(csharp2cuda_temp_234) = 0);
                }
                else
#line 640 "VectorModule.cs"
                {
#line 641 "VectorModule.cs"
#line 641 "VectorModule.cs"
                    double* csharp2cuda_temp_235 = &((output)->scalar_value);
#line 641 "VectorModule.cs"
                    double csharp2cuda_temp_236 = mathblocks_quantile(first, output, probability);
                    (*(csharp2cuda_temp_235) = csharp2cuda_temp_236);
#line 642 "VectorModule.cs"
#line 642 "VectorModule.cs"
                    double csharp2cuda_temp_237 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_237))))
                    {
#line 642 "VectorModule.cs"
#line 642 "VectorModule.cs"
                        int* csharp2cuda_temp_238 = &((output)->valid);
                        (*(csharp2cuda_temp_238) = 0);
                    }
                }
            }
#line 645 "VectorModule.cs"
            break;
#line 646 "VectorModule.cs"
        case 28:
        case 29:
#line 648 "VectorModule.cs"
            if (((thread) == (0)))
#line 649 "VectorModule.cs"
            {
#line 650 "VectorModule.cs"
#line 650 "VectorModule.cs"
                int csharp2cuda_temp_239 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_239);
#line 651 "VectorModule.cs"
#line 651 "VectorModule.cs"
                double* csharp2cuda_temp_240 = &((output)->scalar_value);
#line 651 "VectorModule.cs"
                double csharp2cuda_temp_241;
#line 651 "VectorModule.cs"
                if (((opcode) == (28)))
                {
#line 652 "VectorModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
#line 651 "VectorModule.cs"
                    csharp2cuda_temp_241 = mathblocks_compensated_absolute_sum(a, csharp2cuda_temp_242);
                }
                else
                {
#line 653 "VectorModule.cs"
                    int csharp2cuda_temp_243 = (first)->count;
#line 653 "VectorModule.cs"
                    double csharp2cuda_temp_244 = mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_243);
#line 651 "VectorModule.cs"
                    csharp2cuda_temp_241 = mathblocks_square_root(csharp2cuda_temp_244);
                }
                (*(csharp2cuda_temp_240) = csharp2cuda_temp_241);
#line 654 "VectorModule.cs"
#line 654 "VectorModule.cs"
                double csharp2cuda_temp_245 = (output)->scalar_value;
#line 654 "VectorModule.cs"
                bool csharp2cuda_temp_246;
#line 654 "VectorModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_245)))))
                {
#line 654 "VectorModule.cs"
                    double csharp2cuda_temp_247 = (output)->scalar_value;
#line 654 "VectorModule.cs"
                    csharp2cuda_temp_246 = ((csharp2cuda_temp_247) == (0.0));
                }
                else
                {
#line 654 "VectorModule.cs"
                    csharp2cuda_temp_246 = true;
                }
                if (csharp2cuda_temp_246)
                {
#line 654 "VectorModule.cs"
#line 654 "VectorModule.cs"
                    int* csharp2cuda_temp_248 = &((output)->valid);
                    (*(csharp2cuda_temp_248) = 0);
                }
            }
#line 656 "VectorModule.cs"
            __syncthreads();
#line 657 "VectorModule.cs"
            {
#line 657 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 657 "VectorModule.cs"
                    bool csharp2cuda_temp_251 = (output)->valid;
#line 657 "VectorModule.cs"
                    bool csharp2cuda_temp_252;
#line 657 "VectorModule.cs"
                    if (csharp2cuda_temp_251)
                    {
#line 657 "VectorModule.cs"
                        int csharp2cuda_temp_253 = (first)->count;
#line 657 "VectorModule.cs"
                        csharp2cuda_temp_252 = ((index) < (csharp2cuda_temp_253));
                    }
                    else
                    {
#line 657 "VectorModule.cs"
                        csharp2cuda_temp_252 = false;
                    }
                    if (!(csharp2cuda_temp_252))
                        break;
#line 658 "VectorModule.cs"
                    {
#line 659 "VectorModule.cs"
#line 659 "VectorModule.cs"
                        double* csharp2cuda_temp_254 = &((result)[index]);
#line 659 "VectorModule.cs"
                        double csharp2cuda_temp_255 = (a)[index];
#line 659 "VectorModule.cs"
                        double csharp2cuda_temp_256 = (output)->scalar_value;
#line 659 "VectorModule.cs"
                        double csharp2cuda_temp_257 = __ddiv_rn(1.0, csharp2cuda_temp_256);
                        (*(csharp2cuda_temp_254) = __dmul_rn(csharp2cuda_temp_255, csharp2cuda_temp_257));
#line 660 "VectorModule.cs"
#line 660 "VectorModule.cs"
                        double csharp2cuda_temp_258 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_258))))
                        {
#line 660 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 657 "VectorModule.cs"
                    int* csharp2cuda_temp_249 = &(index);
#line 657 "VectorModule.cs"
                    int csharp2cuda_temp_250 = *(csharp2cuda_temp_249);
                    (*(csharp2cuda_temp_249) = csharp2cuda_i32_add(csharp2cuda_temp_250, blockDim.x));
                }
            }
#line 662 "VectorModule.cs"
            break;
#line 663 "VectorModule.cs"
        case 30:
#line 664 "VectorModule.cs"
            if (((thread) == (0)))
#line 665 "VectorModule.cs"
            {
#line 666 "VectorModule.cs"
                mathblocks_set_vector_shape(output, 2);
#line 667 "VectorModule.cs"
                if ((output)->valid)
#line 668 "VectorModule.cs"
                {
#line 669 "VectorModule.cs"
#line 669 "VectorModule.cs"
                    double* csharp2cuda_temp_259 = &((result)[0]);
#line 669 "VectorModule.cs"
                    double csharp2cuda_temp_260 = (first)->scalar_value;
                    (*(csharp2cuda_temp_259) = csharp2cuda_temp_260);
#line 670 "VectorModule.cs"
#line 670 "VectorModule.cs"
                    double* csharp2cuda_temp_261 = &((result)[1]);
#line 670 "VectorModule.cs"
                    double csharp2cuda_temp_262 = (second)->scalar_value;
                    (*(csharp2cuda_temp_261) = csharp2cuda_temp_262);
                }
            }
#line 673 "VectorModule.cs"
            break;
#line 674 "VectorModule.cs"
        case 31:
        case 41:
        case 45:
#line 677 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 677 "VectorModule.cs"
#line 677 "VectorModule.cs"
                int csharp2cuda_temp_263 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_263);
            }
#line 678 "VectorModule.cs"
            __syncthreads();
#line 679 "VectorModule.cs"
            {
#line 679 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 679 "VectorModule.cs"
                    bool csharp2cuda_temp_266 = (output)->valid;
#line 679 "VectorModule.cs"
                    bool csharp2cuda_temp_267;
#line 679 "VectorModule.cs"
                    if (csharp2cuda_temp_266)
                    {
#line 679 "VectorModule.cs"
                        int csharp2cuda_temp_268 = (first)->count;
#line 679 "VectorModule.cs"
                        csharp2cuda_temp_267 = ((index) < (csharp2cuda_temp_268));
                    }
                    else
                    {
#line 679 "VectorModule.cs"
                        csharp2cuda_temp_267 = false;
                    }
                    if (!(csharp2cuda_temp_267))
                        break;
#line 680 "VectorModule.cs"
                    {
#line 681 "VectorModule.cs"
                        double csharp2cuda_temp_269;
#line 681 "VectorModule.cs"
                        if (((opcode) == (31)))
                        {
#line 681 "VectorModule.cs"
                            double csharp2cuda_temp_270 = (a)[index];
#line 681 "VectorModule.cs"
                            csharp2cuda_temp_269 = mathblocks_maximum(csharp2cuda_temp_270, 0.0);
                        }
                        else
                        {
#line 682 "VectorModule.cs"
                            double csharp2cuda_temp_271;
#line 682 "VectorModule.cs"
                            if (((opcode) == (41)))
                            {
#line 682 "VectorModule.cs"
                                double csharp2cuda_temp_272 = (a)[index];
#line 682 "VectorModule.cs"
                                double csharp2cuda_temp_273 = (a)[index];
#line 682 "VectorModule.cs"
                                csharp2cuda_temp_271 = ((double)(csharp2cuda_i32_sub(((((csharp2cuda_temp_272) > (0.0))) ? 1 : 0), ((((csharp2cuda_temp_273) < (0.0))) ? 1 : 0))));
                            }
                            else
                            {
#line 683 "VectorModule.cs"
                                double csharp2cuda_temp_274 = (a)[index];
#line 683 "VectorModule.cs"
                                double csharp2cuda_temp_275 = (a)[index];
#line 682 "VectorModule.cs"
                                csharp2cuda_temp_271 = __dmul_rn(csharp2cuda_temp_274, csharp2cuda_temp_275);
                            }
#line 681 "VectorModule.cs"
                            csharp2cuda_temp_269 = csharp2cuda_temp_271;
                        }
#line 681 "VectorModule.cs"
                        double value = csharp2cuda_temp_269;
#line 684 "VectorModule.cs"
#line 684 "VectorModule.cs"
                        double* csharp2cuda_temp_276 = &((result)[index]);
                        (*(csharp2cuda_temp_276) = value);
#line 685 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 685 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 679 "VectorModule.cs"
                    int* csharp2cuda_temp_264 = &(index);
#line 679 "VectorModule.cs"
                    int csharp2cuda_temp_265 = *(csharp2cuda_temp_264);
                    (*(csharp2cuda_temp_264) = csharp2cuda_i32_add(csharp2cuda_temp_265, blockDim.x));
                }
            }
#line 687 "VectorModule.cs"
            break;
#line 688 "VectorModule.cs"
        case 32:
#line 689 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 689 "VectorModule.cs"
#line 689 "VectorModule.cs"
                int csharp2cuda_temp_277 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_277);
            }
#line 690 "VectorModule.cs"
            __syncthreads();
#line 691 "VectorModule.cs"
            {
#line 691 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 691 "VectorModule.cs"
                    bool csharp2cuda_temp_280 = (output)->valid;
#line 691 "VectorModule.cs"
                    bool csharp2cuda_temp_281;
#line 691 "VectorModule.cs"
                    if (csharp2cuda_temp_280)
                    {
#line 691 "VectorModule.cs"
                        int csharp2cuda_temp_282 = (first)->count;
#line 691 "VectorModule.cs"
                        csharp2cuda_temp_281 = ((index) < (csharp2cuda_temp_282));
                    }
                    else
                    {
#line 691 "VectorModule.cs"
                        csharp2cuda_temp_281 = false;
                    }
                    if (!(csharp2cuda_temp_281))
                        break;
#line 692 "VectorModule.cs"
                    {
#line 693 "VectorModule.cs"
#line 693 "VectorModule.cs"
                        double* csharp2cuda_temp_283 = &((result)[index]);
#line 693 "VectorModule.cs"
                        double csharp2cuda_temp_284 = (a)[index];
#line 693 "VectorModule.cs"
                        double csharp2cuda_temp_285 = (second)->scalar_value;
                        (*(csharp2cuda_temp_283) = mathblocks_power(csharp2cuda_temp_284, csharp2cuda_temp_285));
#line 694 "VectorModule.cs"
#line 694 "VectorModule.cs"
                        double csharp2cuda_temp_286 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_286))))
                        {
#line 694 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 691 "VectorModule.cs"
                    int* csharp2cuda_temp_278 = &(index);
#line 691 "VectorModule.cs"
                    int csharp2cuda_temp_279 = *(csharp2cuda_temp_278);
                    (*(csharp2cuda_temp_278) = csharp2cuda_i32_add(csharp2cuda_temp_279, blockDim.x));
                }
            }
#line 696 "VectorModule.cs"
            break;
#line 697 "VectorModule.cs"
        case 33:
#line 698 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 698 "VectorModule.cs"
#line 698 "VectorModule.cs"
                int csharp2cuda_temp_287 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_287, 1));
            }
#line 699 "VectorModule.cs"
            __syncthreads();
#line 700 "VectorModule.cs"
#line 700 "VectorModule.cs"
            bool csharp2cuda_temp_288;
#line 700 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 700 "VectorModule.cs"
                csharp2cuda_temp_288 = (output)->valid;
            }
            else
            {
#line 700 "VectorModule.cs"
                csharp2cuda_temp_288 = false;
            }
            if (csharp2cuda_temp_288)
            {
#line 700 "VectorModule.cs"
#line 700 "VectorModule.cs"
                double* csharp2cuda_temp_289 = &((result)[0]);
#line 700 "VectorModule.cs"
                double csharp2cuda_temp_290 = (second)->scalar_value;
                (*(csharp2cuda_temp_289) = csharp2cuda_temp_290);
            }
#line 701 "VectorModule.cs"
            {
#line 701 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 701 "VectorModule.cs"
                    bool csharp2cuda_temp_293 = (output)->valid;
#line 701 "VectorModule.cs"
                    bool csharp2cuda_temp_294;
#line 701 "VectorModule.cs"
                    if (csharp2cuda_temp_293)
                    {
#line 701 "VectorModule.cs"
                        int csharp2cuda_temp_295 = (first)->count;
#line 701 "VectorModule.cs"
                        csharp2cuda_temp_294 = ((index) < (csharp2cuda_temp_295));
                    }
                    else
                    {
#line 701 "VectorModule.cs"
                        csharp2cuda_temp_294 = false;
                    }
                    if (!(csharp2cuda_temp_294))
                        break;
#line 702 "VectorModule.cs"
#line 702 "VectorModule.cs"
                    double* csharp2cuda_temp_296 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 702 "VectorModule.cs"
                    double csharp2cuda_temp_297 = (a)[index];
                    (*(csharp2cuda_temp_296) = csharp2cuda_temp_297);
#line 701 "VectorModule.cs"
                    int* csharp2cuda_temp_291 = &(index);
#line 701 "VectorModule.cs"
                    int csharp2cuda_temp_292 = *(csharp2cuda_temp_291);
                    (*(csharp2cuda_temp_291) = csharp2cuda_i32_add(csharp2cuda_temp_292, blockDim.x));
                }
            }
#line 703 "VectorModule.cs"
            break;
#line 704 "VectorModule.cs"
        case 34:
#line 705 "VectorModule.cs"
            if (((thread) == (0)))
#line 706 "VectorModule.cs"
            {
#line 707 "VectorModule.cs"
                double product = 1.0;
#line 708 "VectorModule.cs"
                {
#line 708 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 708 "VectorModule.cs"
                        int csharp2cuda_temp_299 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_299))))
                            break;
#line 708 "VectorModule.cs"
#line 708 "VectorModule.cs"
                        double* csharp2cuda_temp_300 = &(product);
#line 708 "VectorModule.cs"
                        double csharp2cuda_temp_301 = *(csharp2cuda_temp_300);
#line 708 "VectorModule.cs"
                        double csharp2cuda_temp_302 = (a)[index];
                        (*(csharp2cuda_temp_300) = __dmul_rn(csharp2cuda_temp_301, csharp2cuda_temp_302));
#line 708 "VectorModule.cs"
                        int* csharp2cuda_temp_298 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_298));
                    }
                }
#line 709 "VectorModule.cs"
#line 709 "VectorModule.cs"
                double* csharp2cuda_temp_303 = &((output)->scalar_value);
                (*(csharp2cuda_temp_303) = product);
#line 710 "VectorModule.cs"
                if ((!(isfinite(product))))
                {
#line 710 "VectorModule.cs"
#line 710 "VectorModule.cs"
                    int* csharp2cuda_temp_304 = &((output)->valid);
                    (*(csharp2cuda_temp_304) = 0);
                }
            }
#line 712 "VectorModule.cs"
            break;
#line 713 "VectorModule.cs"
        case 36:
#line 714 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 714 "VectorModule.cs"
#line 714 "VectorModule.cs"
                int csharp2cuda_temp_305 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_305);
            }
#line 715 "VectorModule.cs"
            __syncthreads();
#line 716 "VectorModule.cs"
            {
#line 716 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 716 "VectorModule.cs"
                    bool csharp2cuda_temp_308 = (output)->valid;
#line 716 "VectorModule.cs"
                    bool csharp2cuda_temp_309;
#line 716 "VectorModule.cs"
                    if (csharp2cuda_temp_308)
                    {
#line 716 "VectorModule.cs"
                        int csharp2cuda_temp_310 = (first)->count;
#line 716 "VectorModule.cs"
                        csharp2cuda_temp_309 = ((index) < (csharp2cuda_temp_310));
                    }
                    else
                    {
#line 716 "VectorModule.cs"
                        csharp2cuda_temp_309 = false;
                    }
                    if (!(csharp2cuda_temp_309))
                        break;
#line 717 "VectorModule.cs"
#line 717 "VectorModule.cs"
                    double* csharp2cuda_temp_311 = &((result)[index]);
#line 717 "VectorModule.cs"
                    int csharp2cuda_temp_312 = (first)->count;
#line 717 "VectorModule.cs"
                    double csharp2cuda_temp_313 = mathblocks_vector_rank_at(a, csharp2cuda_temp_312, index);
                    (*(csharp2cuda_temp_311) = csharp2cuda_temp_313);
#line 716 "VectorModule.cs"
                    int* csharp2cuda_temp_306 = &(index);
#line 716 "VectorModule.cs"
                    int csharp2cuda_temp_307 = *(csharp2cuda_temp_306);
                    (*(csharp2cuda_temp_306) = csharp2cuda_i32_add(csharp2cuda_temp_307, blockDim.x));
                }
            }
#line 718 "VectorModule.cs"
            break;
#line 719 "VectorModule.cs"
        case 37:
#line 720 "VectorModule.cs"
            if (((thread) == (0)))
#line 721 "VectorModule.cs"
            {
#line 722 "VectorModule.cs"
                int count = 0;
#line 723 "VectorModule.cs"
#line 723 "VectorModule.cs"
                double csharp2cuda_temp_314 = (second)->scalar_value;
#line 723 "VectorModule.cs"
                int* csharp2cuda_temp_315 = &(count);
#line 723 "VectorModule.cs"
                bool csharp2cuda_temp_316 = mathblocks_nonnegative_integer(csharp2cuda_temp_314, csharp2cuda_temp_315);
#line 723 "VectorModule.cs"
                bool csharp2cuda_temp_317;
#line 723 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_316))))
                {
#line 723 "VectorModule.cs"
                    csharp2cuda_temp_317 = ((count) > (1000000));
                }
                else
                {
#line 723 "VectorModule.cs"
                    csharp2cuda_temp_317 = true;
                }
                if (csharp2cuda_temp_317)
                {
#line 724 "VectorModule.cs"
#line 724 "VectorModule.cs"
                    int* csharp2cuda_temp_318 = &((output)->valid);
                    (*(csharp2cuda_temp_318) = 0);
                }
                else
                {
#line 726 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, count);
                }
            }
#line 728 "VectorModule.cs"
            __syncthreads();
#line 729 "VectorModule.cs"
            {
#line 729 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 729 "VectorModule.cs"
                    bool csharp2cuda_temp_321 = (output)->valid;
#line 729 "VectorModule.cs"
                    bool csharp2cuda_temp_322;
#line 729 "VectorModule.cs"
                    if (csharp2cuda_temp_321)
                    {
#line 729 "VectorModule.cs"
                        int csharp2cuda_temp_323 = (output)->count;
#line 729 "VectorModule.cs"
                        csharp2cuda_temp_322 = ((index) < (csharp2cuda_temp_323));
                    }
                    else
                    {
#line 729 "VectorModule.cs"
                        csharp2cuda_temp_322 = false;
                    }
                    if (!(csharp2cuda_temp_322))
                        break;
#line 730 "VectorModule.cs"
#line 730 "VectorModule.cs"
                    double* csharp2cuda_temp_324 = &((result)[index]);
#line 730 "VectorModule.cs"
                    double csharp2cuda_temp_325 = (first)->scalar_value;
                    (*(csharp2cuda_temp_324) = csharp2cuda_temp_325);
#line 729 "VectorModule.cs"
                    int* csharp2cuda_temp_319 = &(index);
#line 729 "VectorModule.cs"
                    int csharp2cuda_temp_320 = *(csharp2cuda_temp_319);
                    (*(csharp2cuda_temp_319) = csharp2cuda_i32_add(csharp2cuda_temp_320, blockDim.x));
                }
            }
#line 731 "VectorModule.cs"
            break;
#line 732 "VectorModule.cs"
        case 38:
#line 733 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 733 "VectorModule.cs"
#line 733 "VectorModule.cs"
                int csharp2cuda_temp_326 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_326);
            }
#line 734 "VectorModule.cs"
            __syncthreads();
#line 735 "VectorModule.cs"
            {
#line 735 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 735 "VectorModule.cs"
                    bool csharp2cuda_temp_329 = (output)->valid;
#line 735 "VectorModule.cs"
                    bool csharp2cuda_temp_330;
#line 735 "VectorModule.cs"
                    if (csharp2cuda_temp_329)
                    {
#line 735 "VectorModule.cs"
                        int csharp2cuda_temp_331 = (first)->count;
#line 735 "VectorModule.cs"
                        csharp2cuda_temp_330 = ((index) < (csharp2cuda_temp_331));
                    }
                    else
                    {
#line 735 "VectorModule.cs"
                        csharp2cuda_temp_330 = false;
                    }
                    if (!(csharp2cuda_temp_330))
                        break;
#line 736 "VectorModule.cs"
#line 736 "VectorModule.cs"
                    double* csharp2cuda_temp_332 = &((result)[index]);
#line 736 "VectorModule.cs"
                    int csharp2cuda_temp_333 = (first)->count;
#line 736 "VectorModule.cs"
                    double csharp2cuda_temp_334 = (a)[csharp2cuda_i32_sub(csharp2cuda_i32_sub(csharp2cuda_temp_333, index), 1)];
                    (*(csharp2cuda_temp_332) = csharp2cuda_temp_334);
#line 735 "VectorModule.cs"
                    int* csharp2cuda_temp_327 = &(index);
#line 735 "VectorModule.cs"
                    int csharp2cuda_temp_328 = *(csharp2cuda_temp_327);
                    (*(csharp2cuda_temp_327) = csharp2cuda_i32_add(csharp2cuda_temp_328, blockDim.x));
                }
            }
#line 737 "VectorModule.cs"
            break;
#line 738 "VectorModule.cs"
        case 39:
#line 739 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 739 "VectorModule.cs"
#line 739 "VectorModule.cs"
                int csharp2cuda_temp_335 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_335);
            }
#line 740 "VectorModule.cs"
            __syncthreads();
#line 741 "VectorModule.cs"
            {
#line 741 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 741 "VectorModule.cs"
                    bool csharp2cuda_temp_338 = (output)->valid;
#line 741 "VectorModule.cs"
                    bool csharp2cuda_temp_339;
#line 741 "VectorModule.cs"
                    if (csharp2cuda_temp_338)
                    {
#line 741 "VectorModule.cs"
                        int csharp2cuda_temp_340 = (first)->count;
#line 741 "VectorModule.cs"
                        csharp2cuda_temp_339 = ((index) < (csharp2cuda_temp_340));
                    }
                    else
                    {
#line 741 "VectorModule.cs"
                        csharp2cuda_temp_339 = false;
                    }
                    if (!(csharp2cuda_temp_339))
                        break;
#line 742 "VectorModule.cs"
                    {
#line 743 "VectorModule.cs"
#line 743 "VectorModule.cs"
                        double* csharp2cuda_temp_341 = &((result)[index]);
#line 743 "VectorModule.cs"
                        double csharp2cuda_temp_342 = (a)[index];
#line 743 "VectorModule.cs"
                        double csharp2cuda_temp_343 = (second)->scalar_value;
                        (*(csharp2cuda_temp_341) = __dmul_rn(csharp2cuda_temp_342, csharp2cuda_temp_343));
#line 744 "VectorModule.cs"
#line 744 "VectorModule.cs"
                        double csharp2cuda_temp_344 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_344))))
                        {
#line 744 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 741 "VectorModule.cs"
                    int* csharp2cuda_temp_336 = &(index);
#line 741 "VectorModule.cs"
                    int csharp2cuda_temp_337 = *(csharp2cuda_temp_336);
                    (*(csharp2cuda_temp_336) = csharp2cuda_i32_add(csharp2cuda_temp_337, blockDim.x));
                }
            }
#line 746 "VectorModule.cs"
            break;
#line 747 "VectorModule.cs"
        case 40:
#line 748 "VectorModule.cs"
            if (((thread) == (0)))
#line 749 "VectorModule.cs"
            {
#line 750 "VectorModule.cs"
#line 750 "VectorModule.cs"
                int csharp2cuda_temp_345 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_345);
#line 751 "VectorModule.cs"
#line 751 "VectorModule.cs"
                int csharp2cuda_temp_346 = (first)->count;
#line 751 "VectorModule.cs"
                int csharp2cuda_temp_347 = (second)->count;
#line 751 "VectorModule.cs"
                bool csharp2cuda_temp_348;
#line 751 "VectorModule.cs"
                if (!(((csharp2cuda_temp_346) != (csharp2cuda_temp_347))))
                {
#line 751 "VectorModule.cs"
                    int csharp2cuda_temp_349 = (first)->count;
#line 751 "VectorModule.cs"
                    int csharp2cuda_temp_350 = (third)->count;
#line 751 "VectorModule.cs"
                    csharp2cuda_temp_348 = ((csharp2cuda_temp_349) != (csharp2cuda_temp_350));
                }
                else
                {
#line 751 "VectorModule.cs"
                    csharp2cuda_temp_348 = true;
                }
                if (csharp2cuda_temp_348)
                {
#line 751 "VectorModule.cs"
#line 751 "VectorModule.cs"
                    int* csharp2cuda_temp_351 = &((output)->valid);
                    (*(csharp2cuda_temp_351) = 0);
                }
            }
#line 753 "VectorModule.cs"
            __syncthreads();
#line 754 "VectorModule.cs"
            {
#line 754 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 754 "VectorModule.cs"
                    bool csharp2cuda_temp_354 = (output)->valid;
#line 754 "VectorModule.cs"
                    bool csharp2cuda_temp_355;
#line 754 "VectorModule.cs"
                    if (csharp2cuda_temp_354)
                    {
#line 754 "VectorModule.cs"
                        int csharp2cuda_temp_356 = (first)->count;
#line 754 "VectorModule.cs"
                        csharp2cuda_temp_355 = ((index) < (csharp2cuda_temp_356));
                    }
                    else
                    {
#line 754 "VectorModule.cs"
                        csharp2cuda_temp_355 = false;
                    }
                    if (!(csharp2cuda_temp_355))
                        break;
#line 755 "VectorModule.cs"
#line 755 "VectorModule.cs"
                    double* csharp2cuda_temp_357 = &((result)[index]);
#line 755 "VectorModule.cs"
                    bool csharp2cuda_temp_358 = (boolean_a)[index];
#line 755 "VectorModule.cs"
                    double csharp2cuda_temp_359;
#line 755 "VectorModule.cs"
                    if (csharp2cuda_temp_358)
                    {
#line 755 "VectorModule.cs"
                        csharp2cuda_temp_359 = (b)[index];
                    }
                    else
                    {
#line 755 "VectorModule.cs"
                        csharp2cuda_temp_359 = (c)[index];
                    }
                    (*(csharp2cuda_temp_357) = csharp2cuda_temp_359);
#line 754 "VectorModule.cs"
                    int* csharp2cuda_temp_352 = &(index);
#line 754 "VectorModule.cs"
                    int csharp2cuda_temp_353 = *(csharp2cuda_temp_352);
                    (*(csharp2cuda_temp_352) = csharp2cuda_i32_add(csharp2cuda_temp_353, blockDim.x));
                }
            }
#line 756 "VectorModule.cs"
            break;
#line 757 "VectorModule.cs"
        case 42:
#line 758 "VectorModule.cs"
            if (((thread) == (0)))
#line 759 "VectorModule.cs"
            {
#line 760 "VectorModule.cs"
                int start = 0;
#line 761 "VectorModule.cs"
                int length = 0;
#line 762 "VectorModule.cs"
#line 762 "VectorModule.cs"
                double csharp2cuda_temp_360 = (second)->scalar_value;
#line 762 "VectorModule.cs"
                int* csharp2cuda_temp_361 = &(start);
#line 762 "VectorModule.cs"
                bool csharp2cuda_temp_362 = mathblocks_nonnegative_integer(csharp2cuda_temp_360, csharp2cuda_temp_361);
#line 762 "VectorModule.cs"
                bool csharp2cuda_temp_363;
#line 762 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_362))))
                {
#line 763 "VectorModule.cs"
                    double csharp2cuda_temp_364 = (third)->scalar_value;
#line 763 "VectorModule.cs"
                    int* csharp2cuda_temp_365 = &(length);
#line 763 "VectorModule.cs"
                    bool csharp2cuda_temp_366 = mathblocks_nonnegative_integer(csharp2cuda_temp_364, csharp2cuda_temp_365);
#line 762 "VectorModule.cs"
                    csharp2cuda_temp_363 = (!(csharp2cuda_temp_366));
                }
                else
                {
#line 762 "VectorModule.cs"
                    csharp2cuda_temp_363 = true;
                }
#line 762 "VectorModule.cs"
                bool csharp2cuda_temp_367;
#line 762 "VectorModule.cs"
                if (!(csharp2cuda_temp_363))
                {
#line 764 "VectorModule.cs"
                    int csharp2cuda_temp_368 = (first)->count;
#line 762 "VectorModule.cs"
                    csharp2cuda_temp_367 = ((start) > (csharp2cuda_temp_368));
                }
                else
                {
#line 762 "VectorModule.cs"
                    csharp2cuda_temp_367 = true;
                }
#line 762 "VectorModule.cs"
                bool csharp2cuda_temp_369;
#line 762 "VectorModule.cs"
                if (!(csharp2cuda_temp_367))
                {
#line 764 "VectorModule.cs"
                    int csharp2cuda_temp_370 = (first)->count;
#line 762 "VectorModule.cs"
                    csharp2cuda_temp_369 = ((length) > (csharp2cuda_i32_sub(csharp2cuda_temp_370, start)));
                }
                else
                {
#line 762 "VectorModule.cs"
                    csharp2cuda_temp_369 = true;
                }
                if (csharp2cuda_temp_369)
                {
#line 765 "VectorModule.cs"
#line 765 "VectorModule.cs"
                    int* csharp2cuda_temp_371 = &((output)->valid);
                    (*(csharp2cuda_temp_371) = 0);
                }
                else
                {
#line 767 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, length);
                }
            }
#line 769 "VectorModule.cs"
            __syncthreads();
#line 770 "VectorModule.cs"
            if ((output)->valid)
#line 771 "VectorModule.cs"
            {
#line 772 "VectorModule.cs"
                double csharp2cuda_temp_372 = (second)->scalar_value;
#line 772 "VectorModule.cs"
                int start = csharp2cuda_f64_to_i32(csharp2cuda_temp_372);
#line 773 "VectorModule.cs"
                {
#line 773 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 773 "VectorModule.cs"
                        int csharp2cuda_temp_375 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_375))))
                            break;
#line 774 "VectorModule.cs"
#line 774 "VectorModule.cs"
                        double* csharp2cuda_temp_376 = &((result)[index]);
#line 774 "VectorModule.cs"
                        double csharp2cuda_temp_377 = (a)[csharp2cuda_i32_add(start, index)];
                        (*(csharp2cuda_temp_376) = csharp2cuda_temp_377);
#line 773 "VectorModule.cs"
                        int* csharp2cuda_temp_373 = &(index);
#line 773 "VectorModule.cs"
                        int csharp2cuda_temp_374 = *(csharp2cuda_temp_373);
                        (*(csharp2cuda_temp_373) = csharp2cuda_i32_add(csharp2cuda_temp_374, blockDim.x));
                    }
                }
            }
#line 776 "VectorModule.cs"
            break;
#line 777 "VectorModule.cs"
        case 43:
#line 778 "VectorModule.cs"
            if (((thread) == (0)))
#line 779 "VectorModule.cs"
            {
#line 780 "VectorModule.cs"
#line 780 "VectorModule.cs"
                int csharp2cuda_temp_378 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_378);
#line 781 "VectorModule.cs"
                if ((output)->valid)
                {
#line 781 "VectorModule.cs"
                    mathblocks_copy_and_sort(first, output);
                }
            }
#line 783 "VectorModule.cs"
            break;
#line 784 "VectorModule.cs"
        case 46:
#line 785 "VectorModule.cs"
            if (((thread) == (0)))
#line 786 "VectorModule.cs"
            {
#line 787 "VectorModule.cs"
#line 787 "VectorModule.cs"
                int csharp2cuda_temp_379 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_379);
#line 788 "VectorModule.cs"
#line 788 "VectorModule.cs"
                bool csharp2cuda_temp_380 = (output)->valid;
#line 788 "VectorModule.cs"
                bool csharp2cuda_temp_381;
#line 788 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_380))))
                {
#line 788 "VectorModule.cs"
                    int csharp2cuda_temp_382 = (first)->count;
#line 788 "VectorModule.cs"
                    csharp2cuda_temp_381 = ((csharp2cuda_temp_382) <= (0));
                }
                else
                {
#line 788 "VectorModule.cs"
                    csharp2cuda_temp_381 = true;
                }
                if (csharp2cuda_temp_381)
#line 789 "VectorModule.cs"
                {
#line 790 "VectorModule.cs"
#line 790 "VectorModule.cs"
                    int* csharp2cuda_temp_383 = &((output)->valid);
                    (*(csharp2cuda_temp_383) = 0);
#line 791 "VectorModule.cs"
                    break;
                }
#line 793 "VectorModule.cs"
                double mean = 0.0;
#line 794 "VectorModule.cs"
                double deviation = 0.0;
#line 795 "VectorModule.cs"
#line 795 "VectorModule.cs"
                int csharp2cuda_temp_384 = (first)->count;
#line 795 "VectorModule.cs"
                double* csharp2cuda_temp_385 = &(mean);
#line 795 "VectorModule.cs"
                double* csharp2cuda_temp_386 = &(deviation);
                mathblocks_vector_standardize_moments(a, csharp2cuda_temp_384, csharp2cuda_temp_385, csharp2cuda_temp_386);
#line 796 "VectorModule.cs"
                {
#line 796 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 796 "VectorModule.cs"
                        int csharp2cuda_temp_388 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_388))))
                            break;
#line 797 "VectorModule.cs"
                        {
#line 798 "VectorModule.cs"
#line 798 "VectorModule.cs"
                            double* csharp2cuda_temp_389 = &((result)[index]);
#line 798 "VectorModule.cs"
                            double csharp2cuda_temp_390 = (a)[index];
#line 798 "VectorModule.cs"
                            double csharp2cuda_temp_391 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_390, mean), deviation);
                            (*(csharp2cuda_temp_389) = csharp2cuda_temp_391);
#line 799 "VectorModule.cs"
#line 799 "VectorModule.cs"
                            double csharp2cuda_temp_392 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_392))))
                            {
#line 799 "VectorModule.cs"
#line 799 "VectorModule.cs"
                                int* csharp2cuda_temp_393 = &((output)->valid);
                                (*(csharp2cuda_temp_393) = 0);
                            }
                        }
#line 796 "VectorModule.cs"
                        int* csharp2cuda_temp_387 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_387));
                    }
                }
            }
#line 802 "VectorModule.cs"
            break;
#line 803 "VectorModule.cs"
        case 49:
#line 804 "VectorModule.cs"
            if (((thread) == (0)))
#line 805 "VectorModule.cs"
            {
#line 806 "VectorModule.cs"
                int count = 0;
#line 807 "VectorModule.cs"
                {
#line 807 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 807 "VectorModule.cs"
                        int csharp2cuda_temp_395 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_395))))
                            break;
#line 808 "VectorModule.cs"
                        {
#line 809 "VectorModule.cs"
                            bool found = false;
#line 810 "VectorModule.cs"
                            {
#line 810 "VectorModule.cs"
                                int prior = 0;
                                while (true)
                                {
                                    if (!(((prior) < (count))))
                                        break;
#line 811 "VectorModule.cs"
#line 811 "VectorModule.cs"
                                    double csharp2cuda_temp_397 = (result)[prior];
#line 811 "VectorModule.cs"
                                    double csharp2cuda_temp_398 = (a)[index];
                                    if (((csharp2cuda_temp_397) == (csharp2cuda_temp_398)))
#line 811 "VectorModule.cs"
                                    {
#line 811 "VectorModule.cs"
#line 811 "VectorModule.cs"
                                        bool* csharp2cuda_temp_399 = &(found);
                                        (*(csharp2cuda_temp_399) = true);
#line 811 "VectorModule.cs"
                                        break;
                                    }
#line 810 "VectorModule.cs"
                                    int* csharp2cuda_temp_396 = &(prior);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_396));
                                }
                            }
#line 812 "VectorModule.cs"
                            if ((!(found)))
                            {
#line 812 "VectorModule.cs"
#line 812 "VectorModule.cs"
                                int* csharp2cuda_temp_400 = &(count);
#line 812 "VectorModule.cs"
                                int csharp2cuda_temp_401 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_400));
#line 812 "VectorModule.cs"
                                double* csharp2cuda_temp_402 = &((result)[csharp2cuda_temp_401]);
#line 812 "VectorModule.cs"
                                double csharp2cuda_temp_403 = (a)[index];
                                (*(csharp2cuda_temp_402) = csharp2cuda_temp_403);
                            }
                        }
#line 807 "VectorModule.cs"
                        int* csharp2cuda_temp_394 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_394));
                    }
                }
#line 814 "VectorModule.cs"
                mathblocks_set_vector_shape(output, count);
            }
#line 816 "VectorModule.cs"
            break;
#line 817 "VectorModule.cs"
        case 50:
        case 52:
        case 55:
#line 820 "VectorModule.cs"
            {
#line 821 "VectorModule.cs"
                if (((thread) == (0)))
#line 822 "VectorModule.cs"
                {
#line 823 "VectorModule.cs"
#line 823 "VectorModule.cs"
                    int* csharp2cuda_temp_404 = &((output)->boolean_value);
#line 823 "VectorModule.cs"
                    int csharp2cuda_temp_405;
#line 823 "VectorModule.cs"
                    if (((opcode) == (50)))
                    {
#line 823 "VectorModule.cs"
                        csharp2cuda_temp_405 = 1;
                    }
                    else
                    {
#line 823 "VectorModule.cs"
                        csharp2cuda_temp_405 = 0;
                    }
                    (*(csharp2cuda_temp_404) = csharp2cuda_temp_405);
#line 824 "VectorModule.cs"
#line 824 "VectorModule.cs"
                    double* csharp2cuda_temp_406 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_406) = 0.0);
                }
#line 826 "VectorModule.cs"
                __syncthreads();
#line 827 "VectorModule.cs"
                int local_count = 0;
#line 828 "VectorModule.cs"
                bool local_all = true;
#line 829 "VectorModule.cs"
                bool local_any = false;
#line 830 "VectorModule.cs"
                {
#line 830 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 830 "VectorModule.cs"
                        int csharp2cuda_temp_409 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_409))))
                            break;
#line 831 "VectorModule.cs"
                        {
#line 832 "VectorModule.cs"
                            int csharp2cuda_temp_410 = (boolean_a)[index];
#line 832 "VectorModule.cs"
                            bool value = ((csharp2cuda_temp_410) != (0));
#line 833 "VectorModule.cs"
                            if (value)
                            {
#line 833 "VectorModule.cs"
#line 833 "VectorModule.cs"
                                int* csharp2cuda_temp_411 = &(local_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_411));
                            }
#line 834 "VectorModule.cs"
#line 834 "VectorModule.cs"
                            bool* csharp2cuda_temp_412 = &(local_all);
#line 834 "VectorModule.cs"
                            bool csharp2cuda_temp_413;
#line 834 "VectorModule.cs"
                            if (local_all)
                            {
#line 834 "VectorModule.cs"
                                csharp2cuda_temp_413 = value;
                            }
                            else
                            {
#line 834 "VectorModule.cs"
                                csharp2cuda_temp_413 = false;
                            }
                            (*(csharp2cuda_temp_412) = csharp2cuda_temp_413);
#line 835 "VectorModule.cs"
#line 835 "VectorModule.cs"
                            bool* csharp2cuda_temp_414 = &(local_any);
#line 835 "VectorModule.cs"
                            bool csharp2cuda_temp_415;
#line 835 "VectorModule.cs"
                            if (!(local_any))
                            {
#line 835 "VectorModule.cs"
                                csharp2cuda_temp_415 = value;
                            }
                            else
                            {
#line 835 "VectorModule.cs"
                                csharp2cuda_temp_415 = true;
                            }
                            (*(csharp2cuda_temp_414) = csharp2cuda_temp_415);
                        }
#line 830 "VectorModule.cs"
                        int* csharp2cuda_temp_407 = &(index);
#line 830 "VectorModule.cs"
                        int csharp2cuda_temp_408 = *(csharp2cuda_temp_407);
                        (*(csharp2cuda_temp_407) = csharp2cuda_i32_add(csharp2cuda_temp_408, blockDim.x));
                    }
                }
#line 837 "VectorModule.cs"
#line 837 "VectorModule.cs"
                bool csharp2cuda_temp_416;
#line 837 "VectorModule.cs"
                if (((opcode) == (55)))
                {
#line 837 "VectorModule.cs"
                    csharp2cuda_temp_416 = ((local_count) != (0));
                }
                else
                {
#line 837 "VectorModule.cs"
                    csharp2cuda_temp_416 = false;
                }
                if (csharp2cuda_temp_416)
                {
#line 838 "VectorModule.cs"
                    atomicAdd(&((output)->boolean_value), local_count);
                }
                else
                {
#line 839 "VectorModule.cs"
#line 839 "VectorModule.cs"
                    bool csharp2cuda_temp_417;
#line 839 "VectorModule.cs"
                    if (((opcode) == (50)))
                    {
#line 839 "VectorModule.cs"
                        csharp2cuda_temp_417 = (!(local_all));
                    }
                    else
                    {
#line 839 "VectorModule.cs"
                        csharp2cuda_temp_417 = false;
                    }
                    if (csharp2cuda_temp_417)
                    {
#line 840 "VectorModule.cs"
                        atomicExch(&((output)->boolean_value), 0);
                    }
                    else
                    {
#line 841 "VectorModule.cs"
#line 841 "VectorModule.cs"
                        bool csharp2cuda_temp_418;
#line 841 "VectorModule.cs"
                        if (((opcode) == (52)))
                        {
#line 841 "VectorModule.cs"
                            csharp2cuda_temp_418 = local_any;
                        }
                        else
                        {
#line 841 "VectorModule.cs"
                            csharp2cuda_temp_418 = false;
                        }
                        if (csharp2cuda_temp_418)
                        {
#line 842 "VectorModule.cs"
                            atomicExch(&((output)->boolean_value), 1);
                        }
                    }
                }
#line 843 "VectorModule.cs"
                __syncthreads();
#line 844 "VectorModule.cs"
#line 844 "VectorModule.cs"
                bool csharp2cuda_temp_419;
#line 844 "VectorModule.cs"
                if (((thread) == (0)))
                {
#line 844 "VectorModule.cs"
                    csharp2cuda_temp_419 = ((opcode) == (55));
                }
                else
                {
#line 844 "VectorModule.cs"
                    csharp2cuda_temp_419 = false;
                }
                if (csharp2cuda_temp_419)
#line 845 "VectorModule.cs"
                {
#line 846 "VectorModule.cs"
#line 846 "VectorModule.cs"
                    double* csharp2cuda_temp_420 = &((output)->scalar_value);
#line 846 "VectorModule.cs"
                    int csharp2cuda_temp_421 = (output)->boolean_value;
                    (*(csharp2cuda_temp_420) = ((double)(csharp2cuda_temp_421)));
#line 847 "VectorModule.cs"
#line 847 "VectorModule.cs"
                    int* csharp2cuda_temp_422 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_422) = 0);
                }
#line 849 "VectorModule.cs"
                break;
            }
#line 851 "VectorModule.cs"
        case 51:
        case 54:
        case 57:
#line 854 "VectorModule.cs"
            if (((thread) == (0)))
#line 855 "VectorModule.cs"
            {
#line 856 "VectorModule.cs"
#line 856 "VectorModule.cs"
                int csharp2cuda_temp_423 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_423);
#line 857 "VectorModule.cs"
#line 857 "VectorModule.cs"
                int csharp2cuda_temp_424 = (first)->count;
#line 857 "VectorModule.cs"
                int csharp2cuda_temp_425 = (second)->count;
                if (((csharp2cuda_temp_424) != (csharp2cuda_temp_425)))
                {
#line 857 "VectorModule.cs"
#line 857 "VectorModule.cs"
                    int* csharp2cuda_temp_426 = &((output)->valid);
                    (*(csharp2cuda_temp_426) = 0);
                }
            }
#line 859 "VectorModule.cs"
            __syncthreads();
#line 860 "VectorModule.cs"
            {
#line 860 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 860 "VectorModule.cs"
                    bool csharp2cuda_temp_429 = (output)->valid;
#line 860 "VectorModule.cs"
                    bool csharp2cuda_temp_430;
#line 860 "VectorModule.cs"
                    if (csharp2cuda_temp_429)
                    {
#line 860 "VectorModule.cs"
                        int csharp2cuda_temp_431 = (first)->count;
#line 860 "VectorModule.cs"
                        csharp2cuda_temp_430 = ((index) < (csharp2cuda_temp_431));
                    }
                    else
                    {
#line 860 "VectorModule.cs"
                        csharp2cuda_temp_430 = false;
                    }
                    if (!(csharp2cuda_temp_430))
                        break;
#line 861 "VectorModule.cs"
#line 861 "VectorModule.cs"
                    int* csharp2cuda_temp_432 = &((boolean_result)[index]);
#line 861 "VectorModule.cs"
                    bool csharp2cuda_temp_433;
#line 861 "VectorModule.cs"
                    if (((opcode) == (51)))
                    {
#line 861 "VectorModule.cs"
                        bool csharp2cuda_temp_434 = (boolean_a)[index];
#line 861 "VectorModule.cs"
                        bool csharp2cuda_temp_435;
#line 861 "VectorModule.cs"
                        if (csharp2cuda_temp_434)
                        {
#line 861 "VectorModule.cs"
                            csharp2cuda_temp_435 = (boolean_b)[index];
                        }
                        else
                        {
#line 861 "VectorModule.cs"
                            csharp2cuda_temp_435 = false;
                        }
#line 861 "VectorModule.cs"
                        csharp2cuda_temp_433 = csharp2cuda_temp_435;
                    }
                    else
                    {
#line 862 "VectorModule.cs"
                        bool csharp2cuda_temp_436;
#line 862 "VectorModule.cs"
                        if (((opcode) == (54)))
                        {
#line 862 "VectorModule.cs"
                            bool csharp2cuda_temp_437 = (boolean_a)[index];
#line 862 "VectorModule.cs"
                            bool csharp2cuda_temp_438;
#line 862 "VectorModule.cs"
                            if (!(csharp2cuda_temp_437))
                            {
#line 862 "VectorModule.cs"
                                csharp2cuda_temp_438 = (boolean_b)[index];
                            }
                            else
                            {
#line 862 "VectorModule.cs"
                                csharp2cuda_temp_438 = true;
                            }
#line 862 "VectorModule.cs"
                            csharp2cuda_temp_436 = csharp2cuda_temp_438;
                        }
                        else
                        {
#line 863 "VectorModule.cs"
                            int csharp2cuda_temp_439 = (boolean_a)[index];
#line 863 "VectorModule.cs"
                            int csharp2cuda_temp_440 = (boolean_b)[index];
#line 862 "VectorModule.cs"
                            csharp2cuda_temp_436 = ((csharp2cuda_temp_439) != (csharp2cuda_temp_440));
                        }
#line 861 "VectorModule.cs"
                        csharp2cuda_temp_433 = csharp2cuda_temp_436;
                    }
                    (*(csharp2cuda_temp_432) = csharp2cuda_temp_433);
#line 860 "VectorModule.cs"
                    int* csharp2cuda_temp_427 = &(index);
#line 860 "VectorModule.cs"
                    int csharp2cuda_temp_428 = *(csharp2cuda_temp_427);
                    (*(csharp2cuda_temp_427) = csharp2cuda_i32_add(csharp2cuda_temp_428, blockDim.x));
                }
            }
#line 864 "VectorModule.cs"
            break;
#line 865 "VectorModule.cs"
        case 53:
#line 866 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 866 "VectorModule.cs"
#line 866 "VectorModule.cs"
                int csharp2cuda_temp_441 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_441);
            }
#line 867 "VectorModule.cs"
            __syncthreads();
#line 868 "VectorModule.cs"
            {
#line 868 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 868 "VectorModule.cs"
                    bool csharp2cuda_temp_444 = (output)->valid;
#line 868 "VectorModule.cs"
                    bool csharp2cuda_temp_445;
#line 868 "VectorModule.cs"
                    if (csharp2cuda_temp_444)
                    {
#line 868 "VectorModule.cs"
                        int csharp2cuda_temp_446 = (first)->count;
#line 868 "VectorModule.cs"
                        csharp2cuda_temp_445 = ((index) < (csharp2cuda_temp_446));
                    }
                    else
                    {
#line 868 "VectorModule.cs"
                        csharp2cuda_temp_445 = false;
                    }
                    if (!(csharp2cuda_temp_445))
                        break;
#line 869 "VectorModule.cs"
#line 869 "VectorModule.cs"
                    int* csharp2cuda_temp_447 = &((boolean_result)[index]);
#line 869 "VectorModule.cs"
                    bool csharp2cuda_temp_448 = (boolean_a)[index];
                    (*(csharp2cuda_temp_447) = (!(csharp2cuda_temp_448)));
#line 868 "VectorModule.cs"
                    int* csharp2cuda_temp_442 = &(index);
#line 868 "VectorModule.cs"
                    int csharp2cuda_temp_443 = *(csharp2cuda_temp_442);
                    (*(csharp2cuda_temp_442) = csharp2cuda_i32_add(csharp2cuda_temp_443, blockDim.x));
                }
            }
#line 870 "VectorModule.cs"
            break;
#line 871 "VectorModule.cs"
        case 56:
#line 872 "VectorModule.cs"
            if (((thread) == (0)))
#line 873 "VectorModule.cs"
            {
#line 874 "VectorModule.cs"
                int count = 0;
#line 875 "VectorModule.cs"
                {
#line 875 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 875 "VectorModule.cs"
                        int csharp2cuda_temp_450 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_450))))
                            break;
#line 876 "VectorModule.cs"
                        if ((boolean_a)[index])
                        {
#line 876 "VectorModule.cs"
#line 876 "VectorModule.cs"
                            int* csharp2cuda_temp_451 = &(count);
#line 876 "VectorModule.cs"
                            int csharp2cuda_temp_452 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_451));
#line 876 "VectorModule.cs"
                            double* csharp2cuda_temp_453 = &((result)[csharp2cuda_temp_452]);
                            (*(csharp2cuda_temp_453) = ((double)(index)));
                        }
#line 875 "VectorModule.cs"
                        int* csharp2cuda_temp_449 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_449));
                    }
                }
#line 877 "VectorModule.cs"
                mathblocks_set_vector_shape(output, count);
            }
#line 879 "VectorModule.cs"
            break;
#line 880 "VectorModule.cs"
        default:
#line 881 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 881 "VectorModule.cs"
#line 881 "VectorModule.cs"
                int* csharp2cuda_temp_454 = &((output)->valid);
                (*(csharp2cuda_temp_454) = 0);
            }
#line 882 "VectorModule.cs"
            break;
    }
}

#line 303 "VectorModule.cs"
__device__ bool mathblocks_vector_geometric_mean_value(
    const double* values,
    int count,
    double* logarithms,
    double* value)
#line 309 "VectorModule.cs"
{
#line 310 "VectorModule.cs"
    if (((count) <= (0)))
    {
#line 311 "VectorModule.cs"
        return false;
    }
#line 312 "VectorModule.cs"
    bool finite = true;
#line 313 "VectorModule.cs"
    {
#line 313 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 314 "VectorModule.cs"
            {
#line 315 "VectorModule.cs"
#line 315 "VectorModule.cs"
                double* csharp2cuda_temp_1 = &((logarithms)[index]);
#line 315 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
                (*(csharp2cuda_temp_1) = mathblocks_natural_logarithm(csharp2cuda_temp_2));
#line 316 "VectorModule.cs"
#line 316 "VectorModule.cs"
                double csharp2cuda_temp_3 = (logarithms)[index];
                if ((!(isfinite(csharp2cuda_temp_3))))
                {
#line 317 "VectorModule.cs"
#line 317 "VectorModule.cs"
                    bool* csharp2cuda_temp_4 = &(finite);
                    (*(csharp2cuda_temp_4) = false);
                }
            }
#line 313 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 319 "VectorModule.cs"
    if ((!(finite)))
    {
#line 320 "VectorModule.cs"
        return false;
    }
#line 321 "VectorModule.cs"
#line 321 "VectorModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 321 "VectorModule.cs"
    double csharp2cuda_temp_6 = mathblocks_compensated_sum(logarithms, count);
#line 321 "VectorModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(csharp2cuda_temp_6, ((double)(count)));
    (*(csharp2cuda_temp_5) = mathblocks_exponential(csharp2cuda_temp_7));
#line 322 "VectorModule.cs"
#line 322 "VectorModule.cs"
    double csharp2cuda_temp_8 = *(value);
    return isfinite(csharp2cuda_temp_8);
}

#line 343 "VectorModule.cs"
__device__ double mathblocks_vector_rank_at(
    const double* values,
    int count,
    int position)
#line 348 "VectorModule.cs"
{
#line 349 "VectorModule.cs"
    int less = 0;
#line 350 "VectorModule.cs"
    int equal = 0;
#line 351 "VectorModule.cs"
    {
#line 351 "VectorModule.cs"
        int other = 0;
        while (true)
        {
            if (!(((other) < (count))))
                break;
#line 352 "VectorModule.cs"
            {
#line 353 "VectorModule.cs"
#line 353 "VectorModule.cs"
                double csharp2cuda_temp_1 = (values)[other];
#line 353 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[position];
                if (((csharp2cuda_temp_1) < (csharp2cuda_temp_2)))
                {
#line 353 "VectorModule.cs"
#line 353 "VectorModule.cs"
                    int* csharp2cuda_temp_3 = &(less);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
                else
                {
#line 354 "VectorModule.cs"
#line 354 "VectorModule.cs"
                    double csharp2cuda_temp_4 = (values)[other];
#line 354 "VectorModule.cs"
                    double csharp2cuda_temp_5 = (values)[position];
                    if (((csharp2cuda_temp_4) == (csharp2cuda_temp_5)))
                    {
#line 354 "VectorModule.cs"
#line 354 "VectorModule.cs"
                        int* csharp2cuda_temp_6 = &(equal);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
                    }
                }
            }
#line 351 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(other);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 356 "VectorModule.cs"
#line 356 "VectorModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
    return __dadd_rn(((double)(less)), csharp2cuda_temp_7);
}

#line 359 "VectorModule.cs"
__device__ void mathblocks_vector_standardize_moments(
    const double* values,
    int count,
    double* mean,
    double* deviation)
#line 365 "VectorModule.cs"
{
#line 366 "VectorModule.cs"
    double csharp2cuda_temp_0 = mathblocks_compensated_sum(values, count);
#line 366 "VectorModule.cs"
    double average = __ddiv_rn(csharp2cuda_temp_0, ((double)(count)));
#line 367 "VectorModule.cs"
    double variance = 0.0;
#line 368 "VectorModule.cs"
    {
#line 368 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 369 "VectorModule.cs"
            {
#line 370 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
#line 370 "VectorModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_2, average);
#line 371 "VectorModule.cs"
#line 371 "VectorModule.cs"
                double* csharp2cuda_temp_3 = &(variance);
#line 371 "VectorModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(difference, difference)));
            }
#line 368 "VectorModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 373 "VectorModule.cs"
#line 373 "VectorModule.cs"
    double* csharp2cuda_temp_5 = &(variance);
#line 373 "VectorModule.cs"
    double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
    (*(csharp2cuda_temp_5) = __ddiv_rn(csharp2cuda_temp_6, ((double)(count))));
#line 374 "VectorModule.cs"
#line 374 "VectorModule.cs"
    double* csharp2cuda_temp_7 = mean;
    (*(csharp2cuda_temp_7) = average);
#line 376 "VectorModule.cs"
#line 376 "VectorModule.cs"
    double* csharp2cuda_temp_8 = deviation;
#line 376 "VectorModule.cs"
    double csharp2cuda_temp_9;
#line 376 "VectorModule.cs"
    if (isfinite(variance))
    {
#line 376 "VectorModule.cs"
        csharp2cuda_temp_9 = mathblocks_square_root(variance);
    }
    else
    {
#line 376 "VectorModule.cs"
        csharp2cuda_temp_9 = mathblocks_quiet_nan();
    }
    (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
}