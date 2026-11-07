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

#line 1081 "WindowModule.cs"
__device__ void mathblocks_window_accurate_rows(
    int source,
    const double* x,
    int width,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    long long* scratch);

#line 1384 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 265 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value);

#line 240 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means);

#line 1037 "WindowModule.cs"
__device__ void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql);

#line 784 "WindowModule.cs"
__device__ void mathblocks_window_exact_add(long long* accumulator, double value, int shift, bool subtract);

#line 827 "WindowModule.cs"
__device__ void mathblocks_window_exact_add_square(long long* accumulator, double value, bool subtract);

#line 721 "WindowModule.cs"
__device__ int mathblocks_window_exact_add_to(long long* target, double value, int shift, bool subtract);

#line 888 "WindowModule.cs"
__device__ bool mathblocks_window_exact_any_below(const long long* value, int lowest, int position);

#line 874 "WindowModule.cs"
__device__ long long mathblocks_window_exact_bits(const long long* value, int position, int count);

#line 763 "WindowModule.cs"
__device__ long long mathblocks_window_exact_carry(long long* target, int first, int last);

#line 710 "WindowModule.cs"
__device__ void mathblocks_window_exact_clear(long long* accumulator);

#line 854 "WindowModule.cs"
__device__ int mathblocks_window_exact_load(long long* accumulator, bool* negative);

#line 777 "WindowModule.cs"
__device__ void mathblocks_window_exact_negate(long long* target, int first, int last);

#line 940 "WindowModule.cs"
__device__ void mathblocks_window_exact_read_pair(long long* accumulator, double* high, double* low, bool* zero);

#line 981 "WindowModule.cs"
__device__ double mathblocks_window_exact_read_quotient(long long* accumulator, int divisor);

#line 904 "WindowModule.cs"
__device__ double mathblocks_window_exact_round(const long long* value, int lowest, int top, bool sticky);

#line 1018 "WindowModule.cs"
__device__ void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e);

#line 304 "WindowModule.cs"
__device__ void mathblocks_window_heap_sift(double* values, int root, int end);

#line 324 "WindowModule.cs"
__device__ void mathblocks_window_heap_sort(double* values, int count);

#line 1071 "WindowModule.cs"
__device__ bool mathblocks_window_in_range(double value, double largest);

#line 704 "WindowModule.cs"
__device__ double mathblocks_window_power_of_two(int exponent);

#line 1251 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread);

#line 372 "WindowModule.cs"
__device__ void mathblocks_window_ranks(
    const double* a,
    const double* b,
    int count,
    double* scratch);

#line 1267 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity);

#line 206 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width);

#line 421 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count);

#line 181 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source);

#line 340 "WindowModule.cs"
__device__ double mathblocks_window_sorted_rank(const double* sorted, int count, double value);

#line 1190 "WindowModule.cs"
__device__ void mathblocks_window_sorted_rows(
    const double* x,
    int width,
    double probability,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    double* sorted);

#line 148 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source);

#line 803 "WindowModule.cs"
__device__ void mathblocks_window_split(double a, double* high, double* low);

#line 1026 "WindowModule.cs"
__device__ void mathblocks_window_square(double h, double l, double* sh, double* sl);

#line 430 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value);

#line 1050 "WindowModule.cs"
__device__ double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl);

#line 812 "WindowModule.cs"
__device__ void mathblocks_window_two_product(double a, double b, double* p, double* e);

#line 1009 "WindowModule.cs"
__device__ void mathblocks_window_two_sum(double a, double b, double* s, double* e);

#line 452 "WindowModule.cs"
__device__ bool mathblocks_window_value(
    int source,
    const double* a,
    const double* b,
    const int* flags,
    int count,
    const MathBlockSlot* first_parameter,
    const MathBlockSlot* second_parameter,
    double* scratch,
    double* value);

#line 1081 "WindowModule.cs"
__device__ void mathblocks_window_accurate_rows(
    int source,
    const double* x,
    int width,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    long long* scratch)
#line 1093 "WindowModule.cs"
{
#line 1094 "WindowModule.cs"
    bool variance = ((source) >= (55));
#line 1095 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 1095 "WindowModule.cs"
    if (!(((source) == (56))))
    {
#line 1095 "WindowModule.cs"
        csharp2cuda_temp_0 = ((source) == (58));
    }
    else
    {
#line 1095 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 1095 "WindowModule.cs"
    bool sample = csharp2cuda_temp_0;
#line 1096 "WindowModule.cs"
    bool deviation = ((source) >= (57));
#line 1097 "WindowModule.cs"
    long long* first = scratch;
#line 1098 "WindowModule.cs"
    long long* second = csharp2cuda_pointer_add(scratch, 285);
#line 1099 "WindowModule.cs"
    mathblocks_window_exact_clear(first);
#line 1100 "WindowModule.cs"
    if (variance)
    {
#line 1101 "WindowModule.cs"
        mathblocks_window_exact_clear(second);
    }
#line 1102 "WindowModule.cs"
    double csharp2cuda_temp_1;
#line 1102 "WindowModule.cs"
    if (sample)
    {
#line 1102 "WindowModule.cs"
        csharp2cuda_temp_1 = __dsub_rn(((double)(width)), 1.0);
    }
    else
    {
#line 1102 "WindowModule.cs"
        csharp2cuda_temp_1 = ((double)(width));
    }
#line 1102 "WindowModule.cs"
    double divisor = csharp2cuda_temp_1;
#line 1103 "WindowModule.cs"
    int csharp2cuda_temp_2;
#line 1103 "WindowModule.cs"
    if (((csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1)) < (0)))
    {
#line 1103 "WindowModule.cs"
        csharp2cuda_temp_2 = 0;
    }
    else
    {
#line 1103 "WindowModule.cs"
        csharp2cuda_temp_2 = csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1);
    }
#line 1103 "WindowModule.cs"
    int begin = csharp2cuda_temp_2;
#line 1104 "WindowModule.cs"
    int changes = 0;
#line 1105 "WindowModule.cs"
    {
#line 1105 "WindowModule.cs"
        int row = begin;
        while (true)
        {
            if (!(((row) < (last_row))))
                break;
#line 1106 "WindowModule.cs"
            {
#line 1107 "WindowModule.cs"
#line 1107 "WindowModule.cs"
                double csharp2cuda_temp_4 = (x)[row];
                mathblocks_window_exact_add(first, csharp2cuda_temp_4, 0, false);
#line 1108 "WindowModule.cs"
                if (variance)
#line 1109 "WindowModule.cs"
                {
#line 1110 "WindowModule.cs"
#line 1110 "WindowModule.cs"
                    double csharp2cuda_temp_5 = (x)[row];
                    mathblocks_window_exact_add_square(second, csharp2cuda_temp_5, false);
#line 1111 "WindowModule.cs"
#line 1111 "WindowModule.cs"
                    bool csharp2cuda_temp_6;
#line 1111 "WindowModule.cs"
                    if (((row) > (begin)))
                    {
#line 1111 "WindowModule.cs"
                        double csharp2cuda_temp_7 = (x)[row];
#line 1111 "WindowModule.cs"
                        double csharp2cuda_temp_8 = (x)[csharp2cuda_i32_sub(row, 1)];
#line 1111 "WindowModule.cs"
                        csharp2cuda_temp_6 = ((csharp2cuda_temp_7) != (csharp2cuda_temp_8));
                    }
                    else
                    {
#line 1111 "WindowModule.cs"
                        csharp2cuda_temp_6 = false;
                    }
                    if (csharp2cuda_temp_6)
                    {
#line 1112 "WindowModule.cs"
#line 1112 "WindowModule.cs"
                        int* csharp2cuda_temp_9 = &(changes);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                    }
                }
#line 1114 "WindowModule.cs"
                if (((csharp2cuda_i32_sub(row, width)) >= (begin)))
#line 1115 "WindowModule.cs"
                {
#line 1116 "WindowModule.cs"
#line 1116 "WindowModule.cs"
                    double csharp2cuda_temp_10 = (x)[csharp2cuda_i32_sub(row, width)];
                    mathblocks_window_exact_add(first, csharp2cuda_temp_10, 0, true);
#line 1117 "WindowModule.cs"
                    if (variance)
#line 1118 "WindowModule.cs"
                    {
#line 1119 "WindowModule.cs"
#line 1119 "WindowModule.cs"
                        double csharp2cuda_temp_11 = (x)[csharp2cuda_i32_sub(row, width)];
                        mathblocks_window_exact_add_square(second, csharp2cuda_temp_11, true);
#line 1120 "WindowModule.cs"
#line 1120 "WindowModule.cs"
                        double csharp2cuda_temp_12 = (x)[csharp2cuda_i32_add(csharp2cuda_i32_sub(row, width), 1)];
#line 1120 "WindowModule.cs"
                        double csharp2cuda_temp_13 = (x)[csharp2cuda_i32_sub(row, width)];
                        if (((csharp2cuda_temp_12) != (csharp2cuda_temp_13)))
                        {
#line 1121 "WindowModule.cs"
#line 1121 "WindowModule.cs"
                            int* csharp2cuda_temp_14 = &(changes);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_14));
                        }
                    }
                }
#line 1124 "WindowModule.cs"
                if (((row) < (first_row)))
                {
#line 1125 "WindowModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 1126 "WindowModule.cs"
                bool computed = false;
#line 1127 "WindowModule.cs"
                double value = 0.0;
#line 1128 "WindowModule.cs"
                if (((row) >= (csharp2cuda_i32_sub(width, 1))))
#line 1129 "WindowModule.cs"
                {
#line 1130 "WindowModule.cs"
                    if ((!(variance)))
#line 1131 "WindowModule.cs"
                    {
#line 1132 "WindowModule.cs"
                        double low = 0.0;
#line 1133 "WindowModule.cs"
                        bool zero = true;
#line 1134 "WindowModule.cs"
                        if (((source) == (54)))
                        {
#line 1135 "WindowModule.cs"
#line 1135 "WindowModule.cs"
                            double* csharp2cuda_temp_15 = &(value);
#line 1135 "WindowModule.cs"
                            double csharp2cuda_temp_16 = mathblocks_window_exact_read_quotient(first, width);
                            (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
                        }
                        else
                        {
#line 1137 "WindowModule.cs"
#line 1137 "WindowModule.cs"
                            double* csharp2cuda_temp_17 = &(value);
#line 1137 "WindowModule.cs"
                            double* csharp2cuda_temp_18 = &(low);
#line 1137 "WindowModule.cs"
                            bool* csharp2cuda_temp_19 = &(zero);
                            mathblocks_window_exact_read_pair(first, csharp2cuda_temp_17, csharp2cuda_temp_18, csharp2cuda_temp_19);
                        }
#line 1138 "WindowModule.cs"
#line 1138 "WindowModule.cs"
                        bool* csharp2cuda_temp_20 = &(computed);
                        (*(csharp2cuda_temp_20) = isfinite(value));
                    }
                    else
#line 1141 "WindowModule.cs"
                    {
#line 1142 "WindowModule.cs"
                        double moment = 0.0;
#line 1143 "WindowModule.cs"
                        bool in_range = true;
#line 1144 "WindowModule.cs"
                        if (((changes) != (0)))
#line 1145 "WindowModule.cs"
                        {
#line 1146 "WindowModule.cs"
                            double s1h = 0.0;
#line 1147 "WindowModule.cs"
                            double s1l = 0.0;
#line 1148 "WindowModule.cs"
                            double s2h = 0.0;
#line 1149 "WindowModule.cs"
                            double s2l = 0.0;
#line 1150 "WindowModule.cs"
                            double qh = 0.0;
#line 1151 "WindowModule.cs"
                            double ql = 0.0;
#line 1152 "WindowModule.cs"
                            double rh = 0.0;
#line 1153 "WindowModule.cs"
                            double rl = 0.0;
#line 1154 "WindowModule.cs"
                            bool s1_zero = true;
#line 1155 "WindowModule.cs"
                            bool s2_zero = true;
#line 1156 "WindowModule.cs"
#line 1156 "WindowModule.cs"
                            double* csharp2cuda_temp_21 = &(s1h);
#line 1156 "WindowModule.cs"
                            double* csharp2cuda_temp_22 = &(s1l);
#line 1156 "WindowModule.cs"
                            bool* csharp2cuda_temp_23 = &(s1_zero);
                            mathblocks_window_exact_read_pair(first, csharp2cuda_temp_21, csharp2cuda_temp_22, csharp2cuda_temp_23);
#line 1157 "WindowModule.cs"
#line 1157 "WindowModule.cs"
                            double* csharp2cuda_temp_24 = &(s2h);
#line 1157 "WindowModule.cs"
                            double* csharp2cuda_temp_25 = &(s2l);
#line 1157 "WindowModule.cs"
                            bool* csharp2cuda_temp_26 = &(s2_zero);
                            mathblocks_window_exact_read_pair(second, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26);
#line 1158 "WindowModule.cs"
#line 1158 "WindowModule.cs"
                            double* csharp2cuda_temp_27 = &(qh);
#line 1158 "WindowModule.cs"
                            double* csharp2cuda_temp_28 = &(ql);
                            mathblocks_window_square(s1h, s1l, csharp2cuda_temp_27, csharp2cuda_temp_28);
#line 1159 "WindowModule.cs"
#line 1159 "WindowModule.cs"
                            double* csharp2cuda_temp_29 = &(rh);
#line 1159 "WindowModule.cs"
                            double* csharp2cuda_temp_30 = &(rl);
                            mathblocks_window_divide_by_integer(qh, ql, width, csharp2cuda_temp_29, csharp2cuda_temp_30);
#line 1160 "WindowModule.cs"
#line 1160 "WindowModule.cs"
                            double* csharp2cuda_temp_31 = &(moment);
#line 1160 "WindowModule.cs"
                            double csharp2cuda_temp_32 = mathblocks_window_subtract_rounded(s2h, s2l, rh, rl);
                            (*(csharp2cuda_temp_31) = csharp2cuda_temp_32);
#line 1161 "WindowModule.cs"
                            double largest = __longlong_as_double(9218868437227405311LL);
#line 1162 "WindowModule.cs"
#line 1162 "WindowModule.cs"
                            bool csharp2cuda_temp_33;
#line 1162 "WindowModule.cs"
                            if (!((!(mathblocks_window_in_range(s2h, largest)))))
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_33 = (!(mathblocks_window_in_range(qh, largest)));
                            }
                            else
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_33 = true;
                            }
#line 1162 "WindowModule.cs"
                            bool csharp2cuda_temp_34;
#line 1162 "WindowModule.cs"
                            if (!(csharp2cuda_temp_33))
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_34 = (!(mathblocks_window_in_range(rh, mathblocks_window_power_of_two(996))));
                            }
                            else
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_34 = true;
                            }
#line 1162 "WindowModule.cs"
                            bool csharp2cuda_temp_35;
#line 1162 "WindowModule.cs"
                            if (!(csharp2cuda_temp_34))
                            {
#line 1165 "WindowModule.cs"
                                bool csharp2cuda_temp_36;
#line 1165 "WindowModule.cs"
                                if (((s2h) == (0.0)))
                                {
#line 1165 "WindowModule.cs"
                                    csharp2cuda_temp_36 = (!(s2_zero));
                                }
                                else
                                {
#line 1165 "WindowModule.cs"
                                    csharp2cuda_temp_36 = false;
                                }
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_35 = csharp2cuda_temp_36;
                            }
                            else
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_35 = true;
                            }
#line 1162 "WindowModule.cs"
                            bool csharp2cuda_temp_37;
#line 1162 "WindowModule.cs"
                            if (!(csharp2cuda_temp_35))
                            {
#line 1165 "WindowModule.cs"
                                bool csharp2cuda_temp_38;
#line 1165 "WindowModule.cs"
                                if (((qh) == (0.0)))
                                {
#line 1165 "WindowModule.cs"
                                    csharp2cuda_temp_38 = ((s1h) != (0.0));
                                }
                                else
                                {
#line 1165 "WindowModule.cs"
                                    csharp2cuda_temp_38 = false;
                                }
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_37 = csharp2cuda_temp_38;
                            }
                            else
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_37 = true;
                            }
#line 1162 "WindowModule.cs"
                            bool csharp2cuda_temp_39;
#line 1162 "WindowModule.cs"
                            if (!(csharp2cuda_temp_37))
                            {
#line 1166 "WindowModule.cs"
                                bool csharp2cuda_temp_40;
#line 1166 "WindowModule.cs"
                                if (((moment) > (0.0)))
                                {
#line 1166 "WindowModule.cs"
                                    csharp2cuda_temp_40 = ((moment) < (mathblocks_window_power_of_two(csharp2cuda_i32_neg(968))));
                                }
                                else
                                {
#line 1166 "WindowModule.cs"
                                    csharp2cuda_temp_40 = false;
                                }
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_39 = csharp2cuda_temp_40;
                            }
                            else
                            {
#line 1162 "WindowModule.cs"
                                csharp2cuda_temp_39 = true;
                            }
                            if (csharp2cuda_temp_39)
                            {
#line 1167 "WindowModule.cs"
#line 1167 "WindowModule.cs"
                                bool* csharp2cuda_temp_41 = &(in_range);
                                (*(csharp2cuda_temp_41) = false);
                            }
                            else
                            {
#line 1168 "WindowModule.cs"
                                if (((moment) <= (0.0)))
                                {
#line 1169 "WindowModule.cs"
#line 1169 "WindowModule.cs"
                                    double* csharp2cuda_temp_42 = &(moment);
                                    (*(csharp2cuda_temp_42) = 0.0);
                                }
                            }
                        }
#line 1171 "WindowModule.cs"
#line 1171 "WindowModule.cs"
                        double* csharp2cuda_temp_43 = &(value);
#line 1171 "WindowModule.cs"
                        double csharp2cuda_temp_44 = __ddiv_rn(moment, divisor);
                        (*(csharp2cuda_temp_43) = csharp2cuda_temp_44);
#line 1172 "WindowModule.cs"
                        if (deviation)
                        {
#line 1173 "WindowModule.cs"
#line 1173 "WindowModule.cs"
                            double* csharp2cuda_temp_45 = &(value);
                            (*(csharp2cuda_temp_45) = mathblocks_square_root(value));
                        }
#line 1174 "WindowModule.cs"
#line 1174 "WindowModule.cs"
                        bool* csharp2cuda_temp_46 = &(computed);
#line 1174 "WindowModule.cs"
                        bool csharp2cuda_temp_47;
#line 1174 "WindowModule.cs"
                        if (in_range)
                        {
#line 1174 "WindowModule.cs"
                            csharp2cuda_temp_47 = isfinite(value);
                        }
                        else
                        {
#line 1174 "WindowModule.cs"
                            csharp2cuda_temp_47 = false;
                        }
                        (*(csharp2cuda_temp_46) = csharp2cuda_temp_47);
                    }
                }
#line 1177 "WindowModule.cs"
                if (sibling)
                {
#line 1178 "WindowModule.cs"
#line 1178 "WindowModule.cs"
                    int* csharp2cuda_temp_48 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_48) = computed);
                }
                else
                {
#line 1180 "WindowModule.cs"
#line 1180 "WindowModule.cs"
                    double* csharp2cuda_temp_49 = &((result)[row]);
#line 1180 "WindowModule.cs"
                    double csharp2cuda_temp_50;
#line 1180 "WindowModule.cs"
                    if (computed)
                    {
#line 1180 "WindowModule.cs"
                        csharp2cuda_temp_50 = value;
                    }
                    else
                    {
#line 1180 "WindowModule.cs"
                        csharp2cuda_temp_50 = fill;
                    }
                    (*(csharp2cuda_temp_49) = csharp2cuda_temp_50);
                }
            }
            csharp2cuda_for_continue_0:
#line 1105 "WindowModule.cs"
            int* csharp2cuda_temp_3 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
}

#line 1384 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 1390 "WindowModule.cs"
{
#line 1391 "WindowModule.cs"
    mathblocks_window_run(opcode, inputs, input_count, output, threadIdx.x, blockDim.x, csharp2cuda_i32_neg(1));
}

#line 265 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value)
#line 272 "WindowModule.cs"
{
#line 273 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 274 "WindowModule.cs"
        return false;
    }
#line 275 "WindowModule.cs"
    double* left_means = row_means;
#line 276 "WindowModule.cs"
    double* right_means = csharp2cuda_pointer_add(row_means, count);
#line 277 "WindowModule.cs"
    double left_total = mathblocks_window_distance_row_means(left_values, count, left_means);
#line 278 "WindowModule.cs"
    double right_total = mathblocks_window_distance_row_means(right_values, count, right_means);
#line 279 "WindowModule.cs"
    double covariance_square = 0.0;
#line 280 "WindowModule.cs"
    double left_variance_square = 0.0;
#line 281 "WindowModule.cs"
    double right_variance_square = 0.0;
#line 282 "WindowModule.cs"
    {
#line 282 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 283 "WindowModule.cs"
            {
#line 284 "WindowModule.cs"
                {
#line 284 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 285 "WindowModule.cs"
                        {
#line 286 "WindowModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[row];
#line 286 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[column];
#line 287 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (left_means)[row];
#line 287 "WindowModule.cs"
                            double csharp2cuda_temp_5 = (left_means)[column];
#line 286 "WindowModule.cs"
                            double left = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3)), __dsub_rn(__dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), left_total));
#line 288 "WindowModule.cs"
                            double csharp2cuda_temp_6 = (right_values)[row];
#line 288 "WindowModule.cs"
                            double csharp2cuda_temp_7 = (right_values)[column];
#line 289 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (right_means)[row];
#line 289 "WindowModule.cs"
                            double csharp2cuda_temp_9 = (right_means)[column];
#line 288 "WindowModule.cs"
                            double right = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)), __dsub_rn(__dadd_rn(csharp2cuda_temp_8, csharp2cuda_temp_9), right_total));
#line 290 "WindowModule.cs"
#line 290 "WindowModule.cs"
                            double* csharp2cuda_temp_10 = &(covariance_square);
#line 290 "WindowModule.cs"
                            double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                            (*(csharp2cuda_temp_10) = __dadd_rn(csharp2cuda_temp_11, __dmul_rn(left, right)));
#line 291 "WindowModule.cs"
#line 291 "WindowModule.cs"
                            double* csharp2cuda_temp_12 = &(left_variance_square);
#line 291 "WindowModule.cs"
                            double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                            (*(csharp2cuda_temp_12) = __dadd_rn(csharp2cuda_temp_13, __dmul_rn(left, left)));
#line 292 "WindowModule.cs"
#line 292 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = &(right_variance_square);
#line 292 "WindowModule.cs"
                            double csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
                            (*(csharp2cuda_temp_14) = __dadd_rn(csharp2cuda_temp_15, __dmul_rn(right, right)));
                        }
#line 284 "WindowModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 282 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 295 "WindowModule.cs"
#line 295 "WindowModule.cs"
    double* csharp2cuda_temp_16 = &(covariance_square);
#line 295 "WindowModule.cs"
    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
    (*(csharp2cuda_temp_16) = __ddiv_rn(csharp2cuda_temp_17, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 296 "WindowModule.cs"
#line 296 "WindowModule.cs"
    double* csharp2cuda_temp_18 = &(left_variance_square);
#line 296 "WindowModule.cs"
    double csharp2cuda_temp_19 = *(csharp2cuda_temp_18);
    (*(csharp2cuda_temp_18) = __ddiv_rn(csharp2cuda_temp_19, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 297 "WindowModule.cs"
#line 297 "WindowModule.cs"
    double* csharp2cuda_temp_20 = &(right_variance_square);
#line 297 "WindowModule.cs"
    double csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
    (*(csharp2cuda_temp_20) = __ddiv_rn(csharp2cuda_temp_21, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 298 "WindowModule.cs"
#line 298 "WindowModule.cs"
    double* csharp2cuda_temp_22 = value;
    (*(csharp2cuda_temp_22) = mathblocks_statistics_distance_correlation_value(covariance_square, left_variance_square, right_variance_square));
#line 300 "WindowModule.cs"
#line 300 "WindowModule.cs"
    double csharp2cuda_temp_23 = *(value);
    return isfinite(csharp2cuda_temp_23);
}

#line 240 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means)
#line 245 "WindowModule.cs"
{
#line 246 "WindowModule.cs"
    double total_mean = 0.0;
#line 247 "WindowModule.cs"
    {
#line 247 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 248 "WindowModule.cs"
            {
#line 249 "WindowModule.cs"
#line 249 "WindowModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 250 "WindowModule.cs"
                {
#line 250 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 251 "WindowModule.cs"
                        {
#line 252 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 252 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 252 "WindowModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 253 "WindowModule.cs"
#line 253 "WindowModule.cs"
                            double* csharp2cuda_temp_5 = &((row_means)[row]);
#line 253 "WindowModule.cs"
                            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, distance));
#line 254 "WindowModule.cs"
#line 254 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &(total_mean);
#line 254 "WindowModule.cs"
                            double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                            (*(csharp2cuda_temp_7) = __dadd_rn(csharp2cuda_temp_8, distance));
                        }
#line 250 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 256 "WindowModule.cs"
#line 256 "WindowModule.cs"
                double* csharp2cuda_temp_9 = &((row_means)[row]);
#line 256 "WindowModule.cs"
                double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
                (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
            }
#line 247 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 258 "WindowModule.cs"
#line 258 "WindowModule.cs"
    double* csharp2cuda_temp_11 = &(total_mean);
#line 258 "WindowModule.cs"
    double csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
    (*(csharp2cuda_temp_11) = __ddiv_rn(csharp2cuda_temp_12, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 259 "WindowModule.cs"
    return total_mean;
}

#line 1037 "WindowModule.cs"
__device__ void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql)
#line 1039 "WindowModule.cs"
{
#line 1040 "WindowModule.cs"
    double divisor = ((double)(width));
#line 1041 "WindowModule.cs"
    double high = __ddiv_rn(h, divisor);
#line 1042 "WindowModule.cs"
    double p = 0.0;
#line 1043 "WindowModule.cs"
    double e = 0.0;
#line 1044 "WindowModule.cs"
#line 1044 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(p);
#line 1044 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(e);
    mathblocks_window_two_product(high, divisor, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 1045 "WindowModule.cs"
    double low = __ddiv_rn(__dadd_rn(__dsub_rn(__dsub_rn(h, p), e), l), divisor);
#line 1046 "WindowModule.cs"
    mathblocks_window_fast_two_sum(high, low, qh, ql);
}

#line 784 "WindowModule.cs"
__device__ void mathblocks_window_exact_add(long long* accumulator, double value, int shift, bool subtract)
#line 786 "WindowModule.cs"
{
#line 787 "WindowModule.cs"
    if (((value) == (0.0)))
    {
#line 788 "WindowModule.cs"
        return;
    }
#line 789 "WindowModule.cs"
    int index = mathblocks_window_exact_add_to(accumulator, value, shift, subtract);
#line 790 "WindowModule.cs"
#line 790 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[282];
    if (((((long long)(index))) < (csharp2cuda_temp_0)))
    {
#line 791 "WindowModule.cs"
#line 791 "WindowModule.cs"
        long long* csharp2cuda_temp_1 = &((accumulator)[282]);
        (*(csharp2cuda_temp_1) = ((long long)(index)));
    }
#line 792 "WindowModule.cs"
#line 792 "WindowModule.cs"
    long long csharp2cuda_temp_2 = (accumulator)[283];
    if (((((long long)(csharp2cuda_i32_add(index, 2)))) > (csharp2cuda_temp_2)))
    {
#line 793 "WindowModule.cs"
#line 793 "WindowModule.cs"
        long long* csharp2cuda_temp_3 = &((accumulator)[283]);
        (*(csharp2cuda_temp_3) = ((long long)(csharp2cuda_i32_add(index, 2))));
    }
#line 794 "WindowModule.cs"
#line 794 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((accumulator)[284]);
#line 794 "WindowModule.cs"
    long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
    (*(csharp2cuda_temp_4) = csharp2cuda_i64_add(csharp2cuda_temp_5, 1LL));
#line 795 "WindowModule.cs"
#line 795 "WindowModule.cs"
    long long csharp2cuda_temp_6 = (accumulator)[284];
    if (((csharp2cuda_temp_6) == (134217728LL)))
#line 796 "WindowModule.cs"
    {
#line 797 "WindowModule.cs"
#line 797 "WindowModule.cs"
        long long csharp2cuda_temp_7 = (accumulator)[282];
#line 797 "WindowModule.cs"
        long long csharp2cuda_temp_8 = (accumulator)[283];
        mathblocks_window_exact_carry(accumulator, csharp2cuda_i32_from_bits(csharp2cuda_temp_7), csharp2cuda_i32_from_bits(csharp2cuda_temp_8));
#line 798 "WindowModule.cs"
#line 798 "WindowModule.cs"
        long long* csharp2cuda_temp_9 = &((accumulator)[283]);
#line 798 "WindowModule.cs"
        long long csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
        (*(csharp2cuda_temp_9) = csharp2cuda_i64_add(csharp2cuda_temp_10, 1LL));
#line 799 "WindowModule.cs"
#line 799 "WindowModule.cs"
        long long* csharp2cuda_temp_11 = &((accumulator)[284]);
        (*(csharp2cuda_temp_11) = 0LL);
    }
}

#line 827 "WindowModule.cs"
__device__ void mathblocks_window_exact_add_square(long long* accumulator, double value, bool subtract)
#line 829 "WindowModule.cs"
{
#line 830 "WindowModule.cs"
    if (((value) == (0.0)))
    {
#line 831 "WindowModule.cs"
        return;
    }
#line 832 "WindowModule.cs"
    double magnitude = fabs(value);
#line 833 "WindowModule.cs"
    double scaled = value;
#line 834 "WindowModule.cs"
    int shift = 0;
#line 835 "WindowModule.cs"
    if (((magnitude) < (mathblocks_window_power_of_two(csharp2cuda_i32_neg(400)))))
#line 836 "WindowModule.cs"
    {
#line 837 "WindowModule.cs"
#line 837 "WindowModule.cs"
        double* csharp2cuda_temp_0 = &(scaled);
        (*(csharp2cuda_temp_0) = __dmul_rn(value, mathblocks_window_power_of_two(600)));
#line 838 "WindowModule.cs"
#line 838 "WindowModule.cs"
        int* csharp2cuda_temp_1 = &(shift);
        (*(csharp2cuda_temp_1) = csharp2cuda_i32_neg(1200));
    }
    else
    {
#line 840 "WindowModule.cs"
        if (((magnitude) > (mathblocks_window_power_of_two(400))))
#line 841 "WindowModule.cs"
        {
#line 842 "WindowModule.cs"
#line 842 "WindowModule.cs"
            double* csharp2cuda_temp_2 = &(scaled);
            (*(csharp2cuda_temp_2) = __dmul_rn(value, mathblocks_window_power_of_two(csharp2cuda_i32_neg(600))));
#line 843 "WindowModule.cs"
#line 843 "WindowModule.cs"
            int* csharp2cuda_temp_3 = &(shift);
            (*(csharp2cuda_temp_3) = 1200);
        }
    }
#line 845 "WindowModule.cs"
    double product = 0.0;
#line 846 "WindowModule.cs"
    double error = 0.0;
#line 847 "WindowModule.cs"
#line 847 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(product);
#line 847 "WindowModule.cs"
    double* csharp2cuda_temp_5 = &(error);
    mathblocks_window_two_product(scaled, scaled, csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 848 "WindowModule.cs"
    mathblocks_window_exact_add(accumulator, product, shift, subtract);
#line 849 "WindowModule.cs"
    mathblocks_window_exact_add(accumulator, error, shift, subtract);
}

#line 721 "WindowModule.cs"
__device__ int mathblocks_window_exact_add_to(long long* target, double value, int shift, bool subtract)
#line 723 "WindowModule.cs"
{
#line 724 "WindowModule.cs"
    long long bits = __double_as_longlong(value);
#line 725 "WindowModule.cs"
    bool negative = ((((bits) < (0LL))) != (subtract));
#line 726 "WindowModule.cs"
    int biased = csharp2cuda_i32_from_bits(csharp2cuda_i64_and(csharp2cuda_i64_shr(bits, 52), 2047LL));
#line 727 "WindowModule.cs"
    long long significand = csharp2cuda_i64_and(bits, 4503599627370495LL);
#line 728 "WindowModule.cs"
    int exponent;
#line 729 "WindowModule.cs"
    if (((biased) == (0)))
#line 730 "WindowModule.cs"
    {
#line 731 "WindowModule.cs"
#line 731 "WindowModule.cs"
        int* csharp2cuda_temp_0 = &(exponent);
        (*(csharp2cuda_temp_0) = csharp2cuda_i32_neg(1074));
    }
    else
#line 734 "WindowModule.cs"
    {
#line 735 "WindowModule.cs"
#line 735 "WindowModule.cs"
        long long* csharp2cuda_temp_1 = &(significand);
#line 735 "WindowModule.cs"
        long long csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
        (*(csharp2cuda_temp_1) = csharp2cuda_i64_or(csharp2cuda_temp_2, csharp2cuda_i64_shl(1LL, 52)));
#line 736 "WindowModule.cs"
#line 736 "WindowModule.cs"
        int* csharp2cuda_temp_3 = &(exponent);
        (*(csharp2cuda_temp_3) = csharp2cuda_i32_sub(biased, 1075));
    }
#line 738 "WindowModule.cs"
    int position = csharp2cuda_i32_add(csharp2cuda_i32_add(exponent, shift), 2208);
#line 739 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(position, 5);
#line 740 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(position, 31);
#line 741 "WindowModule.cs"
    long long low_part = csharp2cuda_i64_shl(csharp2cuda_i64_and(significand, 4294967295LL), offset);
#line 742 "WindowModule.cs"
    long long high_part = csharp2cuda_i64_shl(csharp2cuda_i64_shr(significand, 32), offset);
#line 743 "WindowModule.cs"
    long long first = csharp2cuda_i64_and(low_part, 4294967295LL);
#line 744 "WindowModule.cs"
    long long second = csharp2cuda_i64_add(csharp2cuda_i64_shr(low_part, 32), csharp2cuda_i64_and(high_part, 4294967295LL));
#line 745 "WindowModule.cs"
    long long third = csharp2cuda_i64_shr(high_part, 32);
#line 746 "WindowModule.cs"
    if (negative)
#line 747 "WindowModule.cs"
    {
#line 748 "WindowModule.cs"
#line 748 "WindowModule.cs"
        long long* csharp2cuda_temp_4 = &((target)[index]);
#line 748 "WindowModule.cs"
        long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
        (*(csharp2cuda_temp_4) = csharp2cuda_i64_sub(csharp2cuda_temp_5, first));
#line 749 "WindowModule.cs"
#line 749 "WindowModule.cs"
        long long* csharp2cuda_temp_6 = &((target)[csharp2cuda_i32_add(index, 1)]);
#line 749 "WindowModule.cs"
        long long csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
        (*(csharp2cuda_temp_6) = csharp2cuda_i64_sub(csharp2cuda_temp_7, second));
#line 750 "WindowModule.cs"
#line 750 "WindowModule.cs"
        long long* csharp2cuda_temp_8 = &((target)[csharp2cuda_i32_add(index, 2)]);
#line 750 "WindowModule.cs"
        long long csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
        (*(csharp2cuda_temp_8) = csharp2cuda_i64_sub(csharp2cuda_temp_9, third));
    }
    else
#line 753 "WindowModule.cs"
    {
#line 754 "WindowModule.cs"
#line 754 "WindowModule.cs"
        long long* csharp2cuda_temp_10 = &((target)[index]);
#line 754 "WindowModule.cs"
        long long csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
        (*(csharp2cuda_temp_10) = csharp2cuda_i64_add(csharp2cuda_temp_11, first));
#line 755 "WindowModule.cs"
#line 755 "WindowModule.cs"
        long long* csharp2cuda_temp_12 = &((target)[csharp2cuda_i32_add(index, 1)]);
#line 755 "WindowModule.cs"
        long long csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
        (*(csharp2cuda_temp_12) = csharp2cuda_i64_add(csharp2cuda_temp_13, second));
#line 756 "WindowModule.cs"
#line 756 "WindowModule.cs"
        long long* csharp2cuda_temp_14 = &((target)[csharp2cuda_i32_add(index, 2)]);
#line 756 "WindowModule.cs"
        long long csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
        (*(csharp2cuda_temp_14) = csharp2cuda_i64_add(csharp2cuda_temp_15, third));
    }
#line 758 "WindowModule.cs"
    return index;
}

#line 888 "WindowModule.cs"
__device__ bool mathblocks_window_exact_any_below(const long long* value, int lowest, int position)
#line 890 "WindowModule.cs"
{
#line 891 "WindowModule.cs"
    int relative = csharp2cuda_i32_add(position, 2208);
#line 892 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(relative, 5);
#line 893 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(relative, 31);
#line 894 "WindowModule.cs"
#line 894 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (value)[index];
    if (((csharp2cuda_i64_and(csharp2cuda_temp_0, csharp2cuda_i64_sub(csharp2cuda_i64_shl(1LL, offset), 1LL))) != (0LL)))
    {
#line 895 "WindowModule.cs"
        return true;
    }
#line 896 "WindowModule.cs"
    {
#line 896 "WindowModule.cs"
        int chunk = lowest;
        while (true)
        {
            if (!(((chunk) < (index))))
                break;
#line 897 "WindowModule.cs"
#line 897 "WindowModule.cs"
            long long csharp2cuda_temp_2 = (value)[chunk];
            if (((csharp2cuda_temp_2) != (0LL)))
            {
#line 898 "WindowModule.cs"
                return true;
            }
#line 896 "WindowModule.cs"
            int* csharp2cuda_temp_1 = &(chunk);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 899 "WindowModule.cs"
    return false;
}

#line 874 "WindowModule.cs"
__device__ long long mathblocks_window_exact_bits(const long long* value, int position, int count)
#line 876 "WindowModule.cs"
{
#line 877 "WindowModule.cs"
    int relative = csharp2cuda_i32_add(position, 2208);
#line 878 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(relative, 5);
#line 879 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(relative, 31);
#line 880 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (value)[index];
#line 880 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (value)[csharp2cuda_i32_add(index, 1)];
#line 880 "WindowModule.cs"
    unsigned long long word = ((((unsigned long long)(csharp2cuda_temp_0))) | (csharp2cuda_u64_shl(((unsigned long long)(csharp2cuda_temp_1)), 32)));
#line 881 "WindowModule.cs"
    unsigned long long result = csharp2cuda_u64_shr(word, offset);
#line 882 "WindowModule.cs"
    if (((offset) != (0)))
    {
#line 883 "WindowModule.cs"
#line 883 "WindowModule.cs"
        unsigned long long* csharp2cuda_temp_2 = &(result);
#line 883 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 883 "WindowModule.cs"
        long long csharp2cuda_temp_4 = (value)[csharp2cuda_i32_add(index, 2)];
        (*(csharp2cuda_temp_2) = ((csharp2cuda_temp_3) | (csharp2cuda_u64_shl(((unsigned long long)(csharp2cuda_temp_4)), csharp2cuda_i32_sub(64, offset)))));
    }
#line 884 "WindowModule.cs"
    return csharp2cuda_i64_from_bits(((result) & (((csharp2cuda_u64_shl(1ull, count)) - (1ull)))));
}

#line 763 "WindowModule.cs"
__device__ long long mathblocks_window_exact_carry(long long* target, int first, int last)
#line 765 "WindowModule.cs"
{
#line 766 "WindowModule.cs"
    long long carry = 0LL;
#line 767 "WindowModule.cs"
    {
#line 767 "WindowModule.cs"
        int index = first;
        while (true)
        {
            if (!(((index) <= (last))))
                break;
#line 768 "WindowModule.cs"
            {
#line 769 "WindowModule.cs"
                long long csharp2cuda_temp_1 = (target)[index];
#line 769 "WindowModule.cs"
                long long current = csharp2cuda_i64_add(csharp2cuda_temp_1, carry);
#line 770 "WindowModule.cs"
#line 770 "WindowModule.cs"
                long long* csharp2cuda_temp_2 = &(carry);
                (*(csharp2cuda_temp_2) = csharp2cuda_i64_shr(current, 32));
#line 771 "WindowModule.cs"
#line 771 "WindowModule.cs"
                long long* csharp2cuda_temp_3 = &((target)[index]);
                (*(csharp2cuda_temp_3) = csharp2cuda_i64_and(current, 4294967295LL));
            }
#line 767 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 773 "WindowModule.cs"
#line 773 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((target)[csharp2cuda_i32_add(last, 1)]);
#line 773 "WindowModule.cs"
    long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
    (*(csharp2cuda_temp_4) = csharp2cuda_i64_add(csharp2cuda_temp_5, carry));
#line 774 "WindowModule.cs"
    return (target)[csharp2cuda_i32_add(last, 1)];
}

#line 710 "WindowModule.cs"
__device__ void mathblocks_window_exact_clear(long long* accumulator)
#line 712 "WindowModule.cs"
{
#line 713 "WindowModule.cs"
    {
#line 713 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (282))))
                break;
#line 714 "WindowModule.cs"
#line 714 "WindowModule.cs"
            long long* csharp2cuda_temp_1 = &((accumulator)[index]);
            (*(csharp2cuda_temp_1) = 0LL);
#line 713 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 715 "WindowModule.cs"
#line 715 "WindowModule.cs"
    long long* csharp2cuda_temp_2 = &((accumulator)[282]);
    (*(csharp2cuda_temp_2) = 141LL);
#line 716 "WindowModule.cs"
#line 716 "WindowModule.cs"
    long long* csharp2cuda_temp_3 = &((accumulator)[283]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i64_neg(1LL));
#line 717 "WindowModule.cs"
#line 717 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((accumulator)[284]);
    (*(csharp2cuda_temp_4) = 0LL);
}

#line 854 "WindowModule.cs"
__device__ int mathblocks_window_exact_load(long long* accumulator, bool* negative)
#line 856 "WindowModule.cs"
{
#line 857 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 858 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[282];
#line 858 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_0);
#line 859 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (accumulator)[283];
#line 859 "WindowModule.cs"
    int highest = csharp2cuda_i32_from_bits(csharp2cuda_temp_1);
#line 860 "WindowModule.cs"
    {
#line 860 "WindowModule.cs"
        int index = lowest;
        while (true)
        {
            if (!(((index) <= (highest))))
                break;
#line 861 "WindowModule.cs"
#line 861 "WindowModule.cs"
            long long* csharp2cuda_temp_3 = &((scratch)[index]);
#line 861 "WindowModule.cs"
            long long csharp2cuda_temp_4 = (accumulator)[index];
            (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 860 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 862 "WindowModule.cs"
    {
#line 862 "WindowModule.cs"
        int index = csharp2cuda_i32_add(highest, 1);
        while (true)
        {
            if (!(((index) <= (csharp2cuda_i32_add(highest, 4)))))
                break;
#line 863 "WindowModule.cs"
#line 863 "WindowModule.cs"
            long long* csharp2cuda_temp_6 = &((scratch)[index]);
            (*(csharp2cuda_temp_6) = 0LL);
#line 862 "WindowModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
#line 864 "WindowModule.cs"
#line 864 "WindowModule.cs"
    bool* csharp2cuda_temp_7 = negative;
#line 864 "WindowModule.cs"
    long long csharp2cuda_temp_8 = mathblocks_window_exact_carry(scratch, lowest, highest);
    (*(csharp2cuda_temp_7) = ((csharp2cuda_temp_8) < (0LL)));
#line 865 "WindowModule.cs"
    if (*(negative))
#line 866 "WindowModule.cs"
    {
#line 867 "WindowModule.cs"
        mathblocks_window_exact_negate(scratch, lowest, csharp2cuda_i32_add(highest, 1));
#line 868 "WindowModule.cs"
        mathblocks_window_exact_carry(scratch, lowest, csharp2cuda_i32_add(highest, 1));
    }
#line 870 "WindowModule.cs"
    return csharp2cuda_i32_add(highest, 1);
}

#line 777 "WindowModule.cs"
__device__ void mathblocks_window_exact_negate(long long* target, int first, int last)
#line 779 "WindowModule.cs"
{
#line 780 "WindowModule.cs"
    {
#line 780 "WindowModule.cs"
        int index = first;
        while (true)
        {
            if (!(((index) <= (last))))
                break;
#line 781 "WindowModule.cs"
#line 781 "WindowModule.cs"
            long long* csharp2cuda_temp_1 = &((target)[index]);
#line 781 "WindowModule.cs"
            long long csharp2cuda_temp_2 = (target)[index];
            (*(csharp2cuda_temp_1) = csharp2cuda_i64_neg(csharp2cuda_temp_2));
#line 780 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 940 "WindowModule.cs"
__device__ void mathblocks_window_exact_read_pair(long long* accumulator, double* high, double* low, bool* zero)
#line 942 "WindowModule.cs"
{
#line 943 "WindowModule.cs"
#line 943 "WindowModule.cs"
    double* csharp2cuda_temp_0 = high;
    (*(csharp2cuda_temp_0) = 0.0);
#line 944 "WindowModule.cs"
#line 944 "WindowModule.cs"
    double* csharp2cuda_temp_1 = low;
    (*(csharp2cuda_temp_1) = 0.0);
#line 945 "WindowModule.cs"
#line 945 "WindowModule.cs"
    bool* csharp2cuda_temp_2 = zero;
    (*(csharp2cuda_temp_2) = true);
#line 946 "WindowModule.cs"
#line 946 "WindowModule.cs"
    long long csharp2cuda_temp_3 = (accumulator)[283];
    if (((csharp2cuda_temp_3) < (0LL)))
    {
#line 947 "WindowModule.cs"
        return;
    }
#line 948 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 949 "WindowModule.cs"
    long long csharp2cuda_temp_4 = (accumulator)[282];
#line 949 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_4);
#line 950 "WindowModule.cs"
    bool negative = false;
#line 951 "WindowModule.cs"
    bool* csharp2cuda_temp_5 = &(negative);
#line 951 "WindowModule.cs"
    int top = mathblocks_window_exact_load(accumulator, csharp2cuda_temp_5);
#line 952 "WindowModule.cs"
    {
#line 952 "WindowModule.cs"
        int index = lowest;
        while (true)
        {
            if (!(((index) <= (top))))
                break;
#line 953 "WindowModule.cs"
#line 953 "WindowModule.cs"
            long long csharp2cuda_temp_7 = (scratch)[index];
            if (((csharp2cuda_temp_7) != (0LL)))
            {
#line 954 "WindowModule.cs"
#line 954 "WindowModule.cs"
                bool* csharp2cuda_temp_8 = zero;
                (*(csharp2cuda_temp_8) = false);
            }
#line 952 "WindowModule.cs"
            int* csharp2cuda_temp_6 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 955 "WindowModule.cs"
#line 955 "WindowModule.cs"
    double* csharp2cuda_temp_9 = high;
#line 955 "WindowModule.cs"
    double csharp2cuda_temp_10 = mathblocks_window_exact_round(scratch, lowest, top, false);
    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
#line 956 "WindowModule.cs"
#line 956 "WindowModule.cs"
    double csharp2cuda_temp_11 = *(high);
    if ((!(isfinite(csharp2cuda_temp_11))))
#line 957 "WindowModule.cs"
    {
#line 958 "WindowModule.cs"
#line 958 "WindowModule.cs"
        double* csharp2cuda_temp_12 = high;
#line 958 "WindowModule.cs"
        double csharp2cuda_temp_13;
#line 958 "WindowModule.cs"
        if (negative)
        {
#line 958 "WindowModule.cs"
            double csharp2cuda_temp_14 = *(high);
#line 958 "WindowModule.cs"
            csharp2cuda_temp_13 = (-(csharp2cuda_temp_14));
        }
        else
        {
#line 958 "WindowModule.cs"
            csharp2cuda_temp_13 = *(high);
        }
        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 959 "WindowModule.cs"
        return;
    }
#line 961 "WindowModule.cs"
#line 961 "WindowModule.cs"
    double csharp2cuda_temp_15 = *(high);
    mathblocks_window_exact_add_to(scratch, csharp2cuda_temp_15, 0, true);
#line 962 "WindowModule.cs"
    long long csharp2cuda_temp_16 = mathblocks_window_exact_carry(scratch, lowest, top);
#line 962 "WindowModule.cs"
    bool rest_negative = ((csharp2cuda_temp_16) < (0LL));
#line 963 "WindowModule.cs"
    if (rest_negative)
#line 964 "WindowModule.cs"
    {
#line 965 "WindowModule.cs"
        mathblocks_window_exact_negate(scratch, lowest, csharp2cuda_i32_add(top, 1));
#line 966 "WindowModule.cs"
        mathblocks_window_exact_carry(scratch, lowest, csharp2cuda_i32_add(top, 1));
    }
#line 968 "WindowModule.cs"
#line 968 "WindowModule.cs"
    double* csharp2cuda_temp_17 = low;
#line 968 "WindowModule.cs"
    double csharp2cuda_temp_18 = mathblocks_window_exact_round(scratch, lowest, csharp2cuda_i32_add(top, 1), false);
    (*(csharp2cuda_temp_17) = csharp2cuda_temp_18);
#line 969 "WindowModule.cs"
    if (rest_negative)
    {
#line 970 "WindowModule.cs"
#line 970 "WindowModule.cs"
        double* csharp2cuda_temp_19 = low;
#line 970 "WindowModule.cs"
        double csharp2cuda_temp_20 = *(low);
        (*(csharp2cuda_temp_19) = (-(csharp2cuda_temp_20)));
    }
#line 971 "WindowModule.cs"
    if (negative)
#line 972 "WindowModule.cs"
    {
#line 973 "WindowModule.cs"
#line 973 "WindowModule.cs"
        double* csharp2cuda_temp_21 = high;
#line 973 "WindowModule.cs"
        double csharp2cuda_temp_22 = *(high);
        (*(csharp2cuda_temp_21) = (-(csharp2cuda_temp_22)));
#line 974 "WindowModule.cs"
#line 974 "WindowModule.cs"
        double* csharp2cuda_temp_23 = low;
#line 974 "WindowModule.cs"
        double csharp2cuda_temp_24 = *(low);
        (*(csharp2cuda_temp_23) = (-(csharp2cuda_temp_24)));
    }
}

#line 981 "WindowModule.cs"
__device__ double mathblocks_window_exact_read_quotient(long long* accumulator, int divisor)
#line 983 "WindowModule.cs"
{
#line 984 "WindowModule.cs"
#line 984 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[283];
    if (((csharp2cuda_temp_0) < (0LL)))
    {
#line 985 "WindowModule.cs"
        return 0.0;
    }
#line 986 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 987 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (accumulator)[282];
#line 987 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_1);
#line 988 "WindowModule.cs"
    bool negative = false;
#line 989 "WindowModule.cs"
    bool* csharp2cuda_temp_2 = &(negative);
#line 989 "WindowModule.cs"
    int top = mathblocks_window_exact_load(accumulator, csharp2cuda_temp_2);
#line 990 "WindowModule.cs"
    int leading = top;
#line 991 "WindowModule.cs"
    while (true)
    {
#line 991 "WindowModule.cs"
        bool csharp2cuda_temp_3;
#line 991 "WindowModule.cs"
        if (((leading) > (lowest)))
        {
#line 991 "WindowModule.cs"
            long long csharp2cuda_temp_4 = (scratch)[leading];
#line 991 "WindowModule.cs"
            csharp2cuda_temp_3 = ((csharp2cuda_temp_4) == (0LL));
        }
        else
        {
#line 991 "WindowModule.cs"
            csharp2cuda_temp_3 = false;
        }
        if (!(csharp2cuda_temp_3))
            break;
#line 992 "WindowModule.cs"
#line 992 "WindowModule.cs"
        int* csharp2cuda_temp_5 = &(leading);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
    }
#line 993 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 993 "WindowModule.cs"
    if (((csharp2cuda_i32_sub(leading, 4)) < (lowest)))
    {
#line 993 "WindowModule.cs"
        csharp2cuda_temp_6 = csharp2cuda_i32_sub(leading, 4);
    }
    else
    {
#line 993 "WindowModule.cs"
        csharp2cuda_temp_6 = lowest;
    }
#line 993 "WindowModule.cs"
    int start = csharp2cuda_temp_6;
#line 994 "WindowModule.cs"
    if (((start) < (0)))
    {
#line 995 "WindowModule.cs"
#line 995 "WindowModule.cs"
        int* csharp2cuda_temp_7 = &(start);
        (*(csharp2cuda_temp_7) = 0);
    }
#line 996 "WindowModule.cs"
    long long remainder = 0LL;
#line 997 "WindowModule.cs"
    {
#line 997 "WindowModule.cs"
        int index = csharp2cuda_i32_add(top, 1);
        while (true)
        {
            if (!(((index) >= (start))))
                break;
#line 998 "WindowModule.cs"
            {
#line 999 "WindowModule.cs"
                long long csharp2cuda_temp_9 = (scratch)[index];
#line 999 "WindowModule.cs"
                long long current = csharp2cuda_i64_or(csharp2cuda_i64_shl(remainder, 32), csharp2cuda_temp_9);
#line 1000 "WindowModule.cs"
#line 1000 "WindowModule.cs"
                long long* csharp2cuda_temp_10 = &((scratch)[index]);
#line 1000 "WindowModule.cs"
                long long csharp2cuda_temp_11 = csharp2cuda_i64_div(current, ((long long)(divisor)));
                (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
#line 1001 "WindowModule.cs"
#line 1001 "WindowModule.cs"
                long long* csharp2cuda_temp_12 = &(remainder);
#line 1001 "WindowModule.cs"
                long long csharp2cuda_temp_13 = csharp2cuda_i64_rem(current, ((long long)(divisor)));
                (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
            }
#line 997 "WindowModule.cs"
            int* csharp2cuda_temp_8 = &(index);
            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_8));
        }
    }
#line 1003 "WindowModule.cs"
    double result = mathblocks_window_exact_round(scratch, start, csharp2cuda_i32_add(top, 1), ((remainder) != (0LL)));
#line 1004 "WindowModule.cs"
    {
#line 1004 "WindowModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (lowest))))
                break;
#line 1005 "WindowModule.cs"
#line 1005 "WindowModule.cs"
            long long* csharp2cuda_temp_15 = &((scratch)[index]);
            (*(csharp2cuda_temp_15) = 0LL);
#line 1004 "WindowModule.cs"
            int* csharp2cuda_temp_14 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
#line 1006 "WindowModule.cs"
#line 1006 "WindowModule.cs"
    double csharp2cuda_temp_16;
#line 1006 "WindowModule.cs"
    if (negative)
    {
#line 1006 "WindowModule.cs"
        csharp2cuda_temp_16 = (-(result));
    }
    else
    {
#line 1006 "WindowModule.cs"
        csharp2cuda_temp_16 = result;
    }
    return csharp2cuda_temp_16;
}

#line 904 "WindowModule.cs"
__device__ double mathblocks_window_exact_round(const long long* value, int lowest, int top, bool sticky)
#line 906 "WindowModule.cs"
{
#line 907 "WindowModule.cs"
    int chunk = top;
#line 908 "WindowModule.cs"
    while (true)
    {
#line 908 "WindowModule.cs"
        bool csharp2cuda_temp_0;
#line 908 "WindowModule.cs"
        if (((chunk) >= (lowest)))
        {
#line 908 "WindowModule.cs"
            long long csharp2cuda_temp_1 = (value)[chunk];
#line 908 "WindowModule.cs"
            csharp2cuda_temp_0 = ((csharp2cuda_temp_1) == (0LL));
        }
        else
        {
#line 908 "WindowModule.cs"
            csharp2cuda_temp_0 = false;
        }
        if (!(csharp2cuda_temp_0))
            break;
#line 909 "WindowModule.cs"
#line 909 "WindowModule.cs"
        int* csharp2cuda_temp_2 = &(chunk);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_2));
    }
#line 910 "WindowModule.cs"
    if (((chunk) < (lowest)))
    {
#line 911 "WindowModule.cs"
        return 0.0;
    }
#line 912 "WindowModule.cs"
    int bit = 31;
#line 913 "WindowModule.cs"
    while (true)
    {
#line 913 "WindowModule.cs"
        long long csharp2cuda_temp_3 = (value)[chunk];
        if (!(((csharp2cuda_i64_and(csharp2cuda_i64_shr(csharp2cuda_temp_3, bit), 1LL)) == (0LL))))
            break;
#line 914 "WindowModule.cs"
#line 914 "WindowModule.cs"
        int* csharp2cuda_temp_4 = &(bit);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_4));
    }
#line 915 "WindowModule.cs"
    int most = csharp2cuda_i32_add(csharp2cuda_i32_add(csharp2cuda_i32_neg(2208), csharp2cuda_i32_mul(32, chunk)), bit);
#line 916 "WindowModule.cs"
    int csharp2cuda_temp_5;
#line 916 "WindowModule.cs"
    if (((csharp2cuda_i32_sub(most, 52)) < (csharp2cuda_i32_neg(1074))))
    {
#line 916 "WindowModule.cs"
        csharp2cuda_temp_5 = csharp2cuda_i32_neg(1074);
    }
    else
    {
#line 916 "WindowModule.cs"
        csharp2cuda_temp_5 = csharp2cuda_i32_sub(most, 52);
    }
#line 916 "WindowModule.cs"
    int least = csharp2cuda_temp_5;
#line 917 "WindowModule.cs"
    int count = csharp2cuda_i32_add(csharp2cuda_i32_sub(most, least), 1);
#line 918 "WindowModule.cs"
    long long csharp2cuda_temp_6;
#line 918 "WindowModule.cs"
    if (((count) > (0)))
    {
#line 918 "WindowModule.cs"
        csharp2cuda_temp_6 = mathblocks_window_exact_bits(value, least, count);
    }
    else
    {
#line 918 "WindowModule.cs"
        csharp2cuda_temp_6 = 0LL;
    }
#line 918 "WindowModule.cs"
    long long significand = csharp2cuda_temp_6;
#line 919 "WindowModule.cs"
    long long csharp2cuda_temp_7 = mathblocks_window_exact_bits(value, csharp2cuda_i32_sub(least, 1), 1);
#line 919 "WindowModule.cs"
    bool round = ((csharp2cuda_temp_7) != (0LL));
#line 920 "WindowModule.cs"
    bool csharp2cuda_temp_8;
#line 920 "WindowModule.cs"
    if (!(sticky))
    {
#line 920 "WindowModule.cs"
        csharp2cuda_temp_8 = mathblocks_window_exact_any_below(value, lowest, csharp2cuda_i32_sub(least, 1));
    }
    else
    {
#line 920 "WindowModule.cs"
        csharp2cuda_temp_8 = true;
    }
#line 920 "WindowModule.cs"
    bool below = csharp2cuda_temp_8;
#line 921 "WindowModule.cs"
#line 921 "WindowModule.cs"
    bool csharp2cuda_temp_9;
#line 921 "WindowModule.cs"
    if (round)
    {
#line 921 "WindowModule.cs"
        bool csharp2cuda_temp_10;
#line 921 "WindowModule.cs"
        if (!(below))
        {
#line 921 "WindowModule.cs"
            csharp2cuda_temp_10 = ((csharp2cuda_i64_and(significand, 1LL)) != (0LL));
        }
        else
        {
#line 921 "WindowModule.cs"
            csharp2cuda_temp_10 = true;
        }
#line 921 "WindowModule.cs"
        csharp2cuda_temp_9 = csharp2cuda_temp_10;
    }
    else
    {
#line 921 "WindowModule.cs"
        csharp2cuda_temp_9 = false;
    }
    if (csharp2cuda_temp_9)
    {
#line 922 "WindowModule.cs"
#line 922 "WindowModule.cs"
        long long* csharp2cuda_temp_11 = &(significand);
        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_11));
    }
#line 923 "WindowModule.cs"
    if (((significand) == (csharp2cuda_i64_shl(1LL, 53))))
#line 924 "WindowModule.cs"
    {
#line 925 "WindowModule.cs"
#line 925 "WindowModule.cs"
        long long* csharp2cuda_temp_12 = &(significand);
        (*(csharp2cuda_temp_12) = csharp2cuda_i64_shl(1LL, 52));
#line 926 "WindowModule.cs"
#line 926 "WindowModule.cs"
        int* csharp2cuda_temp_13 = &(least);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
    }
#line 928 "WindowModule.cs"
    if (((significand) >= (csharp2cuda_i64_shl(1LL, 52))))
#line 929 "WindowModule.cs"
    {
#line 930 "WindowModule.cs"
        int biased = csharp2cuda_i32_add(least, 1075);
#line 931 "WindowModule.cs"
        if (((biased) >= (2047)))
        {
#line 932 "WindowModule.cs"
            return __longlong_as_double(9218868437227405312LL);
        }
#line 933 "WindowModule.cs"
        return __longlong_as_double(csharp2cuda_i64_or(csharp2cuda_i64_shl(((long long)(biased)), 52), csharp2cuda_i64_sub(significand, csharp2cuda_i64_shl(1LL, 52))));
    }
#line 935 "WindowModule.cs"
    return __longlong_as_double(significand);
}

#line 1018 "WindowModule.cs"
__device__ void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e)
#line 1020 "WindowModule.cs"
{
#line 1021 "WindowModule.cs"
#line 1021 "WindowModule.cs"
    double* csharp2cuda_temp_0 = s;
    (*(csharp2cuda_temp_0) = __dadd_rn(a, b));
#line 1022 "WindowModule.cs"
#line 1022 "WindowModule.cs"
    double* csharp2cuda_temp_1 = e;
#line 1022 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(s);
    (*(csharp2cuda_temp_1) = __dsub_rn(b, __dsub_rn(csharp2cuda_temp_2, a)));
}

#line 304 "WindowModule.cs"
__device__ void mathblocks_window_heap_sift(double* values, int root, int end)
#line 306 "WindowModule.cs"
{
#line 307 "WindowModule.cs"
    int child = csharp2cuda_i32_add(csharp2cuda_i32_mul(2, root), 1);
#line 308 "WindowModule.cs"
    while (true)
    {
        if (!(((child) < (end))))
            break;
#line 309 "WindowModule.cs"
        {
#line 310 "WindowModule.cs"
#line 310 "WindowModule.cs"
            bool csharp2cuda_temp_0;
#line 310 "WindowModule.cs"
            if (((csharp2cuda_i32_add(child, 1)) < (end)))
            {
#line 310 "WindowModule.cs"
                double csharp2cuda_temp_1 = (values)[csharp2cuda_i32_add(child, 1)];
#line 310 "WindowModule.cs"
                double csharp2cuda_temp_2 = (values)[child];
#line 310 "WindowModule.cs"
                csharp2cuda_temp_0 = ((csharp2cuda_temp_1) > (csharp2cuda_temp_2));
            }
            else
            {
#line 310 "WindowModule.cs"
                csharp2cuda_temp_0 = false;
            }
            if (csharp2cuda_temp_0)
            {
#line 311 "WindowModule.cs"
#line 311 "WindowModule.cs"
                int* csharp2cuda_temp_3 = &(child);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
            }
#line 312 "WindowModule.cs"
#line 312 "WindowModule.cs"
            double csharp2cuda_temp_4 = (values)[child];
#line 312 "WindowModule.cs"
            double csharp2cuda_temp_5 = (values)[root];
            if ((!(((csharp2cuda_temp_4) > (csharp2cuda_temp_5)))))
            {
#line 313 "WindowModule.cs"
                break;
            }
#line 314 "WindowModule.cs"
            double moved = (values)[root];
#line 315 "WindowModule.cs"
#line 315 "WindowModule.cs"
            double* csharp2cuda_temp_6 = &((values)[root]);
#line 315 "WindowModule.cs"
            double csharp2cuda_temp_7 = (values)[child];
            (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
#line 316 "WindowModule.cs"
#line 316 "WindowModule.cs"
            double* csharp2cuda_temp_8 = &((values)[child]);
            (*(csharp2cuda_temp_8) = moved);
#line 317 "WindowModule.cs"
#line 317 "WindowModule.cs"
            int* csharp2cuda_temp_9 = &(root);
            (*(csharp2cuda_temp_9) = child);
#line 318 "WindowModule.cs"
#line 318 "WindowModule.cs"
            int* csharp2cuda_temp_10 = &(child);
            (*(csharp2cuda_temp_10) = csharp2cuda_i32_add(csharp2cuda_i32_mul(2, root), 1));
        }
    }
}

#line 324 "WindowModule.cs"
__device__ void mathblocks_window_heap_sort(double* values, int count)
#line 326 "WindowModule.cs"
{
#line 327 "WindowModule.cs"
    {
#line 327 "WindowModule.cs"
        int csharp2cuda_temp_0 = csharp2cuda_i32_div(count, 2);
#line 327 "WindowModule.cs"
        int start = csharp2cuda_i32_sub(csharp2cuda_temp_0, 1);
        while (true)
        {
            if (!(((start) >= (0))))
                break;
#line 328 "WindowModule.cs"
            mathblocks_window_heap_sift(values, start, count);
#line 327 "WindowModule.cs"
            int* csharp2cuda_temp_1 = &(start);
            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_1));
        }
    }
#line 329 "WindowModule.cs"
    {
#line 329 "WindowModule.cs"
        int end = csharp2cuda_i32_sub(count, 1);
        while (true)
        {
            if (!(((end) > (0))))
                break;
#line 330 "WindowModule.cs"
            {
#line 331 "WindowModule.cs"
                double top = (values)[0];
#line 332 "WindowModule.cs"
#line 332 "WindowModule.cs"
                double* csharp2cuda_temp_3 = &((values)[0]);
#line 332 "WindowModule.cs"
                double csharp2cuda_temp_4 = (values)[end];
                (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 333 "WindowModule.cs"
#line 333 "WindowModule.cs"
                double* csharp2cuda_temp_5 = &((values)[end]);
                (*(csharp2cuda_temp_5) = top);
#line 334 "WindowModule.cs"
                mathblocks_window_heap_sift(values, 0, end);
            }
#line 329 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(end);
            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_2));
        }
    }
}

#line 1071 "WindowModule.cs"
__device__ bool mathblocks_window_in_range(double value, double largest)
#line 1073 "WindowModule.cs"
{
#line 1074 "WindowModule.cs"
#line 1074 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 1074 "WindowModule.cs"
    if (!(((value) == (0.0))))
    {
#line 1075 "WindowModule.cs"
        bool csharp2cuda_temp_1;
#line 1075 "WindowModule.cs"
        if (((fabs(value)) >= (mathblocks_window_power_of_two(csharp2cuda_i32_neg(968)))))
        {
#line 1075 "WindowModule.cs"
            csharp2cuda_temp_1 = ((fabs(value)) <= (largest));
        }
        else
        {
#line 1075 "WindowModule.cs"
            csharp2cuda_temp_1 = false;
        }
#line 1074 "WindowModule.cs"
        csharp2cuda_temp_0 = csharp2cuda_temp_1;
    }
    else
    {
#line 1074 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
    return csharp2cuda_temp_0;
}

#line 704 "WindowModule.cs"
__device__ double mathblocks_window_power_of_two(int exponent)
#line 706 "WindowModule.cs"
{
#line 707 "WindowModule.cs"
    return __longlong_as_double(csharp2cuda_i64_shl(((long long)(csharp2cuda_i32_add(exponent, 1023))), 52));
}

#line 1251 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread)
#line 1253 "WindowModule.cs"
{
#line 1254 "WindowModule.cs"
    if (((thread) != (0)))
    {
#line 1255 "WindowModule.cs"
        return;
    }
#line 1256 "WindowModule.cs"
#line 1256 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &((output)->scalar_value);
    (*(csharp2cuda_temp_0) = 0.0);
#line 1257 "WindowModule.cs"
#line 1257 "WindowModule.cs"
    int* csharp2cuda_temp_1 = &((output)->boolean_value);
    (*(csharp2cuda_temp_1) = 0);
#line 1258 "WindowModule.cs"
#line 1258 "WindowModule.cs"
    int* csharp2cuda_temp_2 = &((output)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 1259 "WindowModule.cs"
#line 1259 "WindowModule.cs"
    int* csharp2cuda_temp_3 = &((output)->rows);
#line 1259 "WindowModule.cs"
    int csharp2cuda_temp_4;
#line 1259 "WindowModule.cs"
    if (valid)
    {
#line 1259 "WindowModule.cs"
        csharp2cuda_temp_4 = count;
    }
    else
    {
#line 1259 "WindowModule.cs"
        csharp2cuda_temp_4 = 0;
    }
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 1260 "WindowModule.cs"
#line 1260 "WindowModule.cs"
    int* csharp2cuda_temp_5 = &((output)->count);
#line 1260 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 1260 "WindowModule.cs"
    if (valid)
    {
#line 1260 "WindowModule.cs"
        csharp2cuda_temp_6 = count;
    }
    else
    {
#line 1260 "WindowModule.cs"
        csharp2cuda_temp_6 = 0;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 1261 "WindowModule.cs"
#line 1261 "WindowModule.cs"
    int* csharp2cuda_temp_7 = &((output)->valid);
    (*(csharp2cuda_temp_7) = valid);
}

#line 372 "WindowModule.cs"
__device__ void mathblocks_window_ranks(
    const double* a,
    const double* b,
    int count,
    double* scratch)
#line 378 "WindowModule.cs"
{
#line 379 "WindowModule.cs"
    double* left = scratch;
#line 380 "WindowModule.cs"
    double* right = csharp2cuda_pointer_add(scratch, count);
#line 381 "WindowModule.cs"
    bool fast = ((count) <= (268435456));
#line 382 "WindowModule.cs"
    {
#line 382 "WindowModule.cs"
        int index = 0;
        while (true)
        {
#line 382 "WindowModule.cs"
            bool csharp2cuda_temp_1;
#line 382 "WindowModule.cs"
            if (fast)
            {
#line 382 "WindowModule.cs"
                csharp2cuda_temp_1 = ((index) < (count));
            }
            else
            {
#line 382 "WindowModule.cs"
                csharp2cuda_temp_1 = false;
            }
            if (!(csharp2cuda_temp_1))
                break;
#line 383 "WindowModule.cs"
#line 383 "WindowModule.cs"
            double csharp2cuda_temp_2 = (a)[index];
#line 383 "WindowModule.cs"
            bool csharp2cuda_temp_3;
#line 383 "WindowModule.cs"
            if (!(isnan(csharp2cuda_temp_2)))
            {
#line 383 "WindowModule.cs"
                double csharp2cuda_temp_4 = (b)[index];
#line 383 "WindowModule.cs"
                csharp2cuda_temp_3 = isnan(csharp2cuda_temp_4);
            }
            else
            {
#line 383 "WindowModule.cs"
                csharp2cuda_temp_3 = true;
            }
            if (csharp2cuda_temp_3)
            {
#line 384 "WindowModule.cs"
#line 384 "WindowModule.cs"
                bool* csharp2cuda_temp_5 = &(fast);
                (*(csharp2cuda_temp_5) = false);
            }
#line 382 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 385 "WindowModule.cs"
    if ((!(fast)))
#line 386 "WindowModule.cs"
    {
#line 387 "WindowModule.cs"
        mathblocks_statistics_rank(a, count, left);
#line 388 "WindowModule.cs"
        mathblocks_statistics_rank(b, count, right);
#line 389 "WindowModule.cs"
        return;
    }
#line 391 "WindowModule.cs"
    {
#line 391 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 392 "WindowModule.cs"
#line 392 "WindowModule.cs"
            double* csharp2cuda_temp_7 = &((right)[index]);
#line 392 "WindowModule.cs"
            double csharp2cuda_temp_8 = (a)[index];
            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 391 "WindowModule.cs"
            int* csharp2cuda_temp_6 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 393 "WindowModule.cs"
    mathblocks_window_heap_sort(right, count);
#line 399 "WindowModule.cs"
    {
#line 399 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 400 "WindowModule.cs"
            {
#line 401 "WindowModule.cs"
                double csharp2cuda_temp_10 = (a)[index];
#line 401 "WindowModule.cs"
                double csharp2cuda_temp_11 = mathblocks_window_sorted_rank(right, count, csharp2cuda_temp_10);
#line 401 "WindowModule.cs"
                long long twice = csharp2cuda_f64_to_i64(__dmul_rn(csharp2cuda_temp_11, 2.0));
#line 402 "WindowModule.cs"
#line 402 "WindowModule.cs"
                double* csharp2cuda_temp_12 = &((left)[index]);
                (*(csharp2cuda_temp_12) = __longlong_as_double(csharp2cuda_i64_shl(twice, 32)));
            }
#line 399 "WindowModule.cs"
            int* csharp2cuda_temp_9 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
        }
    }
#line 404 "WindowModule.cs"
    {
#line 404 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 405 "WindowModule.cs"
#line 405 "WindowModule.cs"
            double* csharp2cuda_temp_14 = &((right)[index]);
#line 405 "WindowModule.cs"
            double csharp2cuda_temp_15 = (b)[index];
            (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
#line 404 "WindowModule.cs"
            int* csharp2cuda_temp_13 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
        }
    }
#line 406 "WindowModule.cs"
    mathblocks_window_heap_sort(right, count);
#line 407 "WindowModule.cs"
    {
#line 407 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 408 "WindowModule.cs"
            {
#line 409 "WindowModule.cs"
                double csharp2cuda_temp_17 = (b)[index];
#line 409 "WindowModule.cs"
                double csharp2cuda_temp_18 = mathblocks_window_sorted_rank(right, count, csharp2cuda_temp_17);
#line 409 "WindowModule.cs"
                long long twice = csharp2cuda_f64_to_i64(__dmul_rn(csharp2cuda_temp_18, 2.0));
#line 410 "WindowModule.cs"
#line 410 "WindowModule.cs"
                double* csharp2cuda_temp_19 = &((left)[index]);
#line 410 "WindowModule.cs"
                double csharp2cuda_temp_20 = (left)[index];
                (*(csharp2cuda_temp_19) = __longlong_as_double(csharp2cuda_i64_or(__double_as_longlong(csharp2cuda_temp_20), twice)));
            }
#line 407 "WindowModule.cs"
            int* csharp2cuda_temp_16 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
        }
    }
#line 412 "WindowModule.cs"
    {
#line 412 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 413 "WindowModule.cs"
            {
#line 414 "WindowModule.cs"
                double csharp2cuda_temp_22 = (left)[index];
#line 414 "WindowModule.cs"
                long long packed = __double_as_longlong(csharp2cuda_temp_22);
#line 415 "WindowModule.cs"
#line 415 "WindowModule.cs"
                double* csharp2cuda_temp_23 = &((right)[index]);
                (*(csharp2cuda_temp_23) = __dmul_rn(((double)(csharp2cuda_i64_and(packed, 4294967295LL))), 0.5));
#line 416 "WindowModule.cs"
#line 416 "WindowModule.cs"
                double* csharp2cuda_temp_24 = &((left)[index]);
                (*(csharp2cuda_temp_24) = __dmul_rn(((double)(csharp2cuda_i64_and(csharp2cuda_i64_shr(packed, 32), 4294967295LL))), 0.5));
            }
#line 412 "WindowModule.cs"
            int* csharp2cuda_temp_21 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
        }
    }
}

#line 1267 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity)
#line 1276 "WindowModule.cs"
{
#line 1277 "WindowModule.cs"
    int source = csharp2cuda_i32_div(opcode, 2);
#line 1278 "WindowModule.cs"
    int csharp2cuda_temp_0 = csharp2cuda_i32_rem(opcode, 2);
#line 1278 "WindowModule.cs"
    bool sibling = ((csharp2cuda_temp_0) != (0));
#line 1279 "WindowModule.cs"
    int arity = mathblocks_window_source_arity(source);
#line 1280 "WindowModule.cs"
    int series = mathblocks_window_series_count(source);
#line 1281 "WindowModule.cs"
    bool csharp2cuda_temp_1;
#line 1281 "WindowModule.cs"
    if (((opcode) >= (0)))
    {
#line 1281 "WindowModule.cs"
        csharp2cuda_temp_1 = ((source) < (59));
    }
    else
    {
#line 1281 "WindowModule.cs"
        csharp2cuda_temp_1 = false;
    }
#line 1281 "WindowModule.cs"
    bool csharp2cuda_temp_2;
#line 1281 "WindowModule.cs"
    if (csharp2cuda_temp_1)
    {
#line 1281 "WindowModule.cs"
        int csharp2cuda_temp_3;
#line 1281 "WindowModule.cs"
        if (sibling)
        {
#line 1281 "WindowModule.cs"
            csharp2cuda_temp_3 = 1;
        }
        else
        {
#line 1281 "WindowModule.cs"
            csharp2cuda_temp_3 = 2;
        }
#line 1281 "WindowModule.cs"
        csharp2cuda_temp_2 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_3)));
    }
    else
    {
#line 1281 "WindowModule.cs"
        csharp2cuda_temp_2 = false;
    }
#line 1281 "WindowModule.cs"
    bool valid = csharp2cuda_temp_2;
#line 1282 "WindowModule.cs"
    {
#line 1282 "WindowModule.cs"
        int index = 0;
        while (true)
        {
#line 1282 "WindowModule.cs"
            bool csharp2cuda_temp_5;
#line 1282 "WindowModule.cs"
            if (valid)
            {
#line 1282 "WindowModule.cs"
                csharp2cuda_temp_5 = ((index) < (input_count));
            }
            else
            {
#line 1282 "WindowModule.cs"
                csharp2cuda_temp_5 = false;
            }
            if (!(csharp2cuda_temp_5))
                break;
#line 1283 "WindowModule.cs"
#line 1283 "WindowModule.cs"
            MathBlockSlot* csharp2cuda_temp_6 = (inputs)[index];
#line 1283 "WindowModule.cs"
            bool csharp2cuda_temp_7;
#line 1283 "WindowModule.cs"
            if (!(((((void*)(csharp2cuda_temp_6))) == (((void*)(nullptr))))))
            {
#line 1283 "WindowModule.cs"
                MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 1283 "WindowModule.cs"
                bool csharp2cuda_temp_9 = (csharp2cuda_temp_8)->valid;
#line 1283 "WindowModule.cs"
                csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
            }
            else
            {
#line 1283 "WindowModule.cs"
                csharp2cuda_temp_7 = true;
            }
            if (csharp2cuda_temp_7)
            {
#line 1284 "WindowModule.cs"
#line 1284 "WindowModule.cs"
                bool* csharp2cuda_temp_10 = &(valid);
                (*(csharp2cuda_temp_10) = false);
            }
#line 1282 "WindowModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 1285 "WindowModule.cs"
    if ((!(valid)))
#line 1286 "WindowModule.cs"
    {
#line 1287 "WindowModule.cs"
        mathblocks_window_publish(output, false, 0, thread);
#line 1288 "WindowModule.cs"
        return;
    }
#line 1291 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_11;
#line 1291 "WindowModule.cs"
    if (((input_count) > (0)))
    {
#line 1291 "WindowModule.cs"
        csharp2cuda_temp_11 = (inputs)[0];
    }
    else
    {
#line 1291 "WindowModule.cs"
        csharp2cuda_temp_11 = ((MathBlockSlot*)(nullptr));
    }
#line 1291 "WindowModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_11;
#line 1292 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_12;
#line 1292 "WindowModule.cs"
    if (((series) > (1)))
    {
#line 1292 "WindowModule.cs"
        csharp2cuda_temp_12 = (inputs)[1];
    }
    else
    {
#line 1292 "WindowModule.cs"
        csharp2cuda_temp_12 = ((MathBlockSlot*)(nullptr));
    }
#line 1292 "WindowModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_12;
#line 1293 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_13;
#line 1293 "WindowModule.cs"
    if (((arity) > (series)))
    {
#line 1293 "WindowModule.cs"
        csharp2cuda_temp_13 = (inputs)[series];
    }
    else
    {
#line 1293 "WindowModule.cs"
        csharp2cuda_temp_13 = ((MathBlockSlot*)(nullptr));
    }
#line 1293 "WindowModule.cs"
    const MathBlockSlot* first_parameter = csharp2cuda_temp_13;
#line 1294 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_14;
#line 1294 "WindowModule.cs"
    if (((arity) > (csharp2cuda_i32_add(series, 1))))
    {
#line 1294 "WindowModule.cs"
        csharp2cuda_temp_14 = (inputs)[csharp2cuda_i32_add(series, 1)];
    }
    else
    {
#line 1294 "WindowModule.cs"
        csharp2cuda_temp_14 = ((MathBlockSlot*)(nullptr));
    }
#line 1294 "WindowModule.cs"
    const MathBlockSlot* second_parameter = csharp2cuda_temp_14;
#line 1295 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_15 = (inputs)[arity];
#line 1295 "WindowModule.cs"
    const MathBlockSlot* width_input = csharp2cuda_temp_15;
#line 1296 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_16;
#line 1296 "WindowModule.cs"
    if (sibling)
    {
#line 1296 "WindowModule.cs"
        csharp2cuda_temp_16 = ((MathBlockSlot*)(nullptr));
    }
    else
    {
#line 1296 "WindowModule.cs"
        csharp2cuda_temp_16 = (inputs)[csharp2cuda_i32_add(arity, 1)];
    }
#line 1296 "WindowModule.cs"
    const MathBlockSlot* fill_input = csharp2cuda_temp_16;
#line 1297 "WindowModule.cs"
    int count = (first)->count;
#line 1298 "WindowModule.cs"
    int width = 0;
#line 1299 "WindowModule.cs"
#line 1299 "WindowModule.cs"
    bool csharp2cuda_temp_17;
#line 1299 "WindowModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 1299 "WindowModule.cs"
        int csharp2cuda_temp_18 = (second)->count;
#line 1299 "WindowModule.cs"
        csharp2cuda_temp_17 = ((csharp2cuda_temp_18) != (count));
    }
    else
    {
#line 1299 "WindowModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
    {
#line 1300 "WindowModule.cs"
#line 1300 "WindowModule.cs"
        bool* csharp2cuda_temp_19 = &(valid);
        (*(csharp2cuda_temp_19) = false);
    }
#line 1301 "WindowModule.cs"
#line 1301 "WindowModule.cs"
    double csharp2cuda_temp_20 = (width_input)->scalar_value;
#line 1301 "WindowModule.cs"
    int* csharp2cuda_temp_21 = &(width);
#line 1301 "WindowModule.cs"
    bool csharp2cuda_temp_22 = mathblocks_sequence_positive_integer(csharp2cuda_temp_20, csharp2cuda_temp_21);
#line 1301 "WindowModule.cs"
    bool csharp2cuda_temp_23;
#line 1301 "WindowModule.cs"
    if (!((!(csharp2cuda_temp_22))))
    {
#line 1301 "WindowModule.cs"
        csharp2cuda_temp_23 = ((width) > (count));
    }
    else
    {
#line 1301 "WindowModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
    {
#line 1302 "WindowModule.cs"
#line 1302 "WindowModule.cs"
        bool* csharp2cuda_temp_24 = &(valid);
        (*(csharp2cuda_temp_24) = false);
    }
#line 1303 "WindowModule.cs"
#line 1303 "WindowModule.cs"
    int csharp2cuda_temp_25 = (output)->capacity;
    if (((count) > (csharp2cuda_temp_25)))
    {
#line 1304 "WindowModule.cs"
#line 1304 "WindowModule.cs"
        bool* csharp2cuda_temp_26 = &(valid);
        (*(csharp2cuda_temp_26) = false);
    }
#line 1305 "WindowModule.cs"
    long long csharp2cuda_temp_27;
#line 1305 "WindowModule.cs"
    if (valid)
    {
#line 1305 "WindowModule.cs"
        csharp2cuda_temp_27 = mathblocks_window_scratch_count(source, width);
    }
    else
    {
#line 1305 "WindowModule.cs"
        csharp2cuda_temp_27 = ((long long)(0));
    }
#line 1305 "WindowModule.cs"
    long long required = csharp2cuda_temp_27;
#line 1306 "WindowModule.cs"
    long long csharp2cuda_temp_28;
#line 1306 "WindowModule.cs"
    if (((scratch_capacity) < (0)))
    {
#line 1306 "WindowModule.cs"
        csharp2cuda_temp_28 = required;
    }
    else
    {
#line 1306 "WindowModule.cs"
        csharp2cuda_temp_28 = ((long long)(scratch_capacity));
    }
#line 1306 "WindowModule.cs"
    long long capacity = csharp2cuda_temp_28;
#line 1307 "WindowModule.cs"
#line 1307 "WindowModule.cs"
    bool csharp2cuda_temp_29;
#line 1307 "WindowModule.cs"
    if (!(((required) > (capacity))))
    {
#line 1307 "WindowModule.cs"
        bool csharp2cuda_temp_30;
#line 1307 "WindowModule.cs"
        if (((required) > (((long long)(0)))))
        {
#line 1307 "WindowModule.cs"
            unsigned long long csharp2cuda_temp_31 = (output)->scratch_pointer;
#line 1307 "WindowModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) == (((unsigned long long)(0))));
        }
        else
        {
#line 1307 "WindowModule.cs"
            csharp2cuda_temp_30 = false;
        }
#line 1307 "WindowModule.cs"
        csharp2cuda_temp_29 = csharp2cuda_temp_30;
    }
    else
    {
#line 1307 "WindowModule.cs"
        csharp2cuda_temp_29 = true;
    }
    if (csharp2cuda_temp_29)
    {
#line 1308 "WindowModule.cs"
#line 1308 "WindowModule.cs"
        bool* csharp2cuda_temp_32 = &(valid);
        (*(csharp2cuda_temp_32) = false);
    }
#line 1309 "WindowModule.cs"
    mathblocks_window_publish(output, valid, count, thread);
#line 1310 "WindowModule.cs"
    if ((!(valid)))
    {
#line 1311 "WindowModule.cs"
        return;
    }
#line 1313 "WindowModule.cs"
    double csharp2cuda_temp_33;
#line 1313 "WindowModule.cs"
    if (sibling)
    {
#line 1313 "WindowModule.cs"
        csharp2cuda_temp_33 = 0.0;
    }
    else
    {
#line 1313 "WindowModule.cs"
        csharp2cuda_temp_33 = (fill_input)->scalar_value;
    }
#line 1313 "WindowModule.cs"
    double fill = csharp2cuda_temp_33;
#line 1314 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_34 = (first)->data_pointer;
#line 1314 "WindowModule.cs"
    const double* a = ((double*)(csharp2cuda_temp_34));
#line 1315 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_35 = (first)->data_pointer;
#line 1315 "WindowModule.cs"
    const int* flags = ((int*)(csharp2cuda_temp_35));
#line 1316 "WindowModule.cs"
    double* csharp2cuda_temp_36;
#line 1316 "WindowModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 1316 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(nullptr));
    }
    else
    {
#line 1316 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_37 = (second)->data_pointer;
#line 1316 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(csharp2cuda_temp_37));
    }
#line 1316 "WindowModule.cs"
    const double* b = csharp2cuda_temp_36;
#line 1317 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_38 = (output)->data_pointer;
#line 1317 "WindowModule.cs"
    double* result = ((double*)(csharp2cuda_temp_38));
#line 1318 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_39 = (output)->data_pointer;
#line 1318 "WindowModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_39));
#line 1319 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_40 = (output)->scratch_pointer;
#line 1319 "WindowModule.cs"
    double* scratch = csharp2cuda_pointer_add(((double*)(csharp2cuda_temp_40)), csharp2cuda_i32_mul(thread, csharp2cuda_i32_from_bits(capacity)));
#line 1320 "WindowModule.cs"
#line 1320 "WindowModule.cs"
    bool csharp2cuda_temp_41;
#line 1320 "WindowModule.cs"
    if (!(((source) == (47))))
    {
#line 1320 "WindowModule.cs"
        csharp2cuda_temp_41 = ((source) == (48));
    }
    else
    {
#line 1320 "WindowModule.cs"
        csharp2cuda_temp_41 = true;
    }
#line 1320 "WindowModule.cs"
    bool csharp2cuda_temp_42;
#line 1320 "WindowModule.cs"
    if (!(csharp2cuda_temp_41))
    {
#line 1320 "WindowModule.cs"
        csharp2cuda_temp_42 = ((source) >= (53));
    }
    else
    {
#line 1320 "WindowModule.cs"
        csharp2cuda_temp_42 = true;
    }
    if (csharp2cuda_temp_42)
#line 1321 "WindowModule.cs"
    {
#line 1323 "WindowModule.cs"
        long long rows_per_thread = csharp2cuda_i64_div(csharp2cuda_i64_sub(csharp2cuda_i64_add(((long long)(count)), ((long long)(threads))), ((long long)(1))), ((long long)(threads)));
#line 1324 "WindowModule.cs"
        long long first_row = csharp2cuda_i64_mul(((long long)(thread)), rows_per_thread);
#line 1325 "WindowModule.cs"
        if (((first_row) >= (((long long)(count)))))
        {
#line 1326 "WindowModule.cs"
            return;
        }
#line 1327 "WindowModule.cs"
        long long csharp2cuda_temp_43;
#line 1327 "WindowModule.cs"
        if (((csharp2cuda_i64_sub(((long long)(count)), first_row)) < (rows_per_thread)))
        {
#line 1327 "WindowModule.cs"
            csharp2cuda_temp_43 = ((long long)(count));
        }
        else
        {
#line 1327 "WindowModule.cs"
            csharp2cuda_temp_43 = csharp2cuda_i64_add(first_row, rows_per_thread);
        }
#line 1327 "WindowModule.cs"
        long long last_row = csharp2cuda_temp_43;
#line 1328 "WindowModule.cs"
        if (((source) >= (53)))
#line 1329 "WindowModule.cs"
        {
#line 1330 "WindowModule.cs"
            mathblocks_window_accurate_rows(source, a, width, csharp2cuda_i32_from_bits(first_row), csharp2cuda_i32_from_bits(last_row), fill, sibling, result, boolean_result, ((long long*)(scratch)));
        }
        else
#line 1343 "WindowModule.cs"
        {
#line 1344 "WindowModule.cs"
#line 1347 "WindowModule.cs"
            double csharp2cuda_temp_44;
#line 1347 "WindowModule.cs"
            if (((source) == (47)))
            {
#line 1347 "WindowModule.cs"
                csharp2cuda_temp_44 = 0.5;
            }
            else
            {
#line 1347 "WindowModule.cs"
                csharp2cuda_temp_44 = (first_parameter)->scalar_value;
            }
            mathblocks_window_sorted_rows(a, width, csharp2cuda_temp_44, csharp2cuda_i32_from_bits(first_row), csharp2cuda_i32_from_bits(last_row), fill, sibling, result, boolean_result, scratch);
        }
#line 1356 "WindowModule.cs"
        return;
    }
#line 1358 "WindowModule.cs"
    {
#line 1358 "WindowModule.cs"
        int end = thread;
        while (true)
        {
            if (!(((end) < (count))))
                break;
#line 1359 "WindowModule.cs"
            {
#line 1360 "WindowModule.cs"
                bool row_valid = false;
#line 1361 "WindowModule.cs"
                double value = 0.0;
#line 1362 "WindowModule.cs"
                if (((end) >= (csharp2cuda_i32_sub(width, 1))))
#line 1363 "WindowModule.cs"
                {
#line 1365 "WindowModule.cs"
                    int start = csharp2cuda_i32_add(csharp2cuda_i32_sub(end, width), 1);
#line 1366 "WindowModule.cs"
#line 1366 "WindowModule.cs"
                    bool* csharp2cuda_temp_47 = &(row_valid);
#line 1375 "WindowModule.cs"
                    double* csharp2cuda_temp_48 = &(value);
#line 1366 "WindowModule.cs"
                    bool csharp2cuda_temp_49 = mathblocks_window_value(source, csharp2cuda_pointer_add(a, start), csharp2cuda_pointer_add(b, start), csharp2cuda_pointer_add(flags, start), width, first_parameter, second_parameter, scratch, csharp2cuda_temp_48);
                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_49);
                }
#line 1377 "WindowModule.cs"
                if (sibling)
                {
#line 1378 "WindowModule.cs"
#line 1378 "WindowModule.cs"
                    int* csharp2cuda_temp_50 = &((boolean_result)[end]);
                    (*(csharp2cuda_temp_50) = row_valid);
                }
                else
                {
#line 1380 "WindowModule.cs"
#line 1380 "WindowModule.cs"
                    double* csharp2cuda_temp_51 = &((result)[end]);
#line 1380 "WindowModule.cs"
                    double csharp2cuda_temp_52;
#line 1380 "WindowModule.cs"
                    if (row_valid)
                    {
#line 1380 "WindowModule.cs"
                        csharp2cuda_temp_52 = value;
                    }
                    else
                    {
#line 1380 "WindowModule.cs"
                        csharp2cuda_temp_52 = fill;
                    }
                    (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
                }
            }
#line 1358 "WindowModule.cs"
            int* csharp2cuda_temp_45 = &(end);
#line 1358 "WindowModule.cs"
            int csharp2cuda_temp_46 = *(csharp2cuda_temp_45);
            (*(csharp2cuda_temp_45) = csharp2cuda_i32_add(csharp2cuda_temp_46, threads));
        }
    }
}

#line 206 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width)
#line 208 "WindowModule.cs"
{
#line 209 "WindowModule.cs"
    long long count = ((long long)(width));
#line 210 "WindowModule.cs"
    switch (source)
    {
#line 212 "WindowModule.cs"
        case 44:
        case 47:
        case 48:
#line 215 "WindowModule.cs"
            return count;
#line 216 "WindowModule.cs"
        case 2:
        case 3:
        case 8:
        case 21:
#line 220 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, ((long long)(2)));
#line 221 "WindowModule.cs"
        case 22:
#line 222 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_sub(count, ((long long)(1))));
#line 223 "WindowModule.cs"
        case 15:
#line 224 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_add(count, ((long long)(1))));
#line 225 "WindowModule.cs"
        case 53:
        case 54:
#line 227 "WindowModule.cs"
            return ((long long)(285));
#line 228 "WindowModule.cs"
        case 55:
        case 56:
        case 57:
        case 58:
#line 232 "WindowModule.cs"
            return ((long long)(570));
#line 233 "WindowModule.cs"
        default:
#line 234 "WindowModule.cs"
            return ((long long)(0));
    }
}

#line 421 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count)
#line 423 "WindowModule.cs"
{
#line 424 "WindowModule.cs"
    double* sorted = mathblocks_stable_merge_sort(scratch, csharp2cuda_pointer_add(scratch, count), count, false);
#line 425 "WindowModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 181 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source)
#line 183 "WindowModule.cs"
{
#line 184 "WindowModule.cs"
    switch (source)
    {
#line 186 "WindowModule.cs"
        case 2:
        case 4:
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
        case 21:
        case 22:
        case 23:
        case 24:
#line 198 "WindowModule.cs"
            return 2;
#line 199 "WindowModule.cs"
        default:
#line 200 "WindowModule.cs"
            return 1;
    }
}

#line 340 "WindowModule.cs"
__device__ double mathblocks_window_sorted_rank(const double* sorted, int count, double value)
#line 342 "WindowModule.cs"
{
#line 343 "WindowModule.cs"
    int low = 0;
#line 344 "WindowModule.cs"
    int high = count;
#line 345 "WindowModule.cs"
    while (true)
    {
        if (!(((low) < (high))))
            break;
#line 346 "WindowModule.cs"
        {
#line 347 "WindowModule.cs"
            int csharp2cuda_temp_0 = csharp2cuda_i32_div(csharp2cuda_i32_sub(high, low), 2);
#line 347 "WindowModule.cs"
            int middle = csharp2cuda_i32_add(low, csharp2cuda_temp_0);
#line 348 "WindowModule.cs"
#line 348 "WindowModule.cs"
            double csharp2cuda_temp_1 = (sorted)[middle];
            if (((csharp2cuda_temp_1) < (value)))
            {
#line 349 "WindowModule.cs"
#line 349 "WindowModule.cs"
                int* csharp2cuda_temp_2 = &(low);
                (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(middle, 1));
            }
            else
            {
#line 351 "WindowModule.cs"
#line 351 "WindowModule.cs"
                int* csharp2cuda_temp_3 = &(high);
                (*(csharp2cuda_temp_3) = middle);
            }
        }
    }
#line 353 "WindowModule.cs"
    int lower = low;
#line 354 "WindowModule.cs"
#line 354 "WindowModule.cs"
    int* csharp2cuda_temp_4 = &(high);
    (*(csharp2cuda_temp_4) = count);
#line 355 "WindowModule.cs"
    while (true)
    {
        if (!(((low) < (high))))
            break;
#line 356 "WindowModule.cs"
        {
#line 357 "WindowModule.cs"
            int csharp2cuda_temp_5 = csharp2cuda_i32_div(csharp2cuda_i32_sub(high, low), 2);
#line 357 "WindowModule.cs"
            int middle = csharp2cuda_i32_add(low, csharp2cuda_temp_5);
#line 358 "WindowModule.cs"
#line 358 "WindowModule.cs"
            double csharp2cuda_temp_6 = (sorted)[middle];
            if (((csharp2cuda_temp_6) > (value)))
            {
#line 359 "WindowModule.cs"
#line 359 "WindowModule.cs"
                int* csharp2cuda_temp_7 = &(high);
                (*(csharp2cuda_temp_7) = middle);
            }
            else
            {
#line 361 "WindowModule.cs"
#line 361 "WindowModule.cs"
                int* csharp2cuda_temp_8 = &(low);
                (*(csharp2cuda_temp_8) = csharp2cuda_i32_add(middle, 1));
            }
        }
    }
#line 363 "WindowModule.cs"
    int equal = csharp2cuda_i32_sub(low, lower);
#line 364 "WindowModule.cs"
#line 364 "WindowModule.cs"
    double csharp2cuda_temp_9 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
    return __dadd_rn(((double)(lower)), csharp2cuda_temp_9);
}

#line 1190 "WindowModule.cs"
__device__ void mathblocks_window_sorted_rows(
    const double* x,
    int width,
    double probability,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    double* sorted)
#line 1202 "WindowModule.cs"
{
#line 1203 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 1203 "WindowModule.cs"
    if (!(((probability) < (0.0))))
    {
#line 1203 "WindowModule.cs"
        csharp2cuda_temp_0 = ((probability) > (1.0));
    }
    else
    {
#line 1203 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 1203 "WindowModule.cs"
    bool probability_valid = (!(csharp2cuda_temp_0));
#line 1204 "WindowModule.cs"
    int csharp2cuda_temp_1;
#line 1204 "WindowModule.cs"
    if (((csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1)) < (0)))
    {
#line 1204 "WindowModule.cs"
        csharp2cuda_temp_1 = 0;
    }
    else
    {
#line 1204 "WindowModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1);
    }
#line 1204 "WindowModule.cs"
    int begin = csharp2cuda_temp_1;
#line 1205 "WindowModule.cs"
    int size = 0;
#line 1206 "WindowModule.cs"
    {
#line 1206 "WindowModule.cs"
        int row = begin;
        while (true)
        {
            if (!(((row) < (last_row))))
                break;
#line 1207 "WindowModule.cs"
            {
#line 1208 "WindowModule.cs"
                if (((csharp2cuda_i32_sub(row, width)) >= (begin)))
#line 1209 "WindowModule.cs"
                {
#line 1210 "WindowModule.cs"
                    double leaving = (x)[csharp2cuda_i32_sub(row, width)];
#line 1211 "WindowModule.cs"
                    int low = 0;
#line 1212 "WindowModule.cs"
                    int high = size;
#line 1213 "WindowModule.cs"
                    while (true)
                    {
                        if (!(((low) < (high))))
                            break;
#line 1214 "WindowModule.cs"
                        {
#line 1215 "WindowModule.cs"
                            int middle = csharp2cuda_i32_div(csharp2cuda_i32_add(low, high), 2);
#line 1216 "WindowModule.cs"
#line 1216 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (sorted)[middle];
                            if (((csharp2cuda_temp_3) < (leaving)))
                            {
#line 1217 "WindowModule.cs"
#line 1217 "WindowModule.cs"
                                int* csharp2cuda_temp_4 = &(low);
                                (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(middle, 1));
                            }
                            else
                            {
#line 1219 "WindowModule.cs"
#line 1219 "WindowModule.cs"
                                int* csharp2cuda_temp_5 = &(high);
                                (*(csharp2cuda_temp_5) = middle);
                            }
                        }
                    }
#line 1221 "WindowModule.cs"
                    {
#line 1221 "WindowModule.cs"
                        int index = low;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_sub(size, 1)))))
                                break;
#line 1222 "WindowModule.cs"
#line 1222 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &((sorted)[index]);
#line 1222 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (sorted)[csharp2cuda_i32_add(index, 1)];
                            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 1221 "WindowModule.cs"
                            int* csharp2cuda_temp_6 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
                        }
                    }
#line 1223 "WindowModule.cs"
#line 1223 "WindowModule.cs"
                    int* csharp2cuda_temp_9 = &(size);
                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_9));
                }
#line 1225 "WindowModule.cs"
                double entering = (x)[row];
#line 1226 "WindowModule.cs"
                int position = size;
#line 1227 "WindowModule.cs"
                while (true)
                {
#line 1227 "WindowModule.cs"
                    bool csharp2cuda_temp_10;
#line 1227 "WindowModule.cs"
                    if (((position) > (0)))
                    {
#line 1227 "WindowModule.cs"
                        double csharp2cuda_temp_11 = (sorted)[csharp2cuda_i32_sub(position, 1)];
#line 1227 "WindowModule.cs"
                        csharp2cuda_temp_10 = ((csharp2cuda_temp_11) > (entering));
                    }
                    else
                    {
#line 1227 "WindowModule.cs"
                        csharp2cuda_temp_10 = false;
                    }
                    if (!(csharp2cuda_temp_10))
                        break;
#line 1228 "WindowModule.cs"
                    {
#line 1229 "WindowModule.cs"
#line 1229 "WindowModule.cs"
                        double* csharp2cuda_temp_12 = &((sorted)[position]);
#line 1229 "WindowModule.cs"
                        double csharp2cuda_temp_13 = (sorted)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 1230 "WindowModule.cs"
#line 1230 "WindowModule.cs"
                        int* csharp2cuda_temp_14 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_14));
                    }
                }
#line 1232 "WindowModule.cs"
#line 1232 "WindowModule.cs"
                double* csharp2cuda_temp_15 = &((sorted)[position]);
                (*(csharp2cuda_temp_15) = entering);
#line 1233 "WindowModule.cs"
#line 1233 "WindowModule.cs"
                int* csharp2cuda_temp_16 = &(size);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
#line 1234 "WindowModule.cs"
                if (((row) < (first_row)))
                {
#line 1235 "WindowModule.cs"
                    goto csharp2cuda_for_continue_1;
                }
#line 1236 "WindowModule.cs"
                bool computed = false;
#line 1237 "WindowModule.cs"
                double value = 0.0;
#line 1238 "WindowModule.cs"
#line 1238 "WindowModule.cs"
                bool csharp2cuda_temp_17;
#line 1238 "WindowModule.cs"
                if (((row) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 1238 "WindowModule.cs"
                    csharp2cuda_temp_17 = probability_valid;
                }
                else
                {
#line 1238 "WindowModule.cs"
                    csharp2cuda_temp_17 = false;
                }
                if (csharp2cuda_temp_17)
#line 1239 "WindowModule.cs"
                {
#line 1240 "WindowModule.cs"
#line 1240 "WindowModule.cs"
                    double* csharp2cuda_temp_18 = &(value);
                    (*(csharp2cuda_temp_18) = mathblocks_statistics_sorted_quantile(sorted, width, probability));
#line 1241 "WindowModule.cs"
#line 1241 "WindowModule.cs"
                    bool* csharp2cuda_temp_19 = &(computed);
                    (*(csharp2cuda_temp_19) = isfinite(value));
                }
#line 1243 "WindowModule.cs"
                if (sibling)
                {
#line 1244 "WindowModule.cs"
#line 1244 "WindowModule.cs"
                    int* csharp2cuda_temp_20 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_20) = computed);
                }
                else
                {
#line 1246 "WindowModule.cs"
#line 1246 "WindowModule.cs"
                    double* csharp2cuda_temp_21 = &((result)[row]);
#line 1246 "WindowModule.cs"
                    double csharp2cuda_temp_22;
#line 1246 "WindowModule.cs"
                    if (computed)
                    {
#line 1246 "WindowModule.cs"
                        csharp2cuda_temp_22 = value;
                    }
                    else
                    {
#line 1246 "WindowModule.cs"
                        csharp2cuda_temp_22 = fill;
                    }
                    (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
                }
            }
            csharp2cuda_for_continue_1:
#line 1206 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
}

#line 148 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source)
#line 150 "WindowModule.cs"
{
#line 151 "WindowModule.cs"
    switch (source)
    {
#line 153 "WindowModule.cs"
        case 34:
#line 154 "WindowModule.cs"
            return 3;
#line 155 "WindowModule.cs"
        case 0:
        case 1:
        case 2:
        case 4:
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 16:
        case 18:
        case 21:
        case 22:
        case 23:
        case 24:
        case 28:
        case 30:
        case 36:
        case 37:
        case 48:
#line 175 "WindowModule.cs"
            return 2;
#line 176 "WindowModule.cs"
        default:
#line 177 "WindowModule.cs"
            return 1;
    }
}

#line 803 "WindowModule.cs"
__device__ void mathblocks_window_split(double a, double* high, double* low)
#line 805 "WindowModule.cs"
{
#line 806 "WindowModule.cs"
    double c = __dmul_rn(134217729.0, a);
#line 807 "WindowModule.cs"
#line 807 "WindowModule.cs"
    double* csharp2cuda_temp_0 = high;
    (*(csharp2cuda_temp_0) = __dsub_rn(c, __dsub_rn(c, a)));
#line 808 "WindowModule.cs"
#line 808 "WindowModule.cs"
    double* csharp2cuda_temp_1 = low;
#line 808 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(high);
    (*(csharp2cuda_temp_1) = __dsub_rn(a, csharp2cuda_temp_2));
}

#line 1026 "WindowModule.cs"
__device__ void mathblocks_window_square(double h, double l, double* sh, double* sl)
#line 1028 "WindowModule.cs"
{
#line 1029 "WindowModule.cs"
    double p = 0.0;
#line 1030 "WindowModule.cs"
    double e = 0.0;
#line 1031 "WindowModule.cs"
#line 1031 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(p);
#line 1031 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(e);
    mathblocks_window_two_product(h, h, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 1032 "WindowModule.cs"
    double low = __dadd_rn(e, __dmul_rn(__dadd_rn(h, h), l));
#line 1033 "WindowModule.cs"
    mathblocks_window_fast_two_sum(p, low, sh, sl);
}

#line 430 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value)
#line 435 "WindowModule.cs"
{
#line 436 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 437 "WindowModule.cs"
        return false;
    }
#line 438 "WindowModule.cs"
    double mean = 0.0;
#line 439 "WindowModule.cs"
    double deviation = 0.0;
#line 440 "WindowModule.cs"
#line 440 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(mean);
#line 440 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(deviation);
    mathblocks_vector_standardize_moments(values, count, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 441 "WindowModule.cs"
    {
#line 441 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 442 "WindowModule.cs"
#line 442 "WindowModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
#line 442 "WindowModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_3, mean), deviation);
            if ((!(isfinite(csharp2cuda_temp_4))))
            {
#line 443 "WindowModule.cs"
                return false;
            }
#line 441 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 444 "WindowModule.cs"
#line 444 "WindowModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 444 "WindowModule.cs"
    double csharp2cuda_temp_6 = (values)[csharp2cuda_i32_sub(count, 1)];
#line 444 "WindowModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_6, mean), deviation);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_7);
#line 445 "WindowModule.cs"
    return true;
}

#line 1050 "WindowModule.cs"
__device__ double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl)
#line 1052 "WindowModule.cs"
{
#line 1053 "WindowModule.cs"
    double sh = 0.0;
#line 1054 "WindowModule.cs"
    double sl = 0.0;
#line 1055 "WindowModule.cs"
    double th = 0.0;
#line 1056 "WindowModule.cs"
    double tl = 0.0;
#line 1057 "WindowModule.cs"
#line 1057 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(sh);
#line 1057 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(sl);
    mathblocks_window_two_sum(ah, (-(bh)), csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 1058 "WindowModule.cs"
#line 1058 "WindowModule.cs"
    double* csharp2cuda_temp_2 = &(th);
#line 1058 "WindowModule.cs"
    double* csharp2cuda_temp_3 = &(tl);
    mathblocks_window_two_sum(al, (-(bl)), csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 1059 "WindowModule.cs"
    double c = __dadd_rn(sl, th);
#line 1060 "WindowModule.cs"
    double vh = 0.0;
#line 1061 "WindowModule.cs"
    double vl = 0.0;
#line 1062 "WindowModule.cs"
#line 1062 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(vh);
#line 1062 "WindowModule.cs"
    double* csharp2cuda_temp_5 = &(vl);
    mathblocks_window_fast_two_sum(sh, c, csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 1063 "WindowModule.cs"
    double w = __dadd_rn(tl, vl);
#line 1064 "WindowModule.cs"
    double zh = 0.0;
#line 1065 "WindowModule.cs"
    double zl = 0.0;
#line 1066 "WindowModule.cs"
#line 1066 "WindowModule.cs"
    double* csharp2cuda_temp_6 = &(zh);
#line 1066 "WindowModule.cs"
    double* csharp2cuda_temp_7 = &(zl);
    mathblocks_window_fast_two_sum(vh, w, csharp2cuda_temp_6, csharp2cuda_temp_7);
#line 1067 "WindowModule.cs"
    return zh;
}

#line 812 "WindowModule.cs"
__device__ void mathblocks_window_two_product(double a, double b, double* p, double* e)
#line 814 "WindowModule.cs"
{
#line 815 "WindowModule.cs"
#line 815 "WindowModule.cs"
    double* csharp2cuda_temp_0 = p;
    (*(csharp2cuda_temp_0) = __dmul_rn(a, b));
#line 816 "WindowModule.cs"
    double ah = 0.0;
#line 817 "WindowModule.cs"
    double al = 0.0;
#line 818 "WindowModule.cs"
    double bh = 0.0;
#line 819 "WindowModule.cs"
    double bl = 0.0;
#line 820 "WindowModule.cs"
#line 820 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(ah);
#line 820 "WindowModule.cs"
    double* csharp2cuda_temp_2 = &(al);
    mathblocks_window_split(a, csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 821 "WindowModule.cs"
#line 821 "WindowModule.cs"
    double* csharp2cuda_temp_3 = &(bh);
#line 821 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(bl);
    mathblocks_window_split(b, csharp2cuda_temp_3, csharp2cuda_temp_4);
#line 822 "WindowModule.cs"
#line 822 "WindowModule.cs"
    double* csharp2cuda_temp_5 = e;
#line 822 "WindowModule.cs"
    double csharp2cuda_temp_6 = *(p);
    (*(csharp2cuda_temp_5) = __dadd_rn(__dadd_rn(__dadd_rn(__dsub_rn(__dmul_rn(ah, bh), csharp2cuda_temp_6), __dmul_rn(ah, bl)), __dmul_rn(al, bh)), __dmul_rn(al, bl)));
}

#line 1009 "WindowModule.cs"
__device__ void mathblocks_window_two_sum(double a, double b, double* s, double* e)
#line 1011 "WindowModule.cs"
{
#line 1012 "WindowModule.cs"
#line 1012 "WindowModule.cs"
    double* csharp2cuda_temp_0 = s;
    (*(csharp2cuda_temp_0) = __dadd_rn(a, b));
#line 1013 "WindowModule.cs"
    double csharp2cuda_temp_1 = *(s);
#line 1013 "WindowModule.cs"
    double b_virtual = __dsub_rn(csharp2cuda_temp_1, a);
#line 1014 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(s);
#line 1014 "WindowModule.cs"
    double a_virtual = __dsub_rn(csharp2cuda_temp_2, b_virtual);
#line 1015 "WindowModule.cs"
#line 1015 "WindowModule.cs"
    double* csharp2cuda_temp_3 = e;
    (*(csharp2cuda_temp_3) = __dadd_rn(__dsub_rn(a, a_virtual), __dsub_rn(b, b_virtual)));
}

#line 452 "WindowModule.cs"
__device__ bool mathblocks_window_value(
    int source,
    const double* a,
    const double* b,
    const int* flags,
    int count,
    const MathBlockSlot* first_parameter,
    const MathBlockSlot* second_parameter,
    double* scratch,
    double* value)
#line 463 "WindowModule.cs"
{
#line 464 "WindowModule.cs"
    switch (source)
    {
#line 466 "WindowModule.cs"
        case 0:
#line 467 "WindowModule.cs"
            {
#line 468 "WindowModule.cs"
                int lag = 0;
#line 469 "WindowModule.cs"
#line 469 "WindowModule.cs"
                double csharp2cuda_temp_0 = (first_parameter)->scalar_value;
#line 469 "WindowModule.cs"
                int* csharp2cuda_temp_1 = &(lag);
#line 469 "WindowModule.cs"
                bool csharp2cuda_temp_2 = mathblocks_sequence_positive_integer(csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 469 "WindowModule.cs"
                bool csharp2cuda_temp_3;
#line 469 "WindowModule.cs"
                if (!((!(csharp2cuda_temp_2))))
                {
#line 469 "WindowModule.cs"
                    csharp2cuda_temp_3 = ((lag) >= (count));
                }
                else
                {
#line 469 "WindowModule.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 470 "WindowModule.cs"
                    return false;
                }
#line 471 "WindowModule.cs"
#line 471 "WindowModule.cs"
                double* csharp2cuda_temp_4 = value;
                (*(csharp2cuda_temp_4) = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), csharp2cuda_i32_sub(count, lag)));
#line 472 "WindowModule.cs"
                break;
            }
#line 474 "WindowModule.cs"
        case 1:
        case 16:
#line 476 "WindowModule.cs"
#line 476 "WindowModule.cs"
            double csharp2cuda_temp_5 = (first_parameter)->scalar_value;
            return mathblocks_statistics_moment_value(a, count, csharp2cuda_temp_5, ((source) == (1)), value);
#line 477 "WindowModule.cs"
        case 2:
#line 478 "WindowModule.cs"
            return mathblocks_window_distance_correlation(a, b, count, scratch, value);
#line 479 "WindowModule.cs"
        case 3:
#line 480 "WindowModule.cs"
#line 480 "WindowModule.cs"
            bool csharp2cuda_temp_6;
#line 480 "WindowModule.cs"
            if (!(((count) <= (0))))
            {
#line 480 "WindowModule.cs"
                csharp2cuda_temp_6 = ((((void*)(scratch))) == (((void*)(nullptr))));
            }
            else
            {
#line 480 "WindowModule.cs"
                csharp2cuda_temp_6 = true;
            }
            if (csharp2cuda_temp_6)
            {
#line 481 "WindowModule.cs"
                return false;
            }
#line 482 "WindowModule.cs"
            mathblocks_statistics_sort_copy(a, count, scratch, false);
#line 483 "WindowModule.cs"
#line 483 "WindowModule.cs"
            double* csharp2cuda_temp_7 = value;
            (*(csharp2cuda_temp_7) = __dsub_rn(mathblocks_statistics_sorted_quantile(scratch, count, 0.75), mathblocks_statistics_sorted_quantile(scratch, count, 0.25)));
#line 486 "WindowModule.cs"
            break;
#line 487 "WindowModule.cs"
        case 4:
#line 488 "WindowModule.cs"
            return mathblocks_statistics_kendall_value(a, b, count, value);
#line 489 "WindowModule.cs"
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
#line 495 "WindowModule.cs"
            {
#line 496 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 497 "WindowModule.cs"
                    return false;
                }
#line 498 "WindowModule.cs"
                double covariance = mathblocks_statistics_population_covariance(a, b, count);
#line 499 "WindowModule.cs"
#line 499 "WindowModule.cs"
                bool csharp2cuda_temp_8;
#line 499 "WindowModule.cs"
                if (!(((source) == (10))))
                {
#line 499 "WindowModule.cs"
                    csharp2cuda_temp_8 = ((source) == (18));
                }
                else
                {
#line 499 "WindowModule.cs"
                    csharp2cuda_temp_8 = true;
                }
                if (csharp2cuda_temp_8)
#line 500 "WindowModule.cs"
                {
#line 501 "WindowModule.cs"
#line 501 "WindowModule.cs"
                    double* csharp2cuda_temp_9 = value;
#line 501 "WindowModule.cs"
                    double csharp2cuda_temp_10;
#line 501 "WindowModule.cs"
                    if (((source) == (10)))
                    {
#line 501 "WindowModule.cs"
                        csharp2cuda_temp_10 = covariance;
                    }
                    else
                    {
#line 501 "WindowModule.cs"
                        csharp2cuda_temp_10 = __ddiv_rn(__dmul_rn(covariance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    }
                    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
                }
                else
                {
#line 505 "WindowModule.cs"
                    if (((source) == (7)))
#line 506 "WindowModule.cs"
                    {
#line 507 "WindowModule.cs"
#line 507 "WindowModule.cs"
                        double* csharp2cuda_temp_11 = value;
                        (*(csharp2cuda_temp_11) = mathblocks_statistics_quotient_by_variance(covariance, mathblocks_statistics_population_variance(a, count)));
                    }
                    else
                    {
#line 510 "WindowModule.cs"
                        if (((source) == (5)))
#line 511 "WindowModule.cs"
                        {
#line 512 "WindowModule.cs"
                            double slope = mathblocks_statistics_quotient_by_variance(covariance, mathblocks_statistics_population_variance(a, count));
#line 514 "WindowModule.cs"
#line 514 "WindowModule.cs"
                            double* csharp2cuda_temp_12 = value;
                            (*(csharp2cuda_temp_12) = __dsub_rn(mathblocks_statistics_mean(b, count), __dmul_rn(slope, mathblocks_statistics_mean(a, count))));
                        }
                        else
#line 518 "WindowModule.cs"
                        {
#line 519 "WindowModule.cs"
                            double correlation = mathblocks_statistics_correlation_value(covariance, mathblocks_statistics_population_variance(a, count), mathblocks_statistics_population_variance(b, count));
#line 523 "WindowModule.cs"
#line 523 "WindowModule.cs"
                            double* csharp2cuda_temp_13 = value;
#line 523 "WindowModule.cs"
                            double csharp2cuda_temp_14;
#line 523 "WindowModule.cs"
                            if (((source) == (6)))
                            {
#line 523 "WindowModule.cs"
                                csharp2cuda_temp_14 = __dmul_rn(correlation, correlation);
                            }
                            else
                            {
#line 523 "WindowModule.cs"
                                csharp2cuda_temp_14 = correlation;
                            }
                            (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
                        }
                    }
                }
#line 525 "WindowModule.cs"
                break;
            }
#line 527 "WindowModule.cs"
        case 8:
#line 528 "WindowModule.cs"
            {
#line 529 "WindowModule.cs"
#line 529 "WindowModule.cs"
                bool csharp2cuda_temp_15;
#line 529 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 529 "WindowModule.cs"
                    csharp2cuda_temp_15 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 529 "WindowModule.cs"
                    csharp2cuda_temp_15 = true;
                }
                if (csharp2cuda_temp_15)
                {
#line 530 "WindowModule.cs"
                    return false;
                }
#line 531 "WindowModule.cs"
                double* sorted = scratch;
#line 532 "WindowModule.cs"
                double* deviations = csharp2cuda_pointer_add(scratch, count);
#line 533 "WindowModule.cs"
                mathblocks_statistics_sort_copy(a, count, sorted, false);
#line 534 "WindowModule.cs"
                double median = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
#line 535 "WindowModule.cs"
                {
#line 535 "WindowModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 536 "WindowModule.cs"
#line 536 "WindowModule.cs"
                        double* csharp2cuda_temp_17 = &((deviations)[index]);
#line 536 "WindowModule.cs"
                        double csharp2cuda_temp_18 = (a)[index];
                        (*(csharp2cuda_temp_17) = fabs(__dsub_rn(csharp2cuda_temp_18, median)));
#line 535 "WindowModule.cs"
                        int* csharp2cuda_temp_16 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                    }
                }
#line 537 "WindowModule.cs"
                mathblocks_statistics_sort_copy(deviations, count, sorted, false);
#line 538 "WindowModule.cs"
#line 538 "WindowModule.cs"
                double* csharp2cuda_temp_19 = value;
                (*(csharp2cuda_temp_19) = mathblocks_statistics_sorted_quantile(sorted, count, 0.5));
#line 539 "WindowModule.cs"
                break;
            }
#line 541 "WindowModule.cs"
        case 11:
        case 12:
#line 543 "WindowModule.cs"
            return mathblocks_statistics_shape_moment_value(a, count, ((source) == (11)), value);
#line 544 "WindowModule.cs"
        case 13:
        case 14:
        case 19:
        case 20:
#line 548 "WindowModule.cs"
            {
#line 549 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 550 "WindowModule.cs"
                    return false;
                }
#line 551 "WindowModule.cs"
                double variance = mathblocks_statistics_population_variance(a, count);
#line 552 "WindowModule.cs"
#line 552 "WindowModule.cs"
                bool csharp2cuda_temp_20;
#line 552 "WindowModule.cs"
                if (!(((source) == (19))))
                {
#line 552 "WindowModule.cs"
                    csharp2cuda_temp_20 = ((source) == (20));
                }
                else
                {
#line 552 "WindowModule.cs"
                    csharp2cuda_temp_20 = true;
                }
                if (csharp2cuda_temp_20)
                {
#line 553 "WindowModule.cs"
#line 553 "WindowModule.cs"
                    double* csharp2cuda_temp_21 = &(variance);
#line 553 "WindowModule.cs"
                    double csharp2cuda_temp_22 = __ddiv_rn(__dmul_rn(variance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
                }
#line 554 "WindowModule.cs"
#line 554 "WindowModule.cs"
                double* csharp2cuda_temp_23 = value;
#line 554 "WindowModule.cs"
                bool csharp2cuda_temp_24;
#line 554 "WindowModule.cs"
                if (!(((source) == (13))))
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_24 = ((source) == (19));
                }
                else
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_24 = true;
                }
#line 554 "WindowModule.cs"
                double csharp2cuda_temp_25;
#line 554 "WindowModule.cs"
                if (csharp2cuda_temp_24)
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_25 = mathblocks_square_root(variance);
                }
                else
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_25 = variance;
                }
                (*(csharp2cuda_temp_23) = csharp2cuda_temp_25);
#line 557 "WindowModule.cs"
                break;
            }
#line 559 "WindowModule.cs"
        case 15:
#line 560 "WindowModule.cs"
            {
#line 561 "WindowModule.cs"
#line 561 "WindowModule.cs"
                bool csharp2cuda_temp_26;
#line 561 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 561 "WindowModule.cs"
                    csharp2cuda_temp_26 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 561 "WindowModule.cs"
                    csharp2cuda_temp_26 = true;
                }
                if (csharp2cuda_temp_26)
                {
#line 562 "WindowModule.cs"
                    return false;
                }
#line 563 "WindowModule.cs"
                int average_count = mathblocks_statistics_pair_averages(a, count, scratch);
#line 564 "WindowModule.cs"
#line 564 "WindowModule.cs"
                double* csharp2cuda_temp_27 = value;
#line 564 "WindowModule.cs"
                double csharp2cuda_temp_28 = mathblocks_window_scratch_median(scratch, average_count);
                (*(csharp2cuda_temp_27) = csharp2cuda_temp_28);
#line 565 "WindowModule.cs"
                break;
            }
#line 567 "WindowModule.cs"
        case 17:
#line 568 "WindowModule.cs"
#line 568 "WindowModule.cs"
            double* csharp2cuda_temp_29 = value;
#line 569 "WindowModule.cs"
            double csharp2cuda_temp_30 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, count), ((double)(count)));
            (*(csharp2cuda_temp_29) = mathblocks_square_root(csharp2cuda_temp_30));
#line 570 "WindowModule.cs"
            break;
#line 571 "WindowModule.cs"
        case 21:
#line 572 "WindowModule.cs"
            {
#line 573 "WindowModule.cs"
#line 573 "WindowModule.cs"
                bool csharp2cuda_temp_31;
#line 573 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 573 "WindowModule.cs"
                    csharp2cuda_temp_31 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 573 "WindowModule.cs"
                    csharp2cuda_temp_31 = true;
                }
                if (csharp2cuda_temp_31)
                {
#line 574 "WindowModule.cs"
                    return false;
                }
#line 575 "WindowModule.cs"
                double* left_ranks = scratch;
#line 576 "WindowModule.cs"
                double* right_ranks = csharp2cuda_pointer_add(scratch, count);
#line 577 "WindowModule.cs"
                mathblocks_window_ranks(a, b, count, scratch);
#line 578 "WindowModule.cs"
#line 578 "WindowModule.cs"
                double* csharp2cuda_temp_32 = value;
                (*(csharp2cuda_temp_32) = mathblocks_statistics_pearson(left_ranks, right_ranks, count));
#line 579 "WindowModule.cs"
                break;
            }
#line 581 "WindowModule.cs"
        case 22:
#line 582 "WindowModule.cs"
            {
#line 583 "WindowModule.cs"
                int slope_count = mathblocks_statistics_pair_slopes(a, b, count, scratch);
#line 584 "WindowModule.cs"
                if (((slope_count) <= (0)))
                {
#line 585 "WindowModule.cs"
                    return false;
                }
#line 586 "WindowModule.cs"
#line 586 "WindowModule.cs"
                double* csharp2cuda_temp_33 = value;
#line 586 "WindowModule.cs"
                double csharp2cuda_temp_34 = mathblocks_window_scratch_median(scratch, slope_count);
                (*(csharp2cuda_temp_33) = csharp2cuda_temp_34);
#line 587 "WindowModule.cs"
                break;
            }
#line 589 "WindowModule.cs"
        case 23:
        case 24:
#line 591 "WindowModule.cs"
            return mathblocks_statistics_weighted_value(a, b, count, ((source) == (24)), value);
#line 592 "WindowModule.cs"
        case 25:
#line 593 "WindowModule.cs"
#line 593 "WindowModule.cs"
            double* csharp2cuda_temp_35 = value;
            (*(csharp2cuda_temp_35) = mathblocks_sequence_longest_run_value(flags, count));
#line 594 "WindowModule.cs"
            return true;
#line 595 "WindowModule.cs"
        case 26:
        case 27:
#line 597 "WindowModule.cs"
            return mathblocks_sequence_decline_value(a, count, ((source) == (27)), value);
#line 598 "WindowModule.cs"
        case 28:
#line 599 "WindowModule.cs"
#line 599 "WindowModule.cs"
            double csharp2cuda_temp_36 = (first_parameter)->scalar_value;
            return mathblocks_sequence_variation_value(a, count, csharp2cuda_temp_36, false, value);
#line 600 "WindowModule.cs"
        case 29:
#line 601 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 2.0, false, value);
#line 602 "WindowModule.cs"
        case 30:
#line 603 "WindowModule.cs"
#line 603 "WindowModule.cs"
            double csharp2cuda_temp_37 = (first_parameter)->scalar_value;
            return mathblocks_sequence_recurrence_value(a, count, csharp2cuda_temp_37, value);
#line 604 "WindowModule.cs"
        case 31:
#line 605 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 1.0, true, value);
#line 606 "WindowModule.cs"
        case 32:
        case 33:
#line 608 "WindowModule.cs"
#line 608 "WindowModule.cs"
            double* csharp2cuda_temp_38 = value;
            (*(csharp2cuda_temp_38) = mathblocks_sequence_sign_change_value(a, count, ((source) == (32))));
#line 609 "WindowModule.cs"
            return true;
#line 610 "WindowModule.cs"
        case 34:
#line 611 "WindowModule.cs"
#line 611 "WindowModule.cs"
            double* csharp2cuda_temp_39 = value;
#line 614 "WindowModule.cs"
            double csharp2cuda_temp_40 = (first_parameter)->scalar_value;
#line 615 "WindowModule.cs"
            int csharp2cuda_temp_41 = (second_parameter)->boolean_value;
            (*(csharp2cuda_temp_39) = mathblocks_sequence_first_passage_value(a, count, csharp2cuda_temp_40, ((csharp2cuda_temp_41) != (0))));
#line 616 "WindowModule.cs"
            return true;
#line 617 "WindowModule.cs"
        case 35:
        case 36:
        case 37:
        case 38:
        case 39:
#line 622 "WindowModule.cs"
            if ((!(mathblocks_probability_distribution(a, count))))
            {
#line 623 "WindowModule.cs"
                return false;
            }
#line 624 "WindowModule.cs"
            if (((source) == (35)))
#line 625 "WindowModule.cs"
            {
#line 626 "WindowModule.cs"
#line 626 "WindowModule.cs"
                double* csharp2cuda_temp_42 = value;
                (*(csharp2cuda_temp_42) = mathblocks_probability_entropy(a, count));
            }
            else
            {
#line 628 "WindowModule.cs"
                if (((source) == (39)))
#line 629 "WindowModule.cs"
                {
#line 630 "WindowModule.cs"
#line 630 "WindowModule.cs"
                    double* csharp2cuda_temp_43 = value;
#line 630 "WindowModule.cs"
                    double csharp2cuda_temp_44 = __ddiv_rn(mathblocks_probability_entropy(a, count), mathblocks_natural_logarithm(2.0));
                    (*(csharp2cuda_temp_43) = csharp2cuda_temp_44);
                }
                else
                {
#line 633 "WindowModule.cs"
                    if (((source) == (38)))
#line 634 "WindowModule.cs"
                    {
#line 635 "WindowModule.cs"
#line 635 "WindowModule.cs"
                        double* csharp2cuda_temp_45 = value;
                        (*(csharp2cuda_temp_45) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, count)));
                    }
                    else
                    {
#line 637 "WindowModule.cs"
#line 640 "WindowModule.cs"
                        double csharp2cuda_temp_46 = (first_parameter)->scalar_value;
#line 637 "WindowModule.cs"
                        bool csharp2cuda_temp_47 = mathblocks_probability_ordered_entropy_value(a, count, csharp2cuda_temp_46, ((source) == (36)), value);
                        if ((!(csharp2cuda_temp_47)))
#line 643 "WindowModule.cs"
                        {
#line 644 "WindowModule.cs"
                            return false;
                        }
                    }
                }
            }
#line 646 "WindowModule.cs"
            break;
#line 647 "WindowModule.cs"
        case 40:
        case 41:
#line 649 "WindowModule.cs"
            {
#line 650 "WindowModule.cs"
                double sum = mathblocks_compensated_sum(a, count);
#line 651 "WindowModule.cs"
#line 651 "WindowModule.cs"
                double* csharp2cuda_temp_48 = value;
#line 651 "WindowModule.cs"
                double csharp2cuda_temp_49;
#line 651 "WindowModule.cs"
                if (((source) == (41)))
                {
#line 651 "WindowModule.cs"
                    csharp2cuda_temp_49 = __ddiv_rn(sum, ((double)(count)));
                }
                else
                {
#line 651 "WindowModule.cs"
                    csharp2cuda_temp_49 = sum;
                }
                (*(csharp2cuda_temp_48) = csharp2cuda_temp_49);
#line 652 "WindowModule.cs"
                break;
            }
#line 654 "WindowModule.cs"
        case 42:
        case 43:
#line 656 "WindowModule.cs"
            {
#line 657 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 658 "WindowModule.cs"
                    return false;
                }
#line 659 "WindowModule.cs"
                double selected = (a)[0];
#line 660 "WindowModule.cs"
                {
#line 660 "WindowModule.cs"
                    int index = 1;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 661 "WindowModule.cs"
#line 661 "WindowModule.cs"
                        double* csharp2cuda_temp_51 = &(selected);
#line 661 "WindowModule.cs"
                        double csharp2cuda_temp_52;
#line 661 "WindowModule.cs"
                        if (((source) == (43)))
                        {
#line 662 "WindowModule.cs"
                            double csharp2cuda_temp_53 = (a)[index];
#line 661 "WindowModule.cs"
                            csharp2cuda_temp_52 = mathblocks_maximum(selected, csharp2cuda_temp_53);
                        }
                        else
                        {
#line 663 "WindowModule.cs"
                            double csharp2cuda_temp_54 = (a)[index];
#line 661 "WindowModule.cs"
                            csharp2cuda_temp_52 = mathblocks_minimum(selected, csharp2cuda_temp_54);
                        }
                        (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
#line 660 "WindowModule.cs"
                        int* csharp2cuda_temp_50 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_50));
                    }
                }
#line 664 "WindowModule.cs"
#line 664 "WindowModule.cs"
                double* csharp2cuda_temp_55 = value;
                (*(csharp2cuda_temp_55) = selected);
#line 665 "WindowModule.cs"
                return true;
            }
#line 667 "WindowModule.cs"
        case 44:
#line 668 "WindowModule.cs"
            return mathblocks_vector_geometric_mean_value(a, count, scratch, value);
#line 669 "WindowModule.cs"
        case 45:
#line 670 "WindowModule.cs"
#line 670 "WindowModule.cs"
            double* csharp2cuda_temp_56 = value;
            (*(csharp2cuda_temp_56) = mathblocks_compensated_absolute_sum(a, count));
#line 671 "WindowModule.cs"
            break;
#line 672 "WindowModule.cs"
        case 46:
#line 673 "WindowModule.cs"
#line 673 "WindowModule.cs"
            double* csharp2cuda_temp_57 = value;
            (*(csharp2cuda_temp_57) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, count)));
#line 674 "WindowModule.cs"
            break;
#line 675 "WindowModule.cs"
        case 47:
        case 48:
#line 677 "WindowModule.cs"
            {
#line 678 "WindowModule.cs"
                double csharp2cuda_temp_58;
#line 678 "WindowModule.cs"
                if (((source) == (47)))
                {
#line 678 "WindowModule.cs"
                    csharp2cuda_temp_58 = 0.5;
                }
                else
                {
#line 678 "WindowModule.cs"
                    csharp2cuda_temp_58 = (first_parameter)->scalar_value;
                }
#line 678 "WindowModule.cs"
                double probability = csharp2cuda_temp_58;
#line 679 "WindowModule.cs"
#line 679 "WindowModule.cs"
                bool csharp2cuda_temp_59;
#line 679 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 679 "WindowModule.cs"
                    csharp2cuda_temp_59 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 679 "WindowModule.cs"
                    csharp2cuda_temp_59 = true;
                }
#line 679 "WindowModule.cs"
                bool csharp2cuda_temp_60;
#line 679 "WindowModule.cs"
                if (!(csharp2cuda_temp_59))
                {
#line 679 "WindowModule.cs"
                    csharp2cuda_temp_60 = ((probability) < (0.0));
                }
                else
                {
#line 679 "WindowModule.cs"
                    csharp2cuda_temp_60 = true;
                }
#line 679 "WindowModule.cs"
                bool csharp2cuda_temp_61;
#line 679 "WindowModule.cs"
                if (!(csharp2cuda_temp_60))
                {
#line 679 "WindowModule.cs"
                    csharp2cuda_temp_61 = ((probability) > (1.0));
                }
                else
                {
#line 679 "WindowModule.cs"
                    csharp2cuda_temp_61 = true;
                }
                if (csharp2cuda_temp_61)
                {
#line 680 "WindowModule.cs"
                    return false;
                }
#line 681 "WindowModule.cs"
#line 681 "WindowModule.cs"
                double* csharp2cuda_temp_62 = value;
#line 681 "WindowModule.cs"
                double csharp2cuda_temp_63 = mathblocks_quantile_values(a, count, scratch, probability);
                (*(csharp2cuda_temp_62) = csharp2cuda_temp_63);
#line 682 "WindowModule.cs"
                break;
            }
#line 684 "WindowModule.cs"
        case 49:
        case 50:
#line 686 "WindowModule.cs"
            return mathblocks_vector_arg_extreme_value(a, count, ((source) == (49)), value);
#line 687 "WindowModule.cs"
        case 51:
#line 688 "WindowModule.cs"
#line 688 "WindowModule.cs"
            double* csharp2cuda_temp_64 = value;
            (*(csharp2cuda_temp_64) = mathblocks_vector_rank_at(a, count, csharp2cuda_i32_sub(count, 1)));
#line 689 "WindowModule.cs"
            return true;
#line 690 "WindowModule.cs"
        case 52:
#line 691 "WindowModule.cs"
            return mathblocks_window_standardize_last(a, count, value);
#line 692 "WindowModule.cs"
        default:
#line 693 "WindowModule.cs"
            return false;
    }
#line 695 "WindowModule.cs"
#line 695 "WindowModule.cs"
    double csharp2cuda_temp_65 = *(value);
    return isfinite(csharp2cuda_temp_65);
}