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

#line 979 "WindowModule.cs"
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

#line 1278 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 284 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value);

#line 259 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means);

#line 935 "WindowModule.cs"
__device__ void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql);

#line 687 "WindowModule.cs"
__device__ void mathblocks_window_exact_add(long long* accumulator, double value, int shift, bool subtract);

#line 730 "WindowModule.cs"
__device__ void mathblocks_window_exact_add_square(long long* accumulator, double value, bool subtract);

#line 624 "WindowModule.cs"
__device__ int mathblocks_window_exact_add_to(long long* target, double value, int shift, bool subtract);

#line 791 "WindowModule.cs"
__device__ bool mathblocks_window_exact_any_below(const long long* value, int lowest, int position);

#line 777 "WindowModule.cs"
__device__ long long mathblocks_window_exact_bits(const long long* value, int position, int count);

#line 666 "WindowModule.cs"
__device__ long long mathblocks_window_exact_carry(long long* target, int first, int last);

#line 613 "WindowModule.cs"
__device__ void mathblocks_window_exact_clear(long long* accumulator);

#line 757 "WindowModule.cs"
__device__ int mathblocks_window_exact_load(long long* accumulator, bool* negative);

#line 680 "WindowModule.cs"
__device__ void mathblocks_window_exact_negate(long long* target, int first, int last);

#line 842 "WindowModule.cs"
__device__ void mathblocks_window_exact_read_pair(long long* accumulator, double* high, double* low);

#line 879 "WindowModule.cs"
__device__ double mathblocks_window_exact_read_quotient(long long* accumulator, int divisor);

#line 807 "WindowModule.cs"
__device__ double mathblocks_window_exact_round(const long long* value, int lowest, int top, bool sticky);

#line 916 "WindowModule.cs"
__device__ void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e);

#line 969 "WindowModule.cs"
__device__ bool mathblocks_window_in_range(double value, double largest);

#line 229 "WindowModule.cs"
__device__ double* mathblocks_window_merge_sort(double* values, double* buffer, int count);

#line 607 "WindowModule.cs"
__device__ double mathblocks_window_power_of_two(int exponent);

#line 1145 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread);

#line 1161 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity);

#line 194 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width);

#line 324 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count);

#line 169 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source);

#line 1084 "WindowModule.cs"
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

#line 136 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source);

#line 706 "WindowModule.cs"
__device__ void mathblocks_window_split(double a, double* high, double* low);

#line 924 "WindowModule.cs"
__device__ void mathblocks_window_square(double h, double l, double* sh, double* sl);

#line 333 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value);

#line 948 "WindowModule.cs"
__device__ double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl);

#line 715 "WindowModule.cs"
__device__ void mathblocks_window_two_product(double a, double b, double* p, double* e);

#line 907 "WindowModule.cs"
__device__ void mathblocks_window_two_sum(double a, double b, double* s, double* e);

#line 355 "WindowModule.cs"
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

#line 979 "WindowModule.cs"
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
#line 991 "WindowModule.cs"
{
#line 992 "WindowModule.cs"
    bool variance = ((source) >= (55));
#line 993 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 993 "WindowModule.cs"
    if (!(((source) == (56))))
    {
#line 993 "WindowModule.cs"
        csharp2cuda_temp_0 = ((source) == (58));
    }
    else
    {
#line 993 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 993 "WindowModule.cs"
    bool sample = csharp2cuda_temp_0;
#line 994 "WindowModule.cs"
    bool deviation = ((source) >= (57));
#line 995 "WindowModule.cs"
    long long* first = scratch;
#line 996 "WindowModule.cs"
    long long* second = csharp2cuda_pointer_add(scratch, 285);
#line 997 "WindowModule.cs"
    mathblocks_window_exact_clear(first);
#line 998 "WindowModule.cs"
    if (variance)
    {
#line 999 "WindowModule.cs"
        mathblocks_window_exact_clear(second);
    }
#line 1000 "WindowModule.cs"
    double csharp2cuda_temp_1;
#line 1000 "WindowModule.cs"
    if (sample)
    {
#line 1000 "WindowModule.cs"
        csharp2cuda_temp_1 = __dsub_rn(((double)(width)), 1.0);
    }
    else
    {
#line 1000 "WindowModule.cs"
        csharp2cuda_temp_1 = ((double)(width));
    }
#line 1000 "WindowModule.cs"
    double divisor = csharp2cuda_temp_1;
#line 1001 "WindowModule.cs"
    int csharp2cuda_temp_2;
#line 1001 "WindowModule.cs"
    if (((csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1)) < (0)))
    {
#line 1001 "WindowModule.cs"
        csharp2cuda_temp_2 = 0;
    }
    else
    {
#line 1001 "WindowModule.cs"
        csharp2cuda_temp_2 = csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1);
    }
#line 1001 "WindowModule.cs"
    int begin = csharp2cuda_temp_2;
#line 1002 "WindowModule.cs"
    int changes = 0;
#line 1003 "WindowModule.cs"
    {
#line 1003 "WindowModule.cs"
        int row = begin;
        while (true)
        {
            if (!(((row) < (last_row))))
                break;
#line 1004 "WindowModule.cs"
            {
#line 1005 "WindowModule.cs"
#line 1005 "WindowModule.cs"
                double csharp2cuda_temp_4 = (x)[row];
                mathblocks_window_exact_add(first, csharp2cuda_temp_4, 0, false);
#line 1006 "WindowModule.cs"
                if (variance)
#line 1007 "WindowModule.cs"
                {
#line 1008 "WindowModule.cs"
#line 1008 "WindowModule.cs"
                    double csharp2cuda_temp_5 = (x)[row];
                    mathblocks_window_exact_add_square(second, csharp2cuda_temp_5, false);
#line 1009 "WindowModule.cs"
#line 1009 "WindowModule.cs"
                    bool csharp2cuda_temp_6;
#line 1009 "WindowModule.cs"
                    if (((row) > (begin)))
                    {
#line 1009 "WindowModule.cs"
                        double csharp2cuda_temp_7 = (x)[row];
#line 1009 "WindowModule.cs"
                        double csharp2cuda_temp_8 = (x)[csharp2cuda_i32_sub(row, 1)];
#line 1009 "WindowModule.cs"
                        csharp2cuda_temp_6 = ((csharp2cuda_temp_7) != (csharp2cuda_temp_8));
                    }
                    else
                    {
#line 1009 "WindowModule.cs"
                        csharp2cuda_temp_6 = false;
                    }
                    if (csharp2cuda_temp_6)
                    {
#line 1010 "WindowModule.cs"
#line 1010 "WindowModule.cs"
                        int* csharp2cuda_temp_9 = &(changes);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                    }
                }
#line 1012 "WindowModule.cs"
                if (((csharp2cuda_i32_sub(row, width)) >= (begin)))
#line 1013 "WindowModule.cs"
                {
#line 1014 "WindowModule.cs"
#line 1014 "WindowModule.cs"
                    double csharp2cuda_temp_10 = (x)[csharp2cuda_i32_sub(row, width)];
                    mathblocks_window_exact_add(first, csharp2cuda_temp_10, 0, true);
#line 1015 "WindowModule.cs"
                    if (variance)
#line 1016 "WindowModule.cs"
                    {
#line 1017 "WindowModule.cs"
#line 1017 "WindowModule.cs"
                        double csharp2cuda_temp_11 = (x)[csharp2cuda_i32_sub(row, width)];
                        mathblocks_window_exact_add_square(second, csharp2cuda_temp_11, true);
#line 1018 "WindowModule.cs"
#line 1018 "WindowModule.cs"
                        double csharp2cuda_temp_12 = (x)[csharp2cuda_i32_add(csharp2cuda_i32_sub(row, width), 1)];
#line 1018 "WindowModule.cs"
                        double csharp2cuda_temp_13 = (x)[csharp2cuda_i32_sub(row, width)];
                        if (((csharp2cuda_temp_12) != (csharp2cuda_temp_13)))
                        {
#line 1019 "WindowModule.cs"
#line 1019 "WindowModule.cs"
                            int* csharp2cuda_temp_14 = &(changes);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_14));
                        }
                    }
                }
#line 1022 "WindowModule.cs"
                if (((row) < (first_row)))
                {
#line 1023 "WindowModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 1024 "WindowModule.cs"
                bool computed = false;
#line 1025 "WindowModule.cs"
                double value = 0.0;
#line 1026 "WindowModule.cs"
                if (((row) >= (csharp2cuda_i32_sub(width, 1))))
#line 1027 "WindowModule.cs"
                {
#line 1028 "WindowModule.cs"
                    if ((!(variance)))
#line 1029 "WindowModule.cs"
                    {
#line 1030 "WindowModule.cs"
                        double low = 0.0;
#line 1031 "WindowModule.cs"
                        if (((source) == (54)))
                        {
#line 1032 "WindowModule.cs"
#line 1032 "WindowModule.cs"
                            double* csharp2cuda_temp_15 = &(value);
#line 1032 "WindowModule.cs"
                            double csharp2cuda_temp_16 = mathblocks_window_exact_read_quotient(first, width);
                            (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
                        }
                        else
                        {
#line 1034 "WindowModule.cs"
#line 1034 "WindowModule.cs"
                            double* csharp2cuda_temp_17 = &(value);
#line 1034 "WindowModule.cs"
                            double* csharp2cuda_temp_18 = &(low);
                            mathblocks_window_exact_read_pair(first, csharp2cuda_temp_17, csharp2cuda_temp_18);
                        }
#line 1035 "WindowModule.cs"
#line 1035 "WindowModule.cs"
                        bool* csharp2cuda_temp_19 = &(computed);
                        (*(csharp2cuda_temp_19) = isfinite(value));
                    }
                    else
#line 1038 "WindowModule.cs"
                    {
#line 1039 "WindowModule.cs"
                        double moment = 0.0;
#line 1040 "WindowModule.cs"
                        bool in_range = true;
#line 1041 "WindowModule.cs"
                        if (((changes) != (0)))
#line 1042 "WindowModule.cs"
                        {
#line 1043 "WindowModule.cs"
                            double s1h = 0.0;
#line 1044 "WindowModule.cs"
                            double s1l = 0.0;
#line 1045 "WindowModule.cs"
                            double s2h = 0.0;
#line 1046 "WindowModule.cs"
                            double s2l = 0.0;
#line 1047 "WindowModule.cs"
                            double qh = 0.0;
#line 1048 "WindowModule.cs"
                            double ql = 0.0;
#line 1049 "WindowModule.cs"
                            double rh = 0.0;
#line 1050 "WindowModule.cs"
                            double rl = 0.0;
#line 1051 "WindowModule.cs"
#line 1051 "WindowModule.cs"
                            double* csharp2cuda_temp_20 = &(s1h);
#line 1051 "WindowModule.cs"
                            double* csharp2cuda_temp_21 = &(s1l);
                            mathblocks_window_exact_read_pair(first, csharp2cuda_temp_20, csharp2cuda_temp_21);
#line 1052 "WindowModule.cs"
#line 1052 "WindowModule.cs"
                            double* csharp2cuda_temp_22 = &(s2h);
#line 1052 "WindowModule.cs"
                            double* csharp2cuda_temp_23 = &(s2l);
                            mathblocks_window_exact_read_pair(second, csharp2cuda_temp_22, csharp2cuda_temp_23);
#line 1053 "WindowModule.cs"
#line 1053 "WindowModule.cs"
                            double* csharp2cuda_temp_24 = &(qh);
#line 1053 "WindowModule.cs"
                            double* csharp2cuda_temp_25 = &(ql);
                            mathblocks_window_square(s1h, s1l, csharp2cuda_temp_24, csharp2cuda_temp_25);
#line 1054 "WindowModule.cs"
#line 1054 "WindowModule.cs"
                            double* csharp2cuda_temp_26 = &(rh);
#line 1054 "WindowModule.cs"
                            double* csharp2cuda_temp_27 = &(rl);
                            mathblocks_window_divide_by_integer(qh, ql, width, csharp2cuda_temp_26, csharp2cuda_temp_27);
#line 1055 "WindowModule.cs"
#line 1055 "WindowModule.cs"
                            double* csharp2cuda_temp_28 = &(moment);
#line 1055 "WindowModule.cs"
                            double csharp2cuda_temp_29 = mathblocks_window_subtract_rounded(s2h, s2l, rh, rl);
                            (*(csharp2cuda_temp_28) = csharp2cuda_temp_29);
#line 1056 "WindowModule.cs"
                            double largest = __longlong_as_double(9218868437227405311LL);
#line 1057 "WindowModule.cs"
#line 1057 "WindowModule.cs"
                            bool csharp2cuda_temp_30;
#line 1057 "WindowModule.cs"
                            if (!((!(mathblocks_window_in_range(s2h, largest)))))
                            {
#line 1057 "WindowModule.cs"
                                csharp2cuda_temp_30 = (!(mathblocks_window_in_range(qh, largest)));
                            }
                            else
                            {
#line 1057 "WindowModule.cs"
                                csharp2cuda_temp_30 = true;
                            }
#line 1057 "WindowModule.cs"
                            bool csharp2cuda_temp_31;
#line 1057 "WindowModule.cs"
                            if (!(csharp2cuda_temp_30))
                            {
#line 1057 "WindowModule.cs"
                                csharp2cuda_temp_31 = (!(mathblocks_window_in_range(rh, mathblocks_window_power_of_two(996))));
                            }
                            else
                            {
#line 1057 "WindowModule.cs"
                                csharp2cuda_temp_31 = true;
                            }
#line 1057 "WindowModule.cs"
                            bool csharp2cuda_temp_32;
#line 1057 "WindowModule.cs"
                            if (!(csharp2cuda_temp_31))
                            {
#line 1060 "WindowModule.cs"
                                bool csharp2cuda_temp_33;
#line 1060 "WindowModule.cs"
                                if (((moment) > (0.0)))
                                {
#line 1060 "WindowModule.cs"
                                    csharp2cuda_temp_33 = ((moment) < (mathblocks_window_power_of_two(csharp2cuda_i32_neg(968))));
                                }
                                else
                                {
#line 1060 "WindowModule.cs"
                                    csharp2cuda_temp_33 = false;
                                }
#line 1057 "WindowModule.cs"
                                csharp2cuda_temp_32 = csharp2cuda_temp_33;
                            }
                            else
                            {
#line 1057 "WindowModule.cs"
                                csharp2cuda_temp_32 = true;
                            }
                            if (csharp2cuda_temp_32)
                            {
#line 1061 "WindowModule.cs"
#line 1061 "WindowModule.cs"
                                bool* csharp2cuda_temp_34 = &(in_range);
                                (*(csharp2cuda_temp_34) = false);
                            }
                            else
                            {
#line 1062 "WindowModule.cs"
                                if (((moment) <= (0.0)))
                                {
#line 1063 "WindowModule.cs"
#line 1063 "WindowModule.cs"
                                    double* csharp2cuda_temp_35 = &(moment);
                                    (*(csharp2cuda_temp_35) = 0.0);
                                }
                            }
                        }
#line 1065 "WindowModule.cs"
#line 1065 "WindowModule.cs"
                        double* csharp2cuda_temp_36 = &(value);
#line 1065 "WindowModule.cs"
                        double csharp2cuda_temp_37 = __ddiv_rn(moment, divisor);
                        (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 1066 "WindowModule.cs"
                        if (deviation)
                        {
#line 1067 "WindowModule.cs"
#line 1067 "WindowModule.cs"
                            double* csharp2cuda_temp_38 = &(value);
                            (*(csharp2cuda_temp_38) = mathblocks_square_root(value));
                        }
#line 1068 "WindowModule.cs"
#line 1068 "WindowModule.cs"
                        bool* csharp2cuda_temp_39 = &(computed);
#line 1068 "WindowModule.cs"
                        bool csharp2cuda_temp_40;
#line 1068 "WindowModule.cs"
                        if (in_range)
                        {
#line 1068 "WindowModule.cs"
                            csharp2cuda_temp_40 = isfinite(value);
                        }
                        else
                        {
#line 1068 "WindowModule.cs"
                            csharp2cuda_temp_40 = false;
                        }
                        (*(csharp2cuda_temp_39) = csharp2cuda_temp_40);
                    }
                }
#line 1071 "WindowModule.cs"
                if (sibling)
                {
#line 1072 "WindowModule.cs"
#line 1072 "WindowModule.cs"
                    int* csharp2cuda_temp_41 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_41) = computed);
                }
                else
                {
#line 1074 "WindowModule.cs"
#line 1074 "WindowModule.cs"
                    double* csharp2cuda_temp_42 = &((result)[row]);
#line 1074 "WindowModule.cs"
                    double csharp2cuda_temp_43;
#line 1074 "WindowModule.cs"
                    if (computed)
                    {
#line 1074 "WindowModule.cs"
                        csharp2cuda_temp_43 = value;
                    }
                    else
                    {
#line 1074 "WindowModule.cs"
                        csharp2cuda_temp_43 = fill;
                    }
                    (*(csharp2cuda_temp_42) = csharp2cuda_temp_43);
                }
            }
            csharp2cuda_for_continue_0:
#line 1003 "WindowModule.cs"
            int* csharp2cuda_temp_3 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
}

#line 1278 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 1284 "WindowModule.cs"
{
#line 1285 "WindowModule.cs"
    mathblocks_window_run(opcode, inputs, input_count, output, threadIdx.x, blockDim.x, csharp2cuda_i32_neg(1));
}

#line 284 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value)
#line 291 "WindowModule.cs"
{
#line 292 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 293 "WindowModule.cs"
        return false;
    }
#line 294 "WindowModule.cs"
    double* left_means = row_means;
#line 295 "WindowModule.cs"
    double* right_means = csharp2cuda_pointer_add(row_means, count);
#line 296 "WindowModule.cs"
    double left_total = mathblocks_window_distance_row_means(left_values, count, left_means);
#line 297 "WindowModule.cs"
    double right_total = mathblocks_window_distance_row_means(right_values, count, right_means);
#line 298 "WindowModule.cs"
    double covariance_square = 0.0;
#line 299 "WindowModule.cs"
    double left_variance_square = 0.0;
#line 300 "WindowModule.cs"
    double right_variance_square = 0.0;
#line 301 "WindowModule.cs"
    {
#line 301 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 302 "WindowModule.cs"
            {
#line 303 "WindowModule.cs"
                {
#line 303 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 304 "WindowModule.cs"
                        {
#line 305 "WindowModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[row];
#line 305 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[column];
#line 306 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (left_means)[row];
#line 306 "WindowModule.cs"
                            double csharp2cuda_temp_5 = (left_means)[column];
#line 305 "WindowModule.cs"
                            double left = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3)), __dsub_rn(__dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), left_total));
#line 307 "WindowModule.cs"
                            double csharp2cuda_temp_6 = (right_values)[row];
#line 307 "WindowModule.cs"
                            double csharp2cuda_temp_7 = (right_values)[column];
#line 308 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (right_means)[row];
#line 308 "WindowModule.cs"
                            double csharp2cuda_temp_9 = (right_means)[column];
#line 307 "WindowModule.cs"
                            double right = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)), __dsub_rn(__dadd_rn(csharp2cuda_temp_8, csharp2cuda_temp_9), right_total));
#line 309 "WindowModule.cs"
#line 309 "WindowModule.cs"
                            double* csharp2cuda_temp_10 = &(covariance_square);
#line 309 "WindowModule.cs"
                            double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                            (*(csharp2cuda_temp_10) = __dadd_rn(csharp2cuda_temp_11, __dmul_rn(left, right)));
#line 310 "WindowModule.cs"
#line 310 "WindowModule.cs"
                            double* csharp2cuda_temp_12 = &(left_variance_square);
#line 310 "WindowModule.cs"
                            double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                            (*(csharp2cuda_temp_12) = __dadd_rn(csharp2cuda_temp_13, __dmul_rn(left, left)));
#line 311 "WindowModule.cs"
#line 311 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = &(right_variance_square);
#line 311 "WindowModule.cs"
                            double csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
                            (*(csharp2cuda_temp_14) = __dadd_rn(csharp2cuda_temp_15, __dmul_rn(right, right)));
                        }
#line 303 "WindowModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 301 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 314 "WindowModule.cs"
#line 314 "WindowModule.cs"
    double* csharp2cuda_temp_16 = &(covariance_square);
#line 314 "WindowModule.cs"
    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
    (*(csharp2cuda_temp_16) = __ddiv_rn(csharp2cuda_temp_17, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 315 "WindowModule.cs"
#line 315 "WindowModule.cs"
    double* csharp2cuda_temp_18 = &(left_variance_square);
#line 315 "WindowModule.cs"
    double csharp2cuda_temp_19 = *(csharp2cuda_temp_18);
    (*(csharp2cuda_temp_18) = __ddiv_rn(csharp2cuda_temp_19, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 316 "WindowModule.cs"
#line 316 "WindowModule.cs"
    double* csharp2cuda_temp_20 = &(right_variance_square);
#line 316 "WindowModule.cs"
    double csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
    (*(csharp2cuda_temp_20) = __ddiv_rn(csharp2cuda_temp_21, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 317 "WindowModule.cs"
#line 317 "WindowModule.cs"
    double* csharp2cuda_temp_22 = value;
#line 318 "WindowModule.cs"
    double csharp2cuda_temp_23 = __ddiv_rn(covariance_square, mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square)));
    (*(csharp2cuda_temp_22) = mathblocks_square_root(csharp2cuda_temp_23));
#line 320 "WindowModule.cs"
#line 320 "WindowModule.cs"
    double csharp2cuda_temp_24 = *(value);
    return isfinite(csharp2cuda_temp_24);
}

#line 259 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means)
#line 264 "WindowModule.cs"
{
#line 265 "WindowModule.cs"
    double total_mean = 0.0;
#line 266 "WindowModule.cs"
    {
#line 266 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 267 "WindowModule.cs"
            {
#line 268 "WindowModule.cs"
#line 268 "WindowModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 269 "WindowModule.cs"
                {
#line 269 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 270 "WindowModule.cs"
                        {
#line 271 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 271 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 271 "WindowModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 272 "WindowModule.cs"
#line 272 "WindowModule.cs"
                            double* csharp2cuda_temp_5 = &((row_means)[row]);
#line 272 "WindowModule.cs"
                            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, distance));
#line 273 "WindowModule.cs"
#line 273 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &(total_mean);
#line 273 "WindowModule.cs"
                            double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                            (*(csharp2cuda_temp_7) = __dadd_rn(csharp2cuda_temp_8, distance));
                        }
#line 269 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 275 "WindowModule.cs"
#line 275 "WindowModule.cs"
                double* csharp2cuda_temp_9 = &((row_means)[row]);
#line 275 "WindowModule.cs"
                double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
                (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
            }
#line 266 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 277 "WindowModule.cs"
#line 277 "WindowModule.cs"
    double* csharp2cuda_temp_11 = &(total_mean);
#line 277 "WindowModule.cs"
    double csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
    (*(csharp2cuda_temp_11) = __ddiv_rn(csharp2cuda_temp_12, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 278 "WindowModule.cs"
    return total_mean;
}

#line 935 "WindowModule.cs"
__device__ void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql)
#line 937 "WindowModule.cs"
{
#line 938 "WindowModule.cs"
    double divisor = ((double)(width));
#line 939 "WindowModule.cs"
    double high = __ddiv_rn(h, divisor);
#line 940 "WindowModule.cs"
    double p = 0.0;
#line 941 "WindowModule.cs"
    double e = 0.0;
#line 942 "WindowModule.cs"
#line 942 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(p);
#line 942 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(e);
    mathblocks_window_two_product(high, divisor, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 943 "WindowModule.cs"
    double low = __ddiv_rn(__dadd_rn(__dsub_rn(__dsub_rn(h, p), e), l), divisor);
#line 944 "WindowModule.cs"
    mathblocks_window_fast_two_sum(high, low, qh, ql);
}

#line 687 "WindowModule.cs"
__device__ void mathblocks_window_exact_add(long long* accumulator, double value, int shift, bool subtract)
#line 689 "WindowModule.cs"
{
#line 690 "WindowModule.cs"
    if (((value) == (0.0)))
    {
#line 691 "WindowModule.cs"
        return;
    }
#line 692 "WindowModule.cs"
    int index = mathblocks_window_exact_add_to(accumulator, value, shift, subtract);
#line 693 "WindowModule.cs"
#line 693 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[282];
    if (((((long long)(index))) < (csharp2cuda_temp_0)))
    {
#line 694 "WindowModule.cs"
#line 694 "WindowModule.cs"
        long long* csharp2cuda_temp_1 = &((accumulator)[282]);
        (*(csharp2cuda_temp_1) = ((long long)(index)));
    }
#line 695 "WindowModule.cs"
#line 695 "WindowModule.cs"
    long long csharp2cuda_temp_2 = (accumulator)[283];
    if (((((long long)(csharp2cuda_i32_add(index, 2)))) > (csharp2cuda_temp_2)))
    {
#line 696 "WindowModule.cs"
#line 696 "WindowModule.cs"
        long long* csharp2cuda_temp_3 = &((accumulator)[283]);
        (*(csharp2cuda_temp_3) = ((long long)(csharp2cuda_i32_add(index, 2))));
    }
#line 697 "WindowModule.cs"
#line 697 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((accumulator)[284]);
#line 697 "WindowModule.cs"
    long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
    (*(csharp2cuda_temp_4) = csharp2cuda_i64_add(csharp2cuda_temp_5, 1LL));
#line 698 "WindowModule.cs"
#line 698 "WindowModule.cs"
    long long csharp2cuda_temp_6 = (accumulator)[284];
    if (((csharp2cuda_temp_6) == (134217728LL)))
#line 699 "WindowModule.cs"
    {
#line 700 "WindowModule.cs"
#line 700 "WindowModule.cs"
        long long csharp2cuda_temp_7 = (accumulator)[282];
#line 700 "WindowModule.cs"
        long long csharp2cuda_temp_8 = (accumulator)[283];
        mathblocks_window_exact_carry(accumulator, csharp2cuda_i32_from_bits(csharp2cuda_temp_7), csharp2cuda_i32_from_bits(csharp2cuda_temp_8));
#line 701 "WindowModule.cs"
#line 701 "WindowModule.cs"
        long long* csharp2cuda_temp_9 = &((accumulator)[283]);
#line 701 "WindowModule.cs"
        long long csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
        (*(csharp2cuda_temp_9) = csharp2cuda_i64_add(csharp2cuda_temp_10, 1LL));
#line 702 "WindowModule.cs"
#line 702 "WindowModule.cs"
        long long* csharp2cuda_temp_11 = &((accumulator)[284]);
        (*(csharp2cuda_temp_11) = 0LL);
    }
}

#line 730 "WindowModule.cs"
__device__ void mathblocks_window_exact_add_square(long long* accumulator, double value, bool subtract)
#line 732 "WindowModule.cs"
{
#line 733 "WindowModule.cs"
    if (((value) == (0.0)))
    {
#line 734 "WindowModule.cs"
        return;
    }
#line 735 "WindowModule.cs"
    double magnitude = fabs(value);
#line 736 "WindowModule.cs"
    double scaled = value;
#line 737 "WindowModule.cs"
    int shift = 0;
#line 738 "WindowModule.cs"
    if (((magnitude) < (mathblocks_window_power_of_two(csharp2cuda_i32_neg(400)))))
#line 739 "WindowModule.cs"
    {
#line 740 "WindowModule.cs"
#line 740 "WindowModule.cs"
        double* csharp2cuda_temp_0 = &(scaled);
        (*(csharp2cuda_temp_0) = __dmul_rn(value, mathblocks_window_power_of_two(600)));
#line 741 "WindowModule.cs"
#line 741 "WindowModule.cs"
        int* csharp2cuda_temp_1 = &(shift);
        (*(csharp2cuda_temp_1) = csharp2cuda_i32_neg(1200));
    }
    else
    {
#line 743 "WindowModule.cs"
        if (((magnitude) > (mathblocks_window_power_of_two(400))))
#line 744 "WindowModule.cs"
        {
#line 745 "WindowModule.cs"
#line 745 "WindowModule.cs"
            double* csharp2cuda_temp_2 = &(scaled);
            (*(csharp2cuda_temp_2) = __dmul_rn(value, mathblocks_window_power_of_two(csharp2cuda_i32_neg(600))));
#line 746 "WindowModule.cs"
#line 746 "WindowModule.cs"
            int* csharp2cuda_temp_3 = &(shift);
            (*(csharp2cuda_temp_3) = 1200);
        }
    }
#line 748 "WindowModule.cs"
    double product = 0.0;
#line 749 "WindowModule.cs"
    double error = 0.0;
#line 750 "WindowModule.cs"
#line 750 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(product);
#line 750 "WindowModule.cs"
    double* csharp2cuda_temp_5 = &(error);
    mathblocks_window_two_product(scaled, scaled, csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 751 "WindowModule.cs"
    mathblocks_window_exact_add(accumulator, product, shift, subtract);
#line 752 "WindowModule.cs"
    mathblocks_window_exact_add(accumulator, error, shift, subtract);
}

#line 624 "WindowModule.cs"
__device__ int mathblocks_window_exact_add_to(long long* target, double value, int shift, bool subtract)
#line 626 "WindowModule.cs"
{
#line 627 "WindowModule.cs"
    long long bits = __double_as_longlong(value);
#line 628 "WindowModule.cs"
    bool negative = ((((bits) < (0LL))) != (subtract));
#line 629 "WindowModule.cs"
    int biased = csharp2cuda_i32_from_bits(csharp2cuda_i64_and(csharp2cuda_i64_shr(bits, 52), 2047LL));
#line 630 "WindowModule.cs"
    long long significand = csharp2cuda_i64_and(bits, 4503599627370495LL);
#line 631 "WindowModule.cs"
    int exponent;
#line 632 "WindowModule.cs"
    if (((biased) == (0)))
#line 633 "WindowModule.cs"
    {
#line 634 "WindowModule.cs"
#line 634 "WindowModule.cs"
        int* csharp2cuda_temp_0 = &(exponent);
        (*(csharp2cuda_temp_0) = csharp2cuda_i32_neg(1074));
    }
    else
#line 637 "WindowModule.cs"
    {
#line 638 "WindowModule.cs"
#line 638 "WindowModule.cs"
        long long* csharp2cuda_temp_1 = &(significand);
#line 638 "WindowModule.cs"
        long long csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
        (*(csharp2cuda_temp_1) = csharp2cuda_i64_or(csharp2cuda_temp_2, csharp2cuda_i64_shl(1LL, 52)));
#line 639 "WindowModule.cs"
#line 639 "WindowModule.cs"
        int* csharp2cuda_temp_3 = &(exponent);
        (*(csharp2cuda_temp_3) = csharp2cuda_i32_sub(biased, 1075));
    }
#line 641 "WindowModule.cs"
    int position = csharp2cuda_i32_add(csharp2cuda_i32_add(exponent, shift), 2208);
#line 642 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(position, 5);
#line 643 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(position, 31);
#line 644 "WindowModule.cs"
    long long low_part = csharp2cuda_i64_shl(csharp2cuda_i64_and(significand, 4294967295LL), offset);
#line 645 "WindowModule.cs"
    long long high_part = csharp2cuda_i64_shl(csharp2cuda_i64_shr(significand, 32), offset);
#line 646 "WindowModule.cs"
    long long first = csharp2cuda_i64_and(low_part, 4294967295LL);
#line 647 "WindowModule.cs"
    long long second = csharp2cuda_i64_add(csharp2cuda_i64_shr(low_part, 32), csharp2cuda_i64_and(high_part, 4294967295LL));
#line 648 "WindowModule.cs"
    long long third = csharp2cuda_i64_shr(high_part, 32);
#line 649 "WindowModule.cs"
    if (negative)
#line 650 "WindowModule.cs"
    {
#line 651 "WindowModule.cs"
#line 651 "WindowModule.cs"
        long long* csharp2cuda_temp_4 = &((target)[index]);
#line 651 "WindowModule.cs"
        long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
        (*(csharp2cuda_temp_4) = csharp2cuda_i64_sub(csharp2cuda_temp_5, first));
#line 652 "WindowModule.cs"
#line 652 "WindowModule.cs"
        long long* csharp2cuda_temp_6 = &((target)[csharp2cuda_i32_add(index, 1)]);
#line 652 "WindowModule.cs"
        long long csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
        (*(csharp2cuda_temp_6) = csharp2cuda_i64_sub(csharp2cuda_temp_7, second));
#line 653 "WindowModule.cs"
#line 653 "WindowModule.cs"
        long long* csharp2cuda_temp_8 = &((target)[csharp2cuda_i32_add(index, 2)]);
#line 653 "WindowModule.cs"
        long long csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
        (*(csharp2cuda_temp_8) = csharp2cuda_i64_sub(csharp2cuda_temp_9, third));
    }
    else
#line 656 "WindowModule.cs"
    {
#line 657 "WindowModule.cs"
#line 657 "WindowModule.cs"
        long long* csharp2cuda_temp_10 = &((target)[index]);
#line 657 "WindowModule.cs"
        long long csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
        (*(csharp2cuda_temp_10) = csharp2cuda_i64_add(csharp2cuda_temp_11, first));
#line 658 "WindowModule.cs"
#line 658 "WindowModule.cs"
        long long* csharp2cuda_temp_12 = &((target)[csharp2cuda_i32_add(index, 1)]);
#line 658 "WindowModule.cs"
        long long csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
        (*(csharp2cuda_temp_12) = csharp2cuda_i64_add(csharp2cuda_temp_13, second));
#line 659 "WindowModule.cs"
#line 659 "WindowModule.cs"
        long long* csharp2cuda_temp_14 = &((target)[csharp2cuda_i32_add(index, 2)]);
#line 659 "WindowModule.cs"
        long long csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
        (*(csharp2cuda_temp_14) = csharp2cuda_i64_add(csharp2cuda_temp_15, third));
    }
#line 661 "WindowModule.cs"
    return index;
}

#line 791 "WindowModule.cs"
__device__ bool mathblocks_window_exact_any_below(const long long* value, int lowest, int position)
#line 793 "WindowModule.cs"
{
#line 794 "WindowModule.cs"
    int relative = csharp2cuda_i32_add(position, 2208);
#line 795 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(relative, 5);
#line 796 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(relative, 31);
#line 797 "WindowModule.cs"
#line 797 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (value)[index];
    if (((csharp2cuda_i64_and(csharp2cuda_temp_0, csharp2cuda_i64_sub(csharp2cuda_i64_shl(1LL, offset), 1LL))) != (0LL)))
    {
#line 798 "WindowModule.cs"
        return true;
    }
#line 799 "WindowModule.cs"
    {
#line 799 "WindowModule.cs"
        int chunk = lowest;
        while (true)
        {
            if (!(((chunk) < (index))))
                break;
#line 800 "WindowModule.cs"
#line 800 "WindowModule.cs"
            long long csharp2cuda_temp_2 = (value)[chunk];
            if (((csharp2cuda_temp_2) != (0LL)))
            {
#line 801 "WindowModule.cs"
                return true;
            }
#line 799 "WindowModule.cs"
            int* csharp2cuda_temp_1 = &(chunk);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 802 "WindowModule.cs"
    return false;
}

#line 777 "WindowModule.cs"
__device__ long long mathblocks_window_exact_bits(const long long* value, int position, int count)
#line 779 "WindowModule.cs"
{
#line 780 "WindowModule.cs"
    int relative = csharp2cuda_i32_add(position, 2208);
#line 781 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(relative, 5);
#line 782 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(relative, 31);
#line 783 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (value)[index];
#line 783 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (value)[csharp2cuda_i32_add(index, 1)];
#line 783 "WindowModule.cs"
    unsigned long long word = ((((unsigned long long)(csharp2cuda_temp_0))) | (csharp2cuda_u64_shl(((unsigned long long)(csharp2cuda_temp_1)), 32)));
#line 784 "WindowModule.cs"
    unsigned long long result = csharp2cuda_u64_shr(word, offset);
#line 785 "WindowModule.cs"
    if (((offset) != (0)))
    {
#line 786 "WindowModule.cs"
#line 786 "WindowModule.cs"
        unsigned long long* csharp2cuda_temp_2 = &(result);
#line 786 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 786 "WindowModule.cs"
        long long csharp2cuda_temp_4 = (value)[csharp2cuda_i32_add(index, 2)];
        (*(csharp2cuda_temp_2) = ((csharp2cuda_temp_3) | (csharp2cuda_u64_shl(((unsigned long long)(csharp2cuda_temp_4)), csharp2cuda_i32_sub(64, offset)))));
    }
#line 787 "WindowModule.cs"
    return csharp2cuda_i64_from_bits(((result) & (((csharp2cuda_u64_shl(1ull, count)) - (1ull)))));
}

#line 666 "WindowModule.cs"
__device__ long long mathblocks_window_exact_carry(long long* target, int first, int last)
#line 668 "WindowModule.cs"
{
#line 669 "WindowModule.cs"
    long long carry = 0LL;
#line 670 "WindowModule.cs"
    {
#line 670 "WindowModule.cs"
        int index = first;
        while (true)
        {
            if (!(((index) <= (last))))
                break;
#line 671 "WindowModule.cs"
            {
#line 672 "WindowModule.cs"
                long long csharp2cuda_temp_1 = (target)[index];
#line 672 "WindowModule.cs"
                long long current = csharp2cuda_i64_add(csharp2cuda_temp_1, carry);
#line 673 "WindowModule.cs"
#line 673 "WindowModule.cs"
                long long* csharp2cuda_temp_2 = &(carry);
                (*(csharp2cuda_temp_2) = csharp2cuda_i64_shr(current, 32));
#line 674 "WindowModule.cs"
#line 674 "WindowModule.cs"
                long long* csharp2cuda_temp_3 = &((target)[index]);
                (*(csharp2cuda_temp_3) = csharp2cuda_i64_and(current, 4294967295LL));
            }
#line 670 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 676 "WindowModule.cs"
#line 676 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((target)[csharp2cuda_i32_add(last, 1)]);
#line 676 "WindowModule.cs"
    long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
    (*(csharp2cuda_temp_4) = csharp2cuda_i64_add(csharp2cuda_temp_5, carry));
#line 677 "WindowModule.cs"
    return (target)[csharp2cuda_i32_add(last, 1)];
}

#line 613 "WindowModule.cs"
__device__ void mathblocks_window_exact_clear(long long* accumulator)
#line 615 "WindowModule.cs"
{
#line 616 "WindowModule.cs"
    {
#line 616 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (282))))
                break;
#line 617 "WindowModule.cs"
#line 617 "WindowModule.cs"
            long long* csharp2cuda_temp_1 = &((accumulator)[index]);
            (*(csharp2cuda_temp_1) = 0LL);
#line 616 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 618 "WindowModule.cs"
#line 618 "WindowModule.cs"
    long long* csharp2cuda_temp_2 = &((accumulator)[282]);
    (*(csharp2cuda_temp_2) = 141LL);
#line 619 "WindowModule.cs"
#line 619 "WindowModule.cs"
    long long* csharp2cuda_temp_3 = &((accumulator)[283]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i64_neg(1LL));
#line 620 "WindowModule.cs"
#line 620 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((accumulator)[284]);
    (*(csharp2cuda_temp_4) = 0LL);
}

#line 757 "WindowModule.cs"
__device__ int mathblocks_window_exact_load(long long* accumulator, bool* negative)
#line 759 "WindowModule.cs"
{
#line 760 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 761 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[282];
#line 761 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_0);
#line 762 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (accumulator)[283];
#line 762 "WindowModule.cs"
    int highest = csharp2cuda_i32_from_bits(csharp2cuda_temp_1);
#line 763 "WindowModule.cs"
    {
#line 763 "WindowModule.cs"
        int index = lowest;
        while (true)
        {
            if (!(((index) <= (highest))))
                break;
#line 764 "WindowModule.cs"
#line 764 "WindowModule.cs"
            long long* csharp2cuda_temp_3 = &((scratch)[index]);
#line 764 "WindowModule.cs"
            long long csharp2cuda_temp_4 = (accumulator)[index];
            (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 763 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 765 "WindowModule.cs"
    {
#line 765 "WindowModule.cs"
        int index = csharp2cuda_i32_add(highest, 1);
        while (true)
        {
            if (!(((index) <= (csharp2cuda_i32_add(highest, 4)))))
                break;
#line 766 "WindowModule.cs"
#line 766 "WindowModule.cs"
            long long* csharp2cuda_temp_6 = &((scratch)[index]);
            (*(csharp2cuda_temp_6) = 0LL);
#line 765 "WindowModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
#line 767 "WindowModule.cs"
#line 767 "WindowModule.cs"
    bool* csharp2cuda_temp_7 = negative;
#line 767 "WindowModule.cs"
    long long csharp2cuda_temp_8 = mathblocks_window_exact_carry(scratch, lowest, highest);
    (*(csharp2cuda_temp_7) = ((csharp2cuda_temp_8) < (0LL)));
#line 768 "WindowModule.cs"
    if (*(negative))
#line 769 "WindowModule.cs"
    {
#line 770 "WindowModule.cs"
        mathblocks_window_exact_negate(scratch, lowest, csharp2cuda_i32_add(highest, 1));
#line 771 "WindowModule.cs"
        mathblocks_window_exact_carry(scratch, lowest, csharp2cuda_i32_add(highest, 1));
    }
#line 773 "WindowModule.cs"
    return csharp2cuda_i32_add(highest, 1);
}

#line 680 "WindowModule.cs"
__device__ void mathblocks_window_exact_negate(long long* target, int first, int last)
#line 682 "WindowModule.cs"
{
#line 683 "WindowModule.cs"
    {
#line 683 "WindowModule.cs"
        int index = first;
        while (true)
        {
            if (!(((index) <= (last))))
                break;
#line 684 "WindowModule.cs"
#line 684 "WindowModule.cs"
            long long* csharp2cuda_temp_1 = &((target)[index]);
#line 684 "WindowModule.cs"
            long long csharp2cuda_temp_2 = (target)[index];
            (*(csharp2cuda_temp_1) = csharp2cuda_i64_neg(csharp2cuda_temp_2));
#line 683 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 842 "WindowModule.cs"
__device__ void mathblocks_window_exact_read_pair(long long* accumulator, double* high, double* low)
#line 844 "WindowModule.cs"
{
#line 845 "WindowModule.cs"
#line 845 "WindowModule.cs"
    double* csharp2cuda_temp_0 = high;
    (*(csharp2cuda_temp_0) = 0.0);
#line 846 "WindowModule.cs"
#line 846 "WindowModule.cs"
    double* csharp2cuda_temp_1 = low;
    (*(csharp2cuda_temp_1) = 0.0);
#line 847 "WindowModule.cs"
#line 847 "WindowModule.cs"
    long long csharp2cuda_temp_2 = (accumulator)[283];
    if (((csharp2cuda_temp_2) < (0LL)))
    {
#line 848 "WindowModule.cs"
        return;
    }
#line 849 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 850 "WindowModule.cs"
    long long csharp2cuda_temp_3 = (accumulator)[282];
#line 850 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_3);
#line 851 "WindowModule.cs"
    bool negative = false;
#line 852 "WindowModule.cs"
    bool* csharp2cuda_temp_4 = &(negative);
#line 852 "WindowModule.cs"
    int top = mathblocks_window_exact_load(accumulator, csharp2cuda_temp_4);
#line 853 "WindowModule.cs"
#line 853 "WindowModule.cs"
    double* csharp2cuda_temp_5 = high;
#line 853 "WindowModule.cs"
    double csharp2cuda_temp_6 = mathblocks_window_exact_round(scratch, lowest, top, false);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 854 "WindowModule.cs"
#line 854 "WindowModule.cs"
    double csharp2cuda_temp_7 = *(high);
    if ((!(isfinite(csharp2cuda_temp_7))))
#line 855 "WindowModule.cs"
    {
#line 856 "WindowModule.cs"
#line 856 "WindowModule.cs"
        double* csharp2cuda_temp_8 = high;
#line 856 "WindowModule.cs"
        double csharp2cuda_temp_9;
#line 856 "WindowModule.cs"
        if (negative)
        {
#line 856 "WindowModule.cs"
            double csharp2cuda_temp_10 = *(high);
#line 856 "WindowModule.cs"
            csharp2cuda_temp_9 = (-(csharp2cuda_temp_10));
        }
        else
        {
#line 856 "WindowModule.cs"
            csharp2cuda_temp_9 = *(high);
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 857 "WindowModule.cs"
        return;
    }
#line 859 "WindowModule.cs"
#line 859 "WindowModule.cs"
    double csharp2cuda_temp_11 = *(high);
    mathblocks_window_exact_add_to(scratch, csharp2cuda_temp_11, 0, true);
#line 860 "WindowModule.cs"
    long long csharp2cuda_temp_12 = mathblocks_window_exact_carry(scratch, lowest, top);
#line 860 "WindowModule.cs"
    bool rest_negative = ((csharp2cuda_temp_12) < (0LL));
#line 861 "WindowModule.cs"
    if (rest_negative)
#line 862 "WindowModule.cs"
    {
#line 863 "WindowModule.cs"
        mathblocks_window_exact_negate(scratch, lowest, csharp2cuda_i32_add(top, 1));
#line 864 "WindowModule.cs"
        mathblocks_window_exact_carry(scratch, lowest, csharp2cuda_i32_add(top, 1));
    }
#line 866 "WindowModule.cs"
#line 866 "WindowModule.cs"
    double* csharp2cuda_temp_13 = low;
#line 866 "WindowModule.cs"
    double csharp2cuda_temp_14 = mathblocks_window_exact_round(scratch, lowest, csharp2cuda_i32_add(top, 1), false);
    (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
#line 867 "WindowModule.cs"
    if (rest_negative)
    {
#line 868 "WindowModule.cs"
#line 868 "WindowModule.cs"
        double* csharp2cuda_temp_15 = low;
#line 868 "WindowModule.cs"
        double csharp2cuda_temp_16 = *(low);
        (*(csharp2cuda_temp_15) = (-(csharp2cuda_temp_16)));
    }
#line 869 "WindowModule.cs"
    if (negative)
#line 870 "WindowModule.cs"
    {
#line 871 "WindowModule.cs"
#line 871 "WindowModule.cs"
        double* csharp2cuda_temp_17 = high;
#line 871 "WindowModule.cs"
        double csharp2cuda_temp_18 = *(high);
        (*(csharp2cuda_temp_17) = (-(csharp2cuda_temp_18)));
#line 872 "WindowModule.cs"
#line 872 "WindowModule.cs"
        double* csharp2cuda_temp_19 = low;
#line 872 "WindowModule.cs"
        double csharp2cuda_temp_20 = *(low);
        (*(csharp2cuda_temp_19) = (-(csharp2cuda_temp_20)));
    }
}

#line 879 "WindowModule.cs"
__device__ double mathblocks_window_exact_read_quotient(long long* accumulator, int divisor)
#line 881 "WindowModule.cs"
{
#line 882 "WindowModule.cs"
#line 882 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[283];
    if (((csharp2cuda_temp_0) < (0LL)))
    {
#line 883 "WindowModule.cs"
        return 0.0;
    }
#line 884 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 885 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (accumulator)[282];
#line 885 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_1);
#line 886 "WindowModule.cs"
    bool negative = false;
#line 887 "WindowModule.cs"
    bool* csharp2cuda_temp_2 = &(negative);
#line 887 "WindowModule.cs"
    int top = mathblocks_window_exact_load(accumulator, csharp2cuda_temp_2);
#line 888 "WindowModule.cs"
    int leading = top;
#line 889 "WindowModule.cs"
    while (true)
    {
#line 889 "WindowModule.cs"
        bool csharp2cuda_temp_3;
#line 889 "WindowModule.cs"
        if (((leading) > (lowest)))
        {
#line 889 "WindowModule.cs"
            long long csharp2cuda_temp_4 = (scratch)[leading];
#line 889 "WindowModule.cs"
            csharp2cuda_temp_3 = ((csharp2cuda_temp_4) == (0LL));
        }
        else
        {
#line 889 "WindowModule.cs"
            csharp2cuda_temp_3 = false;
        }
        if (!(csharp2cuda_temp_3))
            break;
#line 890 "WindowModule.cs"
#line 890 "WindowModule.cs"
        int* csharp2cuda_temp_5 = &(leading);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
    }
#line 891 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 891 "WindowModule.cs"
    if (((csharp2cuda_i32_sub(leading, 4)) < (lowest)))
    {
#line 891 "WindowModule.cs"
        csharp2cuda_temp_6 = csharp2cuda_i32_sub(leading, 4);
    }
    else
    {
#line 891 "WindowModule.cs"
        csharp2cuda_temp_6 = lowest;
    }
#line 891 "WindowModule.cs"
    int start = csharp2cuda_temp_6;
#line 892 "WindowModule.cs"
    if (((start) < (0)))
    {
#line 893 "WindowModule.cs"
#line 893 "WindowModule.cs"
        int* csharp2cuda_temp_7 = &(start);
        (*(csharp2cuda_temp_7) = 0);
    }
#line 894 "WindowModule.cs"
    long long remainder = 0LL;
#line 895 "WindowModule.cs"
    {
#line 895 "WindowModule.cs"
        int index = csharp2cuda_i32_add(top, 1);
        while (true)
        {
            if (!(((index) >= (start))))
                break;
#line 896 "WindowModule.cs"
            {
#line 897 "WindowModule.cs"
                long long csharp2cuda_temp_9 = (scratch)[index];
#line 897 "WindowModule.cs"
                long long current = csharp2cuda_i64_or(csharp2cuda_i64_shl(remainder, 32), csharp2cuda_temp_9);
#line 898 "WindowModule.cs"
#line 898 "WindowModule.cs"
                long long* csharp2cuda_temp_10 = &((scratch)[index]);
#line 898 "WindowModule.cs"
                long long csharp2cuda_temp_11 = csharp2cuda_i64_div(current, ((long long)(divisor)));
                (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
#line 899 "WindowModule.cs"
#line 899 "WindowModule.cs"
                long long* csharp2cuda_temp_12 = &(remainder);
#line 899 "WindowModule.cs"
                long long csharp2cuda_temp_13 = csharp2cuda_i64_rem(current, ((long long)(divisor)));
                (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
            }
#line 895 "WindowModule.cs"
            int* csharp2cuda_temp_8 = &(index);
            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_8));
        }
    }
#line 901 "WindowModule.cs"
    double result = mathblocks_window_exact_round(scratch, start, csharp2cuda_i32_add(top, 1), ((remainder) != (0LL)));
#line 902 "WindowModule.cs"
    {
#line 902 "WindowModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (lowest))))
                break;
#line 903 "WindowModule.cs"
#line 903 "WindowModule.cs"
            long long* csharp2cuda_temp_15 = &((scratch)[index]);
            (*(csharp2cuda_temp_15) = 0LL);
#line 902 "WindowModule.cs"
            int* csharp2cuda_temp_14 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
#line 904 "WindowModule.cs"
#line 904 "WindowModule.cs"
    double csharp2cuda_temp_16;
#line 904 "WindowModule.cs"
    if (negative)
    {
#line 904 "WindowModule.cs"
        csharp2cuda_temp_16 = (-(result));
    }
    else
    {
#line 904 "WindowModule.cs"
        csharp2cuda_temp_16 = result;
    }
    return csharp2cuda_temp_16;
}

#line 807 "WindowModule.cs"
__device__ double mathblocks_window_exact_round(const long long* value, int lowest, int top, bool sticky)
#line 809 "WindowModule.cs"
{
#line 810 "WindowModule.cs"
    int chunk = top;
#line 811 "WindowModule.cs"
    while (true)
    {
#line 811 "WindowModule.cs"
        bool csharp2cuda_temp_0;
#line 811 "WindowModule.cs"
        if (((chunk) >= (lowest)))
        {
#line 811 "WindowModule.cs"
            long long csharp2cuda_temp_1 = (value)[chunk];
#line 811 "WindowModule.cs"
            csharp2cuda_temp_0 = ((csharp2cuda_temp_1) == (0LL));
        }
        else
        {
#line 811 "WindowModule.cs"
            csharp2cuda_temp_0 = false;
        }
        if (!(csharp2cuda_temp_0))
            break;
#line 812 "WindowModule.cs"
#line 812 "WindowModule.cs"
        int* csharp2cuda_temp_2 = &(chunk);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_2));
    }
#line 813 "WindowModule.cs"
    if (((chunk) < (lowest)))
    {
#line 814 "WindowModule.cs"
        return 0.0;
    }
#line 815 "WindowModule.cs"
    int bit = 31;
#line 816 "WindowModule.cs"
    while (true)
    {
#line 816 "WindowModule.cs"
        long long csharp2cuda_temp_3 = (value)[chunk];
        if (!(((csharp2cuda_i64_and(csharp2cuda_i64_shr(csharp2cuda_temp_3, bit), 1LL)) == (0LL))))
            break;
#line 817 "WindowModule.cs"
#line 817 "WindowModule.cs"
        int* csharp2cuda_temp_4 = &(bit);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_4));
    }
#line 818 "WindowModule.cs"
    int most = csharp2cuda_i32_add(csharp2cuda_i32_add(csharp2cuda_i32_neg(2208), csharp2cuda_i32_mul(32, chunk)), bit);
#line 819 "WindowModule.cs"
    int csharp2cuda_temp_5;
#line 819 "WindowModule.cs"
    if (((csharp2cuda_i32_sub(most, 52)) < (csharp2cuda_i32_neg(1074))))
    {
#line 819 "WindowModule.cs"
        csharp2cuda_temp_5 = csharp2cuda_i32_neg(1074);
    }
    else
    {
#line 819 "WindowModule.cs"
        csharp2cuda_temp_5 = csharp2cuda_i32_sub(most, 52);
    }
#line 819 "WindowModule.cs"
    int least = csharp2cuda_temp_5;
#line 820 "WindowModule.cs"
    int count = csharp2cuda_i32_add(csharp2cuda_i32_sub(most, least), 1);
#line 821 "WindowModule.cs"
    long long csharp2cuda_temp_6;
#line 821 "WindowModule.cs"
    if (((count) > (0)))
    {
#line 821 "WindowModule.cs"
        csharp2cuda_temp_6 = mathblocks_window_exact_bits(value, least, count);
    }
    else
    {
#line 821 "WindowModule.cs"
        csharp2cuda_temp_6 = 0LL;
    }
#line 821 "WindowModule.cs"
    long long significand = csharp2cuda_temp_6;
#line 822 "WindowModule.cs"
    long long csharp2cuda_temp_7 = mathblocks_window_exact_bits(value, csharp2cuda_i32_sub(least, 1), 1);
#line 822 "WindowModule.cs"
    bool round = ((csharp2cuda_temp_7) != (0LL));
#line 823 "WindowModule.cs"
    bool csharp2cuda_temp_8;
#line 823 "WindowModule.cs"
    if (!(sticky))
    {
#line 823 "WindowModule.cs"
        csharp2cuda_temp_8 = mathblocks_window_exact_any_below(value, lowest, csharp2cuda_i32_sub(least, 1));
    }
    else
    {
#line 823 "WindowModule.cs"
        csharp2cuda_temp_8 = true;
    }
#line 823 "WindowModule.cs"
    bool below = csharp2cuda_temp_8;
#line 824 "WindowModule.cs"
#line 824 "WindowModule.cs"
    bool csharp2cuda_temp_9;
#line 824 "WindowModule.cs"
    if (round)
    {
#line 824 "WindowModule.cs"
        bool csharp2cuda_temp_10;
#line 824 "WindowModule.cs"
        if (!(below))
        {
#line 824 "WindowModule.cs"
            csharp2cuda_temp_10 = ((csharp2cuda_i64_and(significand, 1LL)) != (0LL));
        }
        else
        {
#line 824 "WindowModule.cs"
            csharp2cuda_temp_10 = true;
        }
#line 824 "WindowModule.cs"
        csharp2cuda_temp_9 = csharp2cuda_temp_10;
    }
    else
    {
#line 824 "WindowModule.cs"
        csharp2cuda_temp_9 = false;
    }
    if (csharp2cuda_temp_9)
    {
#line 825 "WindowModule.cs"
#line 825 "WindowModule.cs"
        long long* csharp2cuda_temp_11 = &(significand);
        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_11));
    }
#line 826 "WindowModule.cs"
    if (((significand) == (csharp2cuda_i64_shl(1LL, 53))))
#line 827 "WindowModule.cs"
    {
#line 828 "WindowModule.cs"
#line 828 "WindowModule.cs"
        long long* csharp2cuda_temp_12 = &(significand);
        (*(csharp2cuda_temp_12) = csharp2cuda_i64_shl(1LL, 52));
#line 829 "WindowModule.cs"
#line 829 "WindowModule.cs"
        int* csharp2cuda_temp_13 = &(least);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
    }
#line 831 "WindowModule.cs"
    if (((significand) >= (csharp2cuda_i64_shl(1LL, 52))))
#line 832 "WindowModule.cs"
    {
#line 833 "WindowModule.cs"
        int biased = csharp2cuda_i32_add(least, 1075);
#line 834 "WindowModule.cs"
        if (((biased) >= (2047)))
        {
#line 835 "WindowModule.cs"
            return __longlong_as_double(9218868437227405312LL);
        }
#line 836 "WindowModule.cs"
        return __longlong_as_double(csharp2cuda_i64_or(csharp2cuda_i64_shl(((long long)(biased)), 52), csharp2cuda_i64_sub(significand, csharp2cuda_i64_shl(1LL, 52))));
    }
#line 838 "WindowModule.cs"
    return __longlong_as_double(significand);
}

#line 916 "WindowModule.cs"
__device__ void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e)
#line 918 "WindowModule.cs"
{
#line 919 "WindowModule.cs"
#line 919 "WindowModule.cs"
    double* csharp2cuda_temp_0 = s;
    (*(csharp2cuda_temp_0) = __dadd_rn(a, b));
#line 920 "WindowModule.cs"
#line 920 "WindowModule.cs"
    double* csharp2cuda_temp_1 = e;
#line 920 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(s);
    (*(csharp2cuda_temp_1) = __dsub_rn(b, __dsub_rn(csharp2cuda_temp_2, a)));
}

#line 969 "WindowModule.cs"
__device__ bool mathblocks_window_in_range(double value, double largest)
#line 971 "WindowModule.cs"
{
#line 972 "WindowModule.cs"
#line 972 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 972 "WindowModule.cs"
    if (!(((value) == (0.0))))
    {
#line 973 "WindowModule.cs"
        bool csharp2cuda_temp_1;
#line 973 "WindowModule.cs"
        if (((fabs(value)) >= (mathblocks_window_power_of_two(csharp2cuda_i32_neg(968)))))
        {
#line 973 "WindowModule.cs"
            csharp2cuda_temp_1 = ((fabs(value)) <= (largest));
        }
        else
        {
#line 973 "WindowModule.cs"
            csharp2cuda_temp_1 = false;
        }
#line 972 "WindowModule.cs"
        csharp2cuda_temp_0 = csharp2cuda_temp_1;
    }
    else
    {
#line 972 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
    return csharp2cuda_temp_0;
}

#line 229 "WindowModule.cs"
__device__ double* mathblocks_window_merge_sort(double* values, double* buffer, int count)
#line 231 "WindowModule.cs"
{
#line 232 "WindowModule.cs"
    double* source = values;
#line 233 "WindowModule.cs"
    double* target = buffer;
#line 234 "WindowModule.cs"
    {
#line 234 "WindowModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 235 "WindowModule.cs"
            {
#line 236 "WindowModule.cs"
                {
#line 236 "WindowModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 237 "WindowModule.cs"
                        {
#line 238 "WindowModule.cs"
                            int csharp2cuda_temp_4;
#line 238 "WindowModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 238 "WindowModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 238 "WindowModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 238 "WindowModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 239 "WindowModule.cs"
                            int csharp2cuda_temp_5;
#line 239 "WindowModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 239 "WindowModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 239 "WindowModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 239 "WindowModule.cs"
                            int end = csharp2cuda_temp_5;
#line 240 "WindowModule.cs"
                            int left = start;
#line 241 "WindowModule.cs"
                            int right = middle;
#line 242 "WindowModule.cs"
                            int position = start;
#line 243 "WindowModule.cs"
                            while (true)
                            {
#line 243 "WindowModule.cs"
                                bool csharp2cuda_temp_6;
#line 243 "WindowModule.cs"
                                if (((left) < (middle)))
                                {
#line 243 "WindowModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 243 "WindowModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 244 "WindowModule.cs"
#line 244 "WindowModule.cs"
                                int* csharp2cuda_temp_7 = &(position);
#line 244 "WindowModule.cs"
                                int csharp2cuda_temp_8 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
#line 244 "WindowModule.cs"
                                double* csharp2cuda_temp_9 = &((target)[csharp2cuda_temp_8]);
#line 244 "WindowModule.cs"
                                double csharp2cuda_temp_10 = (source)[right];
#line 244 "WindowModule.cs"
                                double csharp2cuda_temp_11 = (source)[left];
#line 244 "WindowModule.cs"
                                double csharp2cuda_temp_12;
#line 244 "WindowModule.cs"
                                if (((csharp2cuda_temp_10) < (csharp2cuda_temp_11)))
                                {
#line 244 "WindowModule.cs"
                                    int* csharp2cuda_temp_13 = &(right);
#line 244 "WindowModule.cs"
                                    int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 244 "WindowModule.cs"
                                    csharp2cuda_temp_12 = (source)[csharp2cuda_temp_14];
                                }
                                else
                                {
#line 244 "WindowModule.cs"
                                    int* csharp2cuda_temp_15 = &(left);
#line 244 "WindowModule.cs"
                                    int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 244 "WindowModule.cs"
                                    csharp2cuda_temp_12 = (source)[csharp2cuda_temp_16];
                                }
                                (*(csharp2cuda_temp_9) = csharp2cuda_temp_12);
                            }
#line 245 "WindowModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 246 "WindowModule.cs"
#line 246 "WindowModule.cs"
                                int* csharp2cuda_temp_17 = &(position);
#line 246 "WindowModule.cs"
                                int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 246 "WindowModule.cs"
                                double* csharp2cuda_temp_19 = &((target)[csharp2cuda_temp_18]);
#line 246 "WindowModule.cs"
                                int* csharp2cuda_temp_20 = &(left);
#line 246 "WindowModule.cs"
                                int csharp2cuda_temp_21 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
#line 246 "WindowModule.cs"
                                double csharp2cuda_temp_22 = (source)[csharp2cuda_temp_21];
                                (*(csharp2cuda_temp_19) = csharp2cuda_temp_22);
                            }
#line 247 "WindowModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 248 "WindowModule.cs"
#line 248 "WindowModule.cs"
                                int* csharp2cuda_temp_23 = &(position);
#line 248 "WindowModule.cs"
                                int csharp2cuda_temp_24 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_23));
#line 248 "WindowModule.cs"
                                double* csharp2cuda_temp_25 = &((target)[csharp2cuda_temp_24]);
#line 248 "WindowModule.cs"
                                int* csharp2cuda_temp_26 = &(right);
#line 248 "WindowModule.cs"
                                int csharp2cuda_temp_27 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_26));
#line 248 "WindowModule.cs"
                                double csharp2cuda_temp_28 = (source)[csharp2cuda_temp_27];
                                (*(csharp2cuda_temp_25) = csharp2cuda_temp_28);
                            }
                        }
#line 236 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 236 "WindowModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 250 "WindowModule.cs"
                double* sorted = target;
#line 251 "WindowModule.cs"
#line 251 "WindowModule.cs"
                double** csharp2cuda_temp_29 = &(target);
                (*(csharp2cuda_temp_29) = source);
#line 252 "WindowModule.cs"
#line 252 "WindowModule.cs"
                double** csharp2cuda_temp_30 = &(source);
                (*(csharp2cuda_temp_30) = sorted);
            }
#line 234 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 234 "WindowModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 254 "WindowModule.cs"
    return source;
}

#line 607 "WindowModule.cs"
__device__ double mathblocks_window_power_of_two(int exponent)
#line 609 "WindowModule.cs"
{
#line 610 "WindowModule.cs"
    return __longlong_as_double(csharp2cuda_i64_shl(((long long)(csharp2cuda_i32_add(exponent, 1023))), 52));
}

#line 1145 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread)
#line 1147 "WindowModule.cs"
{
#line 1148 "WindowModule.cs"
    if (((thread) != (0)))
    {
#line 1149 "WindowModule.cs"
        return;
    }
#line 1150 "WindowModule.cs"
#line 1150 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &((output)->scalar_value);
    (*(csharp2cuda_temp_0) = 0.0);
#line 1151 "WindowModule.cs"
#line 1151 "WindowModule.cs"
    int* csharp2cuda_temp_1 = &((output)->boolean_value);
    (*(csharp2cuda_temp_1) = 0);
#line 1152 "WindowModule.cs"
#line 1152 "WindowModule.cs"
    int* csharp2cuda_temp_2 = &((output)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 1153 "WindowModule.cs"
#line 1153 "WindowModule.cs"
    int* csharp2cuda_temp_3 = &((output)->rows);
#line 1153 "WindowModule.cs"
    int csharp2cuda_temp_4;
#line 1153 "WindowModule.cs"
    if (valid)
    {
#line 1153 "WindowModule.cs"
        csharp2cuda_temp_4 = count;
    }
    else
    {
#line 1153 "WindowModule.cs"
        csharp2cuda_temp_4 = 0;
    }
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 1154 "WindowModule.cs"
#line 1154 "WindowModule.cs"
    int* csharp2cuda_temp_5 = &((output)->count);
#line 1154 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 1154 "WindowModule.cs"
    if (valid)
    {
#line 1154 "WindowModule.cs"
        csharp2cuda_temp_6 = count;
    }
    else
    {
#line 1154 "WindowModule.cs"
        csharp2cuda_temp_6 = 0;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 1155 "WindowModule.cs"
#line 1155 "WindowModule.cs"
    int* csharp2cuda_temp_7 = &((output)->valid);
    (*(csharp2cuda_temp_7) = valid);
}

#line 1161 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity)
#line 1170 "WindowModule.cs"
{
#line 1171 "WindowModule.cs"
    int source = csharp2cuda_i32_div(opcode, 2);
#line 1172 "WindowModule.cs"
    int csharp2cuda_temp_0 = csharp2cuda_i32_rem(opcode, 2);
#line 1172 "WindowModule.cs"
    bool sibling = ((csharp2cuda_temp_0) != (0));
#line 1173 "WindowModule.cs"
    int arity = mathblocks_window_source_arity(source);
#line 1174 "WindowModule.cs"
    int series = mathblocks_window_series_count(source);
#line 1175 "WindowModule.cs"
    bool csharp2cuda_temp_1;
#line 1175 "WindowModule.cs"
    if (((opcode) >= (0)))
    {
#line 1175 "WindowModule.cs"
        csharp2cuda_temp_1 = ((source) < (59));
    }
    else
    {
#line 1175 "WindowModule.cs"
        csharp2cuda_temp_1 = false;
    }
#line 1175 "WindowModule.cs"
    bool csharp2cuda_temp_2;
#line 1175 "WindowModule.cs"
    if (csharp2cuda_temp_1)
    {
#line 1175 "WindowModule.cs"
        int csharp2cuda_temp_3;
#line 1175 "WindowModule.cs"
        if (sibling)
        {
#line 1175 "WindowModule.cs"
            csharp2cuda_temp_3 = 1;
        }
        else
        {
#line 1175 "WindowModule.cs"
            csharp2cuda_temp_3 = 2;
        }
#line 1175 "WindowModule.cs"
        csharp2cuda_temp_2 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_3)));
    }
    else
    {
#line 1175 "WindowModule.cs"
        csharp2cuda_temp_2 = false;
    }
#line 1175 "WindowModule.cs"
    bool valid = csharp2cuda_temp_2;
#line 1176 "WindowModule.cs"
    {
#line 1176 "WindowModule.cs"
        int index = 0;
        while (true)
        {
#line 1176 "WindowModule.cs"
            bool csharp2cuda_temp_5;
#line 1176 "WindowModule.cs"
            if (valid)
            {
#line 1176 "WindowModule.cs"
                csharp2cuda_temp_5 = ((index) < (input_count));
            }
            else
            {
#line 1176 "WindowModule.cs"
                csharp2cuda_temp_5 = false;
            }
            if (!(csharp2cuda_temp_5))
                break;
#line 1177 "WindowModule.cs"
#line 1177 "WindowModule.cs"
            MathBlockSlot* csharp2cuda_temp_6 = (inputs)[index];
#line 1177 "WindowModule.cs"
            bool csharp2cuda_temp_7;
#line 1177 "WindowModule.cs"
            if (!(((((void*)(csharp2cuda_temp_6))) == (((void*)(nullptr))))))
            {
#line 1177 "WindowModule.cs"
                MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 1177 "WindowModule.cs"
                bool csharp2cuda_temp_9 = (csharp2cuda_temp_8)->valid;
#line 1177 "WindowModule.cs"
                csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
            }
            else
            {
#line 1177 "WindowModule.cs"
                csharp2cuda_temp_7 = true;
            }
            if (csharp2cuda_temp_7)
            {
#line 1178 "WindowModule.cs"
#line 1178 "WindowModule.cs"
                bool* csharp2cuda_temp_10 = &(valid);
                (*(csharp2cuda_temp_10) = false);
            }
#line 1176 "WindowModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 1179 "WindowModule.cs"
    if ((!(valid)))
#line 1180 "WindowModule.cs"
    {
#line 1181 "WindowModule.cs"
        mathblocks_window_publish(output, false, 0, thread);
#line 1182 "WindowModule.cs"
        return;
    }
#line 1185 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_11;
#line 1185 "WindowModule.cs"
    if (((input_count) > (0)))
    {
#line 1185 "WindowModule.cs"
        csharp2cuda_temp_11 = (inputs)[0];
    }
    else
    {
#line 1185 "WindowModule.cs"
        csharp2cuda_temp_11 = ((MathBlockSlot*)(nullptr));
    }
#line 1185 "WindowModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_11;
#line 1186 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_12;
#line 1186 "WindowModule.cs"
    if (((series) > (1)))
    {
#line 1186 "WindowModule.cs"
        csharp2cuda_temp_12 = (inputs)[1];
    }
    else
    {
#line 1186 "WindowModule.cs"
        csharp2cuda_temp_12 = ((MathBlockSlot*)(nullptr));
    }
#line 1186 "WindowModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_12;
#line 1187 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_13;
#line 1187 "WindowModule.cs"
    if (((arity) > (series)))
    {
#line 1187 "WindowModule.cs"
        csharp2cuda_temp_13 = (inputs)[series];
    }
    else
    {
#line 1187 "WindowModule.cs"
        csharp2cuda_temp_13 = ((MathBlockSlot*)(nullptr));
    }
#line 1187 "WindowModule.cs"
    const MathBlockSlot* first_parameter = csharp2cuda_temp_13;
#line 1188 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_14;
#line 1188 "WindowModule.cs"
    if (((arity) > (csharp2cuda_i32_add(series, 1))))
    {
#line 1188 "WindowModule.cs"
        csharp2cuda_temp_14 = (inputs)[csharp2cuda_i32_add(series, 1)];
    }
    else
    {
#line 1188 "WindowModule.cs"
        csharp2cuda_temp_14 = ((MathBlockSlot*)(nullptr));
    }
#line 1188 "WindowModule.cs"
    const MathBlockSlot* second_parameter = csharp2cuda_temp_14;
#line 1189 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_15 = (inputs)[arity];
#line 1189 "WindowModule.cs"
    const MathBlockSlot* width_input = csharp2cuda_temp_15;
#line 1190 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_16;
#line 1190 "WindowModule.cs"
    if (sibling)
    {
#line 1190 "WindowModule.cs"
        csharp2cuda_temp_16 = ((MathBlockSlot*)(nullptr));
    }
    else
    {
#line 1190 "WindowModule.cs"
        csharp2cuda_temp_16 = (inputs)[csharp2cuda_i32_add(arity, 1)];
    }
#line 1190 "WindowModule.cs"
    const MathBlockSlot* fill_input = csharp2cuda_temp_16;
#line 1191 "WindowModule.cs"
    int count = (first)->count;
#line 1192 "WindowModule.cs"
    int width = 0;
#line 1193 "WindowModule.cs"
#line 1193 "WindowModule.cs"
    bool csharp2cuda_temp_17;
#line 1193 "WindowModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 1193 "WindowModule.cs"
        int csharp2cuda_temp_18 = (second)->count;
#line 1193 "WindowModule.cs"
        csharp2cuda_temp_17 = ((csharp2cuda_temp_18) != (count));
    }
    else
    {
#line 1193 "WindowModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
    {
#line 1194 "WindowModule.cs"
#line 1194 "WindowModule.cs"
        bool* csharp2cuda_temp_19 = &(valid);
        (*(csharp2cuda_temp_19) = false);
    }
#line 1195 "WindowModule.cs"
#line 1195 "WindowModule.cs"
    double csharp2cuda_temp_20 = (width_input)->scalar_value;
#line 1195 "WindowModule.cs"
    int* csharp2cuda_temp_21 = &(width);
#line 1195 "WindowModule.cs"
    bool csharp2cuda_temp_22 = mathblocks_sequence_positive_integer(csharp2cuda_temp_20, csharp2cuda_temp_21);
#line 1195 "WindowModule.cs"
    bool csharp2cuda_temp_23;
#line 1195 "WindowModule.cs"
    if (!((!(csharp2cuda_temp_22))))
    {
#line 1195 "WindowModule.cs"
        csharp2cuda_temp_23 = ((width) > (count));
    }
    else
    {
#line 1195 "WindowModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
    {
#line 1196 "WindowModule.cs"
#line 1196 "WindowModule.cs"
        bool* csharp2cuda_temp_24 = &(valid);
        (*(csharp2cuda_temp_24) = false);
    }
#line 1197 "WindowModule.cs"
#line 1197 "WindowModule.cs"
    int csharp2cuda_temp_25 = (output)->capacity;
    if (((count) > (csharp2cuda_temp_25)))
    {
#line 1198 "WindowModule.cs"
#line 1198 "WindowModule.cs"
        bool* csharp2cuda_temp_26 = &(valid);
        (*(csharp2cuda_temp_26) = false);
    }
#line 1199 "WindowModule.cs"
    long long csharp2cuda_temp_27;
#line 1199 "WindowModule.cs"
    if (valid)
    {
#line 1199 "WindowModule.cs"
        csharp2cuda_temp_27 = mathblocks_window_scratch_count(source, width);
    }
    else
    {
#line 1199 "WindowModule.cs"
        csharp2cuda_temp_27 = ((long long)(0));
    }
#line 1199 "WindowModule.cs"
    long long required = csharp2cuda_temp_27;
#line 1200 "WindowModule.cs"
    long long csharp2cuda_temp_28;
#line 1200 "WindowModule.cs"
    if (((scratch_capacity) < (0)))
    {
#line 1200 "WindowModule.cs"
        csharp2cuda_temp_28 = required;
    }
    else
    {
#line 1200 "WindowModule.cs"
        csharp2cuda_temp_28 = ((long long)(scratch_capacity));
    }
#line 1200 "WindowModule.cs"
    long long capacity = csharp2cuda_temp_28;
#line 1201 "WindowModule.cs"
#line 1201 "WindowModule.cs"
    bool csharp2cuda_temp_29;
#line 1201 "WindowModule.cs"
    if (!(((required) > (capacity))))
    {
#line 1201 "WindowModule.cs"
        bool csharp2cuda_temp_30;
#line 1201 "WindowModule.cs"
        if (((required) > (((long long)(0)))))
        {
#line 1201 "WindowModule.cs"
            unsigned long long csharp2cuda_temp_31 = (output)->scratch_pointer;
#line 1201 "WindowModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) == (((unsigned long long)(0))));
        }
        else
        {
#line 1201 "WindowModule.cs"
            csharp2cuda_temp_30 = false;
        }
#line 1201 "WindowModule.cs"
        csharp2cuda_temp_29 = csharp2cuda_temp_30;
    }
    else
    {
#line 1201 "WindowModule.cs"
        csharp2cuda_temp_29 = true;
    }
    if (csharp2cuda_temp_29)
    {
#line 1202 "WindowModule.cs"
#line 1202 "WindowModule.cs"
        bool* csharp2cuda_temp_32 = &(valid);
        (*(csharp2cuda_temp_32) = false);
    }
#line 1203 "WindowModule.cs"
    mathblocks_window_publish(output, valid, count, thread);
#line 1204 "WindowModule.cs"
    if ((!(valid)))
    {
#line 1205 "WindowModule.cs"
        return;
    }
#line 1207 "WindowModule.cs"
    double csharp2cuda_temp_33;
#line 1207 "WindowModule.cs"
    if (sibling)
    {
#line 1207 "WindowModule.cs"
        csharp2cuda_temp_33 = 0.0;
    }
    else
    {
#line 1207 "WindowModule.cs"
        csharp2cuda_temp_33 = (fill_input)->scalar_value;
    }
#line 1207 "WindowModule.cs"
    double fill = csharp2cuda_temp_33;
#line 1208 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_34 = (first)->data_pointer;
#line 1208 "WindowModule.cs"
    const double* a = ((double*)(csharp2cuda_temp_34));
#line 1209 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_35 = (first)->data_pointer;
#line 1209 "WindowModule.cs"
    const int* flags = ((int*)(csharp2cuda_temp_35));
#line 1210 "WindowModule.cs"
    double* csharp2cuda_temp_36;
#line 1210 "WindowModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 1210 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(nullptr));
    }
    else
    {
#line 1210 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_37 = (second)->data_pointer;
#line 1210 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(csharp2cuda_temp_37));
    }
#line 1210 "WindowModule.cs"
    const double* b = csharp2cuda_temp_36;
#line 1211 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_38 = (output)->data_pointer;
#line 1211 "WindowModule.cs"
    double* result = ((double*)(csharp2cuda_temp_38));
#line 1212 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_39 = (output)->data_pointer;
#line 1212 "WindowModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_39));
#line 1213 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_40 = (output)->scratch_pointer;
#line 1213 "WindowModule.cs"
    double* scratch = csharp2cuda_pointer_add(((double*)(csharp2cuda_temp_40)), csharp2cuda_i32_mul(thread, csharp2cuda_i32_from_bits(capacity)));
#line 1214 "WindowModule.cs"
#line 1214 "WindowModule.cs"
    bool csharp2cuda_temp_41;
#line 1214 "WindowModule.cs"
    if (!(((source) == (47))))
    {
#line 1214 "WindowModule.cs"
        csharp2cuda_temp_41 = ((source) == (48));
    }
    else
    {
#line 1214 "WindowModule.cs"
        csharp2cuda_temp_41 = true;
    }
#line 1214 "WindowModule.cs"
    bool csharp2cuda_temp_42;
#line 1214 "WindowModule.cs"
    if (!(csharp2cuda_temp_41))
    {
#line 1214 "WindowModule.cs"
        csharp2cuda_temp_42 = ((source) >= (53));
    }
    else
    {
#line 1214 "WindowModule.cs"
        csharp2cuda_temp_42 = true;
    }
    if (csharp2cuda_temp_42)
#line 1215 "WindowModule.cs"
    {
#line 1217 "WindowModule.cs"
        long long rows_per_thread = csharp2cuda_i64_div(csharp2cuda_i64_sub(csharp2cuda_i64_add(((long long)(count)), ((long long)(threads))), ((long long)(1))), ((long long)(threads)));
#line 1218 "WindowModule.cs"
        long long first_row = csharp2cuda_i64_mul(((long long)(thread)), rows_per_thread);
#line 1219 "WindowModule.cs"
        if (((first_row) >= (((long long)(count)))))
        {
#line 1220 "WindowModule.cs"
            return;
        }
#line 1221 "WindowModule.cs"
        long long csharp2cuda_temp_43;
#line 1221 "WindowModule.cs"
        if (((csharp2cuda_i64_sub(((long long)(count)), first_row)) < (rows_per_thread)))
        {
#line 1221 "WindowModule.cs"
            csharp2cuda_temp_43 = ((long long)(count));
        }
        else
        {
#line 1221 "WindowModule.cs"
            csharp2cuda_temp_43 = csharp2cuda_i64_add(first_row, rows_per_thread);
        }
#line 1221 "WindowModule.cs"
        long long last_row = csharp2cuda_temp_43;
#line 1222 "WindowModule.cs"
        if (((source) >= (53)))
#line 1223 "WindowModule.cs"
        {
#line 1224 "WindowModule.cs"
            mathblocks_window_accurate_rows(source, a, width, csharp2cuda_i32_from_bits(first_row), csharp2cuda_i32_from_bits(last_row), fill, sibling, result, boolean_result, ((long long*)(scratch)));
        }
        else
#line 1237 "WindowModule.cs"
        {
#line 1238 "WindowModule.cs"
#line 1241 "WindowModule.cs"
            double csharp2cuda_temp_44;
#line 1241 "WindowModule.cs"
            if (((source) == (47)))
            {
#line 1241 "WindowModule.cs"
                csharp2cuda_temp_44 = 0.5;
            }
            else
            {
#line 1241 "WindowModule.cs"
                csharp2cuda_temp_44 = (first_parameter)->scalar_value;
            }
            mathblocks_window_sorted_rows(a, width, csharp2cuda_temp_44, csharp2cuda_i32_from_bits(first_row), csharp2cuda_i32_from_bits(last_row), fill, sibling, result, boolean_result, scratch);
        }
#line 1250 "WindowModule.cs"
        return;
    }
#line 1252 "WindowModule.cs"
    {
#line 1252 "WindowModule.cs"
        int end = thread;
        while (true)
        {
            if (!(((end) < (count))))
                break;
#line 1253 "WindowModule.cs"
            {
#line 1254 "WindowModule.cs"
                bool row_valid = false;
#line 1255 "WindowModule.cs"
                double value = 0.0;
#line 1256 "WindowModule.cs"
                if (((end) >= (csharp2cuda_i32_sub(width, 1))))
#line 1257 "WindowModule.cs"
                {
#line 1259 "WindowModule.cs"
                    int start = csharp2cuda_i32_add(csharp2cuda_i32_sub(end, width), 1);
#line 1260 "WindowModule.cs"
#line 1260 "WindowModule.cs"
                    bool* csharp2cuda_temp_47 = &(row_valid);
#line 1269 "WindowModule.cs"
                    double* csharp2cuda_temp_48 = &(value);
#line 1260 "WindowModule.cs"
                    bool csharp2cuda_temp_49 = mathblocks_window_value(source, csharp2cuda_pointer_add(a, start), csharp2cuda_pointer_add(b, start), csharp2cuda_pointer_add(flags, start), width, first_parameter, second_parameter, scratch, csharp2cuda_temp_48);
                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_49);
                }
#line 1271 "WindowModule.cs"
                if (sibling)
                {
#line 1272 "WindowModule.cs"
#line 1272 "WindowModule.cs"
                    int* csharp2cuda_temp_50 = &((boolean_result)[end]);
                    (*(csharp2cuda_temp_50) = row_valid);
                }
                else
                {
#line 1274 "WindowModule.cs"
#line 1274 "WindowModule.cs"
                    double* csharp2cuda_temp_51 = &((result)[end]);
#line 1274 "WindowModule.cs"
                    double csharp2cuda_temp_52;
#line 1274 "WindowModule.cs"
                    if (row_valid)
                    {
#line 1274 "WindowModule.cs"
                        csharp2cuda_temp_52 = value;
                    }
                    else
                    {
#line 1274 "WindowModule.cs"
                        csharp2cuda_temp_52 = fill;
                    }
                    (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
                }
            }
#line 1252 "WindowModule.cs"
            int* csharp2cuda_temp_45 = &(end);
#line 1252 "WindowModule.cs"
            int csharp2cuda_temp_46 = *(csharp2cuda_temp_45);
            (*(csharp2cuda_temp_45) = csharp2cuda_i32_add(csharp2cuda_temp_46, threads));
        }
    }
}

#line 194 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width)
#line 196 "WindowModule.cs"
{
#line 197 "WindowModule.cs"
    long long count = ((long long)(width));
#line 198 "WindowModule.cs"
    switch (source)
    {
#line 200 "WindowModule.cs"
        case 3:
        case 44:
        case 47:
        case 48:
#line 204 "WindowModule.cs"
            return count;
#line 205 "WindowModule.cs"
        case 2:
        case 8:
        case 21:
#line 208 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, ((long long)(2)));
#line 209 "WindowModule.cs"
        case 22:
#line 210 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_sub(count, ((long long)(1))));
#line 211 "WindowModule.cs"
        case 15:
#line 212 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_add(count, ((long long)(1))));
#line 213 "WindowModule.cs"
        case 53:
        case 54:
#line 215 "WindowModule.cs"
            return ((long long)(285));
#line 216 "WindowModule.cs"
        case 55:
        case 56:
        case 57:
        case 58:
#line 220 "WindowModule.cs"
            return ((long long)(570));
#line 221 "WindowModule.cs"
        default:
#line 222 "WindowModule.cs"
            return ((long long)(0));
    }
}

#line 324 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count)
#line 326 "WindowModule.cs"
{
#line 327 "WindowModule.cs"
    double* sorted = mathblocks_window_merge_sort(scratch, csharp2cuda_pointer_add(scratch, count), count);
#line 328 "WindowModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 169 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source)
#line 171 "WindowModule.cs"
{
#line 172 "WindowModule.cs"
    switch (source)
    {
#line 174 "WindowModule.cs"
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
#line 186 "WindowModule.cs"
            return 2;
#line 187 "WindowModule.cs"
        default:
#line 188 "WindowModule.cs"
            return 1;
    }
}

#line 1084 "WindowModule.cs"
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
#line 1096 "WindowModule.cs"
{
#line 1097 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 1097 "WindowModule.cs"
    if (!(((probability) < (0.0))))
    {
#line 1097 "WindowModule.cs"
        csharp2cuda_temp_0 = ((probability) > (1.0));
    }
    else
    {
#line 1097 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 1097 "WindowModule.cs"
    bool probability_valid = (!(csharp2cuda_temp_0));
#line 1098 "WindowModule.cs"
    int csharp2cuda_temp_1;
#line 1098 "WindowModule.cs"
    if (((csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1)) < (0)))
    {
#line 1098 "WindowModule.cs"
        csharp2cuda_temp_1 = 0;
    }
    else
    {
#line 1098 "WindowModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1);
    }
#line 1098 "WindowModule.cs"
    int begin = csharp2cuda_temp_1;
#line 1099 "WindowModule.cs"
    int size = 0;
#line 1100 "WindowModule.cs"
    {
#line 1100 "WindowModule.cs"
        int row = begin;
        while (true)
        {
            if (!(((row) < (last_row))))
                break;
#line 1101 "WindowModule.cs"
            {
#line 1102 "WindowModule.cs"
                if (((csharp2cuda_i32_sub(row, width)) >= (begin)))
#line 1103 "WindowModule.cs"
                {
#line 1104 "WindowModule.cs"
                    double leaving = (x)[csharp2cuda_i32_sub(row, width)];
#line 1105 "WindowModule.cs"
                    int low = 0;
#line 1106 "WindowModule.cs"
                    int high = size;
#line 1107 "WindowModule.cs"
                    while (true)
                    {
                        if (!(((low) < (high))))
                            break;
#line 1108 "WindowModule.cs"
                        {
#line 1109 "WindowModule.cs"
                            int middle = csharp2cuda_i32_div(csharp2cuda_i32_add(low, high), 2);
#line 1110 "WindowModule.cs"
#line 1110 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (sorted)[middle];
                            if (((csharp2cuda_temp_3) < (leaving)))
                            {
#line 1111 "WindowModule.cs"
#line 1111 "WindowModule.cs"
                                int* csharp2cuda_temp_4 = &(low);
                                (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(middle, 1));
                            }
                            else
                            {
#line 1113 "WindowModule.cs"
#line 1113 "WindowModule.cs"
                                int* csharp2cuda_temp_5 = &(high);
                                (*(csharp2cuda_temp_5) = middle);
                            }
                        }
                    }
#line 1115 "WindowModule.cs"
                    {
#line 1115 "WindowModule.cs"
                        int index = low;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_sub(size, 1)))))
                                break;
#line 1116 "WindowModule.cs"
#line 1116 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &((sorted)[index]);
#line 1116 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (sorted)[csharp2cuda_i32_add(index, 1)];
                            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 1115 "WindowModule.cs"
                            int* csharp2cuda_temp_6 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
                        }
                    }
#line 1117 "WindowModule.cs"
#line 1117 "WindowModule.cs"
                    int* csharp2cuda_temp_9 = &(size);
                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_9));
                }
#line 1119 "WindowModule.cs"
                double entering = (x)[row];
#line 1120 "WindowModule.cs"
                int position = size;
#line 1121 "WindowModule.cs"
                while (true)
                {
#line 1121 "WindowModule.cs"
                    bool csharp2cuda_temp_10;
#line 1121 "WindowModule.cs"
                    if (((position) > (0)))
                    {
#line 1121 "WindowModule.cs"
                        double csharp2cuda_temp_11 = (sorted)[csharp2cuda_i32_sub(position, 1)];
#line 1121 "WindowModule.cs"
                        csharp2cuda_temp_10 = ((csharp2cuda_temp_11) > (entering));
                    }
                    else
                    {
#line 1121 "WindowModule.cs"
                        csharp2cuda_temp_10 = false;
                    }
                    if (!(csharp2cuda_temp_10))
                        break;
#line 1122 "WindowModule.cs"
                    {
#line 1123 "WindowModule.cs"
#line 1123 "WindowModule.cs"
                        double* csharp2cuda_temp_12 = &((sorted)[position]);
#line 1123 "WindowModule.cs"
                        double csharp2cuda_temp_13 = (sorted)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 1124 "WindowModule.cs"
#line 1124 "WindowModule.cs"
                        int* csharp2cuda_temp_14 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_14));
                    }
                }
#line 1126 "WindowModule.cs"
#line 1126 "WindowModule.cs"
                double* csharp2cuda_temp_15 = &((sorted)[position]);
                (*(csharp2cuda_temp_15) = entering);
#line 1127 "WindowModule.cs"
#line 1127 "WindowModule.cs"
                int* csharp2cuda_temp_16 = &(size);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
#line 1128 "WindowModule.cs"
                if (((row) < (first_row)))
                {
#line 1129 "WindowModule.cs"
                    goto csharp2cuda_for_continue_1;
                }
#line 1130 "WindowModule.cs"
                bool computed = false;
#line 1131 "WindowModule.cs"
                double value = 0.0;
#line 1132 "WindowModule.cs"
#line 1132 "WindowModule.cs"
                bool csharp2cuda_temp_17;
#line 1132 "WindowModule.cs"
                if (((row) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 1132 "WindowModule.cs"
                    csharp2cuda_temp_17 = probability_valid;
                }
                else
                {
#line 1132 "WindowModule.cs"
                    csharp2cuda_temp_17 = false;
                }
                if (csharp2cuda_temp_17)
#line 1133 "WindowModule.cs"
                {
#line 1134 "WindowModule.cs"
#line 1134 "WindowModule.cs"
                    double* csharp2cuda_temp_18 = &(value);
                    (*(csharp2cuda_temp_18) = mathblocks_statistics_sorted_quantile(sorted, width, probability));
#line 1135 "WindowModule.cs"
#line 1135 "WindowModule.cs"
                    bool* csharp2cuda_temp_19 = &(computed);
                    (*(csharp2cuda_temp_19) = isfinite(value));
                }
#line 1137 "WindowModule.cs"
                if (sibling)
                {
#line 1138 "WindowModule.cs"
#line 1138 "WindowModule.cs"
                    int* csharp2cuda_temp_20 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_20) = computed);
                }
                else
                {
#line 1140 "WindowModule.cs"
#line 1140 "WindowModule.cs"
                    double* csharp2cuda_temp_21 = &((result)[row]);
#line 1140 "WindowModule.cs"
                    double csharp2cuda_temp_22;
#line 1140 "WindowModule.cs"
                    if (computed)
                    {
#line 1140 "WindowModule.cs"
                        csharp2cuda_temp_22 = value;
                    }
                    else
                    {
#line 1140 "WindowModule.cs"
                        csharp2cuda_temp_22 = fill;
                    }
                    (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
                }
            }
            csharp2cuda_for_continue_1:
#line 1100 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
}

#line 136 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source)
#line 138 "WindowModule.cs"
{
#line 139 "WindowModule.cs"
    switch (source)
    {
#line 141 "WindowModule.cs"
        case 34:
#line 142 "WindowModule.cs"
            return 3;
#line 143 "WindowModule.cs"
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
#line 163 "WindowModule.cs"
            return 2;
#line 164 "WindowModule.cs"
        default:
#line 165 "WindowModule.cs"
            return 1;
    }
}

#line 706 "WindowModule.cs"
__device__ void mathblocks_window_split(double a, double* high, double* low)
#line 708 "WindowModule.cs"
{
#line 709 "WindowModule.cs"
    double c = __dmul_rn(134217729.0, a);
#line 710 "WindowModule.cs"
#line 710 "WindowModule.cs"
    double* csharp2cuda_temp_0 = high;
    (*(csharp2cuda_temp_0) = __dsub_rn(c, __dsub_rn(c, a)));
#line 711 "WindowModule.cs"
#line 711 "WindowModule.cs"
    double* csharp2cuda_temp_1 = low;
#line 711 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(high);
    (*(csharp2cuda_temp_1) = __dsub_rn(a, csharp2cuda_temp_2));
}

#line 924 "WindowModule.cs"
__device__ void mathblocks_window_square(double h, double l, double* sh, double* sl)
#line 926 "WindowModule.cs"
{
#line 927 "WindowModule.cs"
    double p = 0.0;
#line 928 "WindowModule.cs"
    double e = 0.0;
#line 929 "WindowModule.cs"
#line 929 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(p);
#line 929 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(e);
    mathblocks_window_two_product(h, h, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 930 "WindowModule.cs"
    double low = __dadd_rn(e, __dmul_rn(__dadd_rn(h, h), l));
#line 931 "WindowModule.cs"
    mathblocks_window_fast_two_sum(p, low, sh, sl);
}

#line 333 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value)
#line 338 "WindowModule.cs"
{
#line 339 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 340 "WindowModule.cs"
        return false;
    }
#line 341 "WindowModule.cs"
    double mean = 0.0;
#line 342 "WindowModule.cs"
    double deviation = 0.0;
#line 343 "WindowModule.cs"
#line 343 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(mean);
#line 343 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(deviation);
    mathblocks_vector_standardize_moments(values, count, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 344 "WindowModule.cs"
    {
#line 344 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 345 "WindowModule.cs"
#line 345 "WindowModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
#line 345 "WindowModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_3, mean), deviation);
            if ((!(isfinite(csharp2cuda_temp_4))))
            {
#line 346 "WindowModule.cs"
                return false;
            }
#line 344 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 347 "WindowModule.cs"
#line 347 "WindowModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 347 "WindowModule.cs"
    double csharp2cuda_temp_6 = (values)[csharp2cuda_i32_sub(count, 1)];
#line 347 "WindowModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_6, mean), deviation);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_7);
#line 348 "WindowModule.cs"
    return true;
}

#line 948 "WindowModule.cs"
__device__ double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl)
#line 950 "WindowModule.cs"
{
#line 951 "WindowModule.cs"
    double sh = 0.0;
#line 952 "WindowModule.cs"
    double sl = 0.0;
#line 953 "WindowModule.cs"
    double th = 0.0;
#line 954 "WindowModule.cs"
    double tl = 0.0;
#line 955 "WindowModule.cs"
#line 955 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(sh);
#line 955 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(sl);
    mathblocks_window_two_sum(ah, (-(bh)), csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 956 "WindowModule.cs"
#line 956 "WindowModule.cs"
    double* csharp2cuda_temp_2 = &(th);
#line 956 "WindowModule.cs"
    double* csharp2cuda_temp_3 = &(tl);
    mathblocks_window_two_sum(al, (-(bl)), csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 957 "WindowModule.cs"
    double c = __dadd_rn(sl, th);
#line 958 "WindowModule.cs"
    double vh = 0.0;
#line 959 "WindowModule.cs"
    double vl = 0.0;
#line 960 "WindowModule.cs"
#line 960 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(vh);
#line 960 "WindowModule.cs"
    double* csharp2cuda_temp_5 = &(vl);
    mathblocks_window_fast_two_sum(sh, c, csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 961 "WindowModule.cs"
    double w = __dadd_rn(tl, vl);
#line 962 "WindowModule.cs"
    double zh = 0.0;
#line 963 "WindowModule.cs"
    double zl = 0.0;
#line 964 "WindowModule.cs"
#line 964 "WindowModule.cs"
    double* csharp2cuda_temp_6 = &(zh);
#line 964 "WindowModule.cs"
    double* csharp2cuda_temp_7 = &(zl);
    mathblocks_window_fast_two_sum(vh, w, csharp2cuda_temp_6, csharp2cuda_temp_7);
#line 965 "WindowModule.cs"
    return zh;
}

#line 715 "WindowModule.cs"
__device__ void mathblocks_window_two_product(double a, double b, double* p, double* e)
#line 717 "WindowModule.cs"
{
#line 718 "WindowModule.cs"
#line 718 "WindowModule.cs"
    double* csharp2cuda_temp_0 = p;
    (*(csharp2cuda_temp_0) = __dmul_rn(a, b));
#line 719 "WindowModule.cs"
    double ah = 0.0;
#line 720 "WindowModule.cs"
    double al = 0.0;
#line 721 "WindowModule.cs"
    double bh = 0.0;
#line 722 "WindowModule.cs"
    double bl = 0.0;
#line 723 "WindowModule.cs"
#line 723 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(ah);
#line 723 "WindowModule.cs"
    double* csharp2cuda_temp_2 = &(al);
    mathblocks_window_split(a, csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 724 "WindowModule.cs"
#line 724 "WindowModule.cs"
    double* csharp2cuda_temp_3 = &(bh);
#line 724 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(bl);
    mathblocks_window_split(b, csharp2cuda_temp_3, csharp2cuda_temp_4);
#line 725 "WindowModule.cs"
#line 725 "WindowModule.cs"
    double* csharp2cuda_temp_5 = e;
#line 725 "WindowModule.cs"
    double csharp2cuda_temp_6 = *(p);
    (*(csharp2cuda_temp_5) = __dadd_rn(__dadd_rn(__dadd_rn(__dsub_rn(__dmul_rn(ah, bh), csharp2cuda_temp_6), __dmul_rn(ah, bl)), __dmul_rn(al, bh)), __dmul_rn(al, bl)));
}

#line 907 "WindowModule.cs"
__device__ void mathblocks_window_two_sum(double a, double b, double* s, double* e)
#line 909 "WindowModule.cs"
{
#line 910 "WindowModule.cs"
#line 910 "WindowModule.cs"
    double* csharp2cuda_temp_0 = s;
    (*(csharp2cuda_temp_0) = __dadd_rn(a, b));
#line 911 "WindowModule.cs"
    double csharp2cuda_temp_1 = *(s);
#line 911 "WindowModule.cs"
    double b_virtual = __dsub_rn(csharp2cuda_temp_1, a);
#line 912 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(s);
#line 912 "WindowModule.cs"
    double a_virtual = __dsub_rn(csharp2cuda_temp_2, b_virtual);
#line 913 "WindowModule.cs"
#line 913 "WindowModule.cs"
    double* csharp2cuda_temp_3 = e;
    (*(csharp2cuda_temp_3) = __dadd_rn(__dsub_rn(a, a_virtual), __dsub_rn(b, b_virtual)));
}

#line 355 "WindowModule.cs"
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
#line 366 "WindowModule.cs"
{
#line 367 "WindowModule.cs"
    switch (source)
    {
#line 369 "WindowModule.cs"
        case 0:
#line 370 "WindowModule.cs"
            {
#line 371 "WindowModule.cs"
                int lag = 0;
#line 372 "WindowModule.cs"
#line 372 "WindowModule.cs"
                double csharp2cuda_temp_0 = (first_parameter)->scalar_value;
#line 372 "WindowModule.cs"
                int* csharp2cuda_temp_1 = &(lag);
#line 372 "WindowModule.cs"
                bool csharp2cuda_temp_2 = mathblocks_sequence_positive_integer(csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 372 "WindowModule.cs"
                bool csharp2cuda_temp_3;
#line 372 "WindowModule.cs"
                if (!((!(csharp2cuda_temp_2))))
                {
#line 372 "WindowModule.cs"
                    csharp2cuda_temp_3 = ((lag) >= (count));
                }
                else
                {
#line 372 "WindowModule.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 373 "WindowModule.cs"
                    return false;
                }
#line 374 "WindowModule.cs"
#line 374 "WindowModule.cs"
                double* csharp2cuda_temp_4 = value;
                (*(csharp2cuda_temp_4) = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), csharp2cuda_i32_sub(count, lag)));
#line 375 "WindowModule.cs"
                break;
            }
#line 377 "WindowModule.cs"
        case 1:
        case 16:
#line 379 "WindowModule.cs"
#line 379 "WindowModule.cs"
            double csharp2cuda_temp_5 = (first_parameter)->scalar_value;
            return mathblocks_statistics_moment_value(a, count, csharp2cuda_temp_5, ((source) == (1)), value);
#line 380 "WindowModule.cs"
        case 2:
#line 381 "WindowModule.cs"
            return mathblocks_window_distance_correlation(a, b, count, scratch, value);
#line 382 "WindowModule.cs"
        case 3:
#line 383 "WindowModule.cs"
#line 383 "WindowModule.cs"
            bool csharp2cuda_temp_6;
#line 383 "WindowModule.cs"
            if (!(((count) <= (0))))
            {
#line 383 "WindowModule.cs"
                csharp2cuda_temp_6 = ((((void*)(scratch))) == (((void*)(nullptr))));
            }
            else
            {
#line 383 "WindowModule.cs"
                csharp2cuda_temp_6 = true;
            }
            if (csharp2cuda_temp_6)
            {
#line 384 "WindowModule.cs"
                return false;
            }
#line 385 "WindowModule.cs"
            mathblocks_statistics_sort_copy(a, count, scratch);
#line 386 "WindowModule.cs"
#line 386 "WindowModule.cs"
            double* csharp2cuda_temp_7 = value;
            (*(csharp2cuda_temp_7) = __dsub_rn(mathblocks_statistics_sorted_quantile(scratch, count, 0.75), mathblocks_statistics_sorted_quantile(scratch, count, 0.25)));
#line 389 "WindowModule.cs"
            break;
#line 390 "WindowModule.cs"
        case 4:
#line 391 "WindowModule.cs"
            return mathblocks_statistics_kendall_value(a, b, count, value);
#line 392 "WindowModule.cs"
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
#line 398 "WindowModule.cs"
            {
#line 399 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 400 "WindowModule.cs"
                    return false;
                }
#line 401 "WindowModule.cs"
                double covariance = mathblocks_statistics_population_covariance(a, b, count);
#line 402 "WindowModule.cs"
#line 402 "WindowModule.cs"
                bool csharp2cuda_temp_8;
#line 402 "WindowModule.cs"
                if (!(((source) == (10))))
                {
#line 402 "WindowModule.cs"
                    csharp2cuda_temp_8 = ((source) == (18));
                }
                else
                {
#line 402 "WindowModule.cs"
                    csharp2cuda_temp_8 = true;
                }
                if (csharp2cuda_temp_8)
#line 403 "WindowModule.cs"
                {
#line 404 "WindowModule.cs"
#line 404 "WindowModule.cs"
                    double* csharp2cuda_temp_9 = value;
#line 404 "WindowModule.cs"
                    double csharp2cuda_temp_10;
#line 404 "WindowModule.cs"
                    if (((source) == (10)))
                    {
#line 404 "WindowModule.cs"
                        csharp2cuda_temp_10 = covariance;
                    }
                    else
                    {
#line 404 "WindowModule.cs"
                        csharp2cuda_temp_10 = __ddiv_rn(__dmul_rn(covariance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    }
                    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
                }
                else
                {
#line 408 "WindowModule.cs"
                    if (((source) == (7)))
#line 409 "WindowModule.cs"
                    {
#line 410 "WindowModule.cs"
#line 410 "WindowModule.cs"
                        double* csharp2cuda_temp_11 = value;
#line 410 "WindowModule.cs"
                        double csharp2cuda_temp_12 = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
                    }
                    else
                    {
#line 413 "WindowModule.cs"
                        if (((source) == (5)))
#line 414 "WindowModule.cs"
                        {
#line 415 "WindowModule.cs"
                            double slope = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
#line 417 "WindowModule.cs"
#line 417 "WindowModule.cs"
                            double* csharp2cuda_temp_13 = value;
                            (*(csharp2cuda_temp_13) = __dsub_rn(mathblocks_statistics_mean(b, count), __dmul_rn(slope, mathblocks_statistics_mean(a, count))));
                        }
                        else
#line 421 "WindowModule.cs"
                        {
#line 422 "WindowModule.cs"
                            double correlation = __ddiv_rn(covariance, __dmul_rn(mathblocks_square_root(mathblocks_statistics_population_variance(a, count)), mathblocks_square_root(mathblocks_statistics_population_variance(b, count))));
#line 425 "WindowModule.cs"
#line 425 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = value;
#line 425 "WindowModule.cs"
                            double csharp2cuda_temp_15;
#line 425 "WindowModule.cs"
                            if (((source) == (6)))
                            {
#line 425 "WindowModule.cs"
                                csharp2cuda_temp_15 = __dmul_rn(correlation, correlation);
                            }
                            else
                            {
#line 425 "WindowModule.cs"
                                csharp2cuda_temp_15 = correlation;
                            }
                            (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                        }
                    }
                }
#line 427 "WindowModule.cs"
                break;
            }
#line 429 "WindowModule.cs"
        case 8:
#line 430 "WindowModule.cs"
            {
#line 431 "WindowModule.cs"
#line 431 "WindowModule.cs"
                bool csharp2cuda_temp_16;
#line 431 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 431 "WindowModule.cs"
                    csharp2cuda_temp_16 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 431 "WindowModule.cs"
                    csharp2cuda_temp_16 = true;
                }
                if (csharp2cuda_temp_16)
                {
#line 432 "WindowModule.cs"
                    return false;
                }
#line 433 "WindowModule.cs"
                double* sorted = scratch;
#line 434 "WindowModule.cs"
                double* deviations = csharp2cuda_pointer_add(scratch, count);
#line 435 "WindowModule.cs"
                mathblocks_statistics_sort_copy(a, count, sorted);
#line 436 "WindowModule.cs"
                double median = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
#line 437 "WindowModule.cs"
                {
#line 437 "WindowModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 438 "WindowModule.cs"
#line 438 "WindowModule.cs"
                        double* csharp2cuda_temp_18 = &((deviations)[index]);
#line 438 "WindowModule.cs"
                        double csharp2cuda_temp_19 = (a)[index];
                        (*(csharp2cuda_temp_18) = fabs(__dsub_rn(csharp2cuda_temp_19, median)));
#line 437 "WindowModule.cs"
                        int* csharp2cuda_temp_17 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                    }
                }
#line 439 "WindowModule.cs"
                mathblocks_statistics_sort_copy(deviations, count, sorted);
#line 440 "WindowModule.cs"
#line 440 "WindowModule.cs"
                double* csharp2cuda_temp_20 = value;
                (*(csharp2cuda_temp_20) = mathblocks_statistics_sorted_quantile(sorted, count, 0.5));
#line 441 "WindowModule.cs"
                break;
            }
#line 443 "WindowModule.cs"
        case 11:
        case 12:
#line 445 "WindowModule.cs"
            return mathblocks_statistics_shape_moment_value(a, count, ((source) == (11)), value);
#line 446 "WindowModule.cs"
        case 13:
        case 14:
        case 19:
        case 20:
#line 450 "WindowModule.cs"
            {
#line 451 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 452 "WindowModule.cs"
                    return false;
                }
#line 453 "WindowModule.cs"
                double variance = mathblocks_statistics_population_variance(a, count);
#line 454 "WindowModule.cs"
#line 454 "WindowModule.cs"
                bool csharp2cuda_temp_21;
#line 454 "WindowModule.cs"
                if (!(((source) == (19))))
                {
#line 454 "WindowModule.cs"
                    csharp2cuda_temp_21 = ((source) == (20));
                }
                else
                {
#line 454 "WindowModule.cs"
                    csharp2cuda_temp_21 = true;
                }
                if (csharp2cuda_temp_21)
                {
#line 455 "WindowModule.cs"
#line 455 "WindowModule.cs"
                    double* csharp2cuda_temp_22 = &(variance);
#line 455 "WindowModule.cs"
                    double csharp2cuda_temp_23 = __ddiv_rn(__dmul_rn(variance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
                }
#line 456 "WindowModule.cs"
#line 456 "WindowModule.cs"
                double* csharp2cuda_temp_24 = value;
#line 456 "WindowModule.cs"
                bool csharp2cuda_temp_25;
#line 456 "WindowModule.cs"
                if (!(((source) == (13))))
                {
#line 456 "WindowModule.cs"
                    csharp2cuda_temp_25 = ((source) == (19));
                }
                else
                {
#line 456 "WindowModule.cs"
                    csharp2cuda_temp_25 = true;
                }
#line 456 "WindowModule.cs"
                double csharp2cuda_temp_26;
#line 456 "WindowModule.cs"
                if (csharp2cuda_temp_25)
                {
#line 456 "WindowModule.cs"
                    csharp2cuda_temp_26 = mathblocks_square_root(variance);
                }
                else
                {
#line 456 "WindowModule.cs"
                    csharp2cuda_temp_26 = variance;
                }
                (*(csharp2cuda_temp_24) = csharp2cuda_temp_26);
#line 459 "WindowModule.cs"
                break;
            }
#line 461 "WindowModule.cs"
        case 15:
#line 462 "WindowModule.cs"
            {
#line 463 "WindowModule.cs"
#line 463 "WindowModule.cs"
                bool csharp2cuda_temp_27;
#line 463 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 463 "WindowModule.cs"
                    csharp2cuda_temp_27 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 463 "WindowModule.cs"
                    csharp2cuda_temp_27 = true;
                }
                if (csharp2cuda_temp_27)
                {
#line 464 "WindowModule.cs"
                    return false;
                }
#line 465 "WindowModule.cs"
                int average_count = mathblocks_statistics_pair_averages(a, count, scratch);
#line 466 "WindowModule.cs"
#line 466 "WindowModule.cs"
                double* csharp2cuda_temp_28 = value;
#line 466 "WindowModule.cs"
                double csharp2cuda_temp_29 = mathblocks_window_scratch_median(scratch, average_count);
                (*(csharp2cuda_temp_28) = csharp2cuda_temp_29);
#line 467 "WindowModule.cs"
                break;
            }
#line 469 "WindowModule.cs"
        case 17:
#line 470 "WindowModule.cs"
#line 470 "WindowModule.cs"
            double* csharp2cuda_temp_30 = value;
#line 471 "WindowModule.cs"
            double csharp2cuda_temp_31 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, count), ((double)(count)));
            (*(csharp2cuda_temp_30) = mathblocks_square_root(csharp2cuda_temp_31));
#line 472 "WindowModule.cs"
            break;
#line 473 "WindowModule.cs"
        case 21:
#line 474 "WindowModule.cs"
            {
#line 475 "WindowModule.cs"
#line 475 "WindowModule.cs"
                bool csharp2cuda_temp_32;
#line 475 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 475 "WindowModule.cs"
                    csharp2cuda_temp_32 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 475 "WindowModule.cs"
                    csharp2cuda_temp_32 = true;
                }
                if (csharp2cuda_temp_32)
                {
#line 476 "WindowModule.cs"
                    return false;
                }
#line 477 "WindowModule.cs"
                double* left_ranks = scratch;
#line 478 "WindowModule.cs"
                double* right_ranks = csharp2cuda_pointer_add(scratch, count);
#line 479 "WindowModule.cs"
                mathblocks_statistics_rank(a, count, left_ranks);
#line 480 "WindowModule.cs"
                mathblocks_statistics_rank(b, count, right_ranks);
#line 481 "WindowModule.cs"
#line 481 "WindowModule.cs"
                double* csharp2cuda_temp_33 = value;
                (*(csharp2cuda_temp_33) = mathblocks_statistics_pearson(left_ranks, right_ranks, count));
#line 482 "WindowModule.cs"
                break;
            }
#line 484 "WindowModule.cs"
        case 22:
#line 485 "WindowModule.cs"
            {
#line 486 "WindowModule.cs"
                int slope_count = mathblocks_statistics_pair_slopes(a, b, count, scratch);
#line 487 "WindowModule.cs"
                if (((slope_count) == (0)))
                {
#line 488 "WindowModule.cs"
                    return false;
                }
#line 489 "WindowModule.cs"
#line 489 "WindowModule.cs"
                double* csharp2cuda_temp_34 = value;
#line 489 "WindowModule.cs"
                double csharp2cuda_temp_35 = mathblocks_window_scratch_median(scratch, slope_count);
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 490 "WindowModule.cs"
                break;
            }
#line 492 "WindowModule.cs"
        case 23:
        case 24:
#line 494 "WindowModule.cs"
            return mathblocks_statistics_weighted_value(a, b, count, ((source) == (24)), value);
#line 495 "WindowModule.cs"
        case 25:
#line 496 "WindowModule.cs"
#line 496 "WindowModule.cs"
            double* csharp2cuda_temp_36 = value;
            (*(csharp2cuda_temp_36) = mathblocks_sequence_longest_run_value(flags, count));
#line 497 "WindowModule.cs"
            return true;
#line 498 "WindowModule.cs"
        case 26:
        case 27:
#line 500 "WindowModule.cs"
            return mathblocks_sequence_decline_value(a, count, ((source) == (27)), value);
#line 501 "WindowModule.cs"
        case 28:
#line 502 "WindowModule.cs"
#line 502 "WindowModule.cs"
            double csharp2cuda_temp_37 = (first_parameter)->scalar_value;
            return mathblocks_sequence_variation_value(a, count, csharp2cuda_temp_37, false, value);
#line 503 "WindowModule.cs"
        case 29:
#line 504 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 2.0, false, value);
#line 505 "WindowModule.cs"
        case 30:
#line 506 "WindowModule.cs"
#line 506 "WindowModule.cs"
            double csharp2cuda_temp_38 = (first_parameter)->scalar_value;
            return mathblocks_sequence_recurrence_value(a, count, csharp2cuda_temp_38, value);
#line 507 "WindowModule.cs"
        case 31:
#line 508 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 1.0, true, value);
#line 509 "WindowModule.cs"
        case 32:
        case 33:
#line 511 "WindowModule.cs"
#line 511 "WindowModule.cs"
            double* csharp2cuda_temp_39 = value;
            (*(csharp2cuda_temp_39) = mathblocks_sequence_sign_change_value(a, count, ((source) == (32))));
#line 512 "WindowModule.cs"
            return true;
#line 513 "WindowModule.cs"
        case 34:
#line 514 "WindowModule.cs"
#line 514 "WindowModule.cs"
            double* csharp2cuda_temp_40 = value;
#line 517 "WindowModule.cs"
            double csharp2cuda_temp_41 = (first_parameter)->scalar_value;
#line 518 "WindowModule.cs"
            int csharp2cuda_temp_42 = (second_parameter)->boolean_value;
            (*(csharp2cuda_temp_40) = mathblocks_sequence_first_passage_value(a, count, csharp2cuda_temp_41, ((csharp2cuda_temp_42) != (0))));
#line 519 "WindowModule.cs"
            return true;
#line 520 "WindowModule.cs"
        case 35:
        case 36:
        case 37:
        case 38:
        case 39:
#line 525 "WindowModule.cs"
            if ((!(mathblocks_probability_distribution(a, count))))
            {
#line 526 "WindowModule.cs"
                return false;
            }
#line 527 "WindowModule.cs"
            if (((source) == (35)))
#line 528 "WindowModule.cs"
            {
#line 529 "WindowModule.cs"
#line 529 "WindowModule.cs"
                double* csharp2cuda_temp_43 = value;
                (*(csharp2cuda_temp_43) = mathblocks_probability_entropy(a, count));
            }
            else
            {
#line 531 "WindowModule.cs"
                if (((source) == (39)))
#line 532 "WindowModule.cs"
                {
#line 533 "WindowModule.cs"
#line 533 "WindowModule.cs"
                    double* csharp2cuda_temp_44 = value;
#line 533 "WindowModule.cs"
                    double csharp2cuda_temp_45 = __ddiv_rn(mathblocks_probability_entropy(a, count), mathblocks_natural_logarithm(2.0));
                    (*(csharp2cuda_temp_44) = csharp2cuda_temp_45);
                }
                else
                {
#line 536 "WindowModule.cs"
                    if (((source) == (38)))
#line 537 "WindowModule.cs"
                    {
#line 538 "WindowModule.cs"
#line 538 "WindowModule.cs"
                        double* csharp2cuda_temp_46 = value;
                        (*(csharp2cuda_temp_46) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, count)));
                    }
                    else
                    {
#line 540 "WindowModule.cs"
#line 543 "WindowModule.cs"
                        double csharp2cuda_temp_47 = (first_parameter)->scalar_value;
#line 540 "WindowModule.cs"
                        bool csharp2cuda_temp_48 = mathblocks_probability_ordered_entropy_value(a, count, csharp2cuda_temp_47, ((source) == (36)), value);
                        if ((!(csharp2cuda_temp_48)))
#line 546 "WindowModule.cs"
                        {
#line 547 "WindowModule.cs"
                            return false;
                        }
                    }
                }
            }
#line 549 "WindowModule.cs"
            break;
#line 550 "WindowModule.cs"
        case 40:
        case 41:
#line 552 "WindowModule.cs"
            {
#line 553 "WindowModule.cs"
                double sum = mathblocks_compensated_sum(a, count);
#line 554 "WindowModule.cs"
#line 554 "WindowModule.cs"
                double* csharp2cuda_temp_49 = value;
#line 554 "WindowModule.cs"
                double csharp2cuda_temp_50;
#line 554 "WindowModule.cs"
                if (((source) == (41)))
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_50 = __ddiv_rn(sum, ((double)(count)));
                }
                else
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_50 = sum;
                }
                (*(csharp2cuda_temp_49) = csharp2cuda_temp_50);
#line 555 "WindowModule.cs"
                break;
            }
#line 557 "WindowModule.cs"
        case 42:
        case 43:
#line 559 "WindowModule.cs"
            {
#line 560 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 561 "WindowModule.cs"
                    return false;
                }
#line 562 "WindowModule.cs"
                double selected = (a)[0];
#line 563 "WindowModule.cs"
                {
#line 563 "WindowModule.cs"
                    int index = 1;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 564 "WindowModule.cs"
#line 564 "WindowModule.cs"
                        double* csharp2cuda_temp_52 = &(selected);
#line 564 "WindowModule.cs"
                        double csharp2cuda_temp_53;
#line 564 "WindowModule.cs"
                        if (((source) == (43)))
                        {
#line 565 "WindowModule.cs"
                            double csharp2cuda_temp_54 = (a)[index];
#line 564 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_maximum(selected, csharp2cuda_temp_54);
                        }
                        else
                        {
#line 566 "WindowModule.cs"
                            double csharp2cuda_temp_55 = (a)[index];
#line 564 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_minimum(selected, csharp2cuda_temp_55);
                        }
                        (*(csharp2cuda_temp_52) = csharp2cuda_temp_53);
#line 563 "WindowModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 567 "WindowModule.cs"
#line 567 "WindowModule.cs"
                double* csharp2cuda_temp_56 = value;
                (*(csharp2cuda_temp_56) = selected);
#line 568 "WindowModule.cs"
                return true;
            }
#line 570 "WindowModule.cs"
        case 44:
#line 571 "WindowModule.cs"
            return mathblocks_vector_geometric_mean_value(a, count, scratch, value);
#line 572 "WindowModule.cs"
        case 45:
#line 573 "WindowModule.cs"
#line 573 "WindowModule.cs"
            double* csharp2cuda_temp_57 = value;
            (*(csharp2cuda_temp_57) = mathblocks_compensated_absolute_sum(a, count));
#line 574 "WindowModule.cs"
            break;
#line 575 "WindowModule.cs"
        case 46:
#line 576 "WindowModule.cs"
#line 576 "WindowModule.cs"
            double* csharp2cuda_temp_58 = value;
            (*(csharp2cuda_temp_58) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, count)));
#line 577 "WindowModule.cs"
            break;
#line 578 "WindowModule.cs"
        case 47:
        case 48:
#line 580 "WindowModule.cs"
            {
#line 581 "WindowModule.cs"
                double csharp2cuda_temp_59;
#line 581 "WindowModule.cs"
                if (((source) == (47)))
                {
#line 581 "WindowModule.cs"
                    csharp2cuda_temp_59 = 0.5;
                }
                else
                {
#line 581 "WindowModule.cs"
                    csharp2cuda_temp_59 = (first_parameter)->scalar_value;
                }
#line 581 "WindowModule.cs"
                double probability = csharp2cuda_temp_59;
#line 582 "WindowModule.cs"
#line 582 "WindowModule.cs"
                bool csharp2cuda_temp_60;
#line 582 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 582 "WindowModule.cs"
                    csharp2cuda_temp_60 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 582 "WindowModule.cs"
                    csharp2cuda_temp_60 = true;
                }
#line 582 "WindowModule.cs"
                bool csharp2cuda_temp_61;
#line 582 "WindowModule.cs"
                if (!(csharp2cuda_temp_60))
                {
#line 582 "WindowModule.cs"
                    csharp2cuda_temp_61 = ((probability) < (0.0));
                }
                else
                {
#line 582 "WindowModule.cs"
                    csharp2cuda_temp_61 = true;
                }
#line 582 "WindowModule.cs"
                bool csharp2cuda_temp_62;
#line 582 "WindowModule.cs"
                if (!(csharp2cuda_temp_61))
                {
#line 582 "WindowModule.cs"
                    csharp2cuda_temp_62 = ((probability) > (1.0));
                }
                else
                {
#line 582 "WindowModule.cs"
                    csharp2cuda_temp_62 = true;
                }
                if (csharp2cuda_temp_62)
                {
#line 583 "WindowModule.cs"
                    return false;
                }
#line 584 "WindowModule.cs"
#line 584 "WindowModule.cs"
                double* csharp2cuda_temp_63 = value;
#line 584 "WindowModule.cs"
                double csharp2cuda_temp_64 = mathblocks_quantile_values(a, count, scratch, probability);
                (*(csharp2cuda_temp_63) = csharp2cuda_temp_64);
#line 585 "WindowModule.cs"
                break;
            }
#line 587 "WindowModule.cs"
        case 49:
        case 50:
#line 589 "WindowModule.cs"
            return mathblocks_vector_arg_extreme_value(a, count, ((source) == (49)), value);
#line 590 "WindowModule.cs"
        case 51:
#line 591 "WindowModule.cs"
#line 591 "WindowModule.cs"
            double* csharp2cuda_temp_65 = value;
            (*(csharp2cuda_temp_65) = mathblocks_vector_rank_at(a, count, csharp2cuda_i32_sub(count, 1)));
#line 592 "WindowModule.cs"
            return true;
#line 593 "WindowModule.cs"
        case 52:
#line 594 "WindowModule.cs"
            return mathblocks_window_standardize_last(a, count, value);
#line 595 "WindowModule.cs"
        default:
#line 596 "WindowModule.cs"
            return false;
    }
#line 598 "WindowModule.cs"
#line 598 "WindowModule.cs"
    double csharp2cuda_temp_66 = *(value);
    return isfinite(csharp2cuda_temp_66);
}