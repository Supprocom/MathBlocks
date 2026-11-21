#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class GeometryModule
{
    [CudaExternal]
    public struct MathBlockSlot
    {
        public float scalar_value;
        public ulong data_pointer;
        public ulong scratch_pointer;
        public CudaInt32 boolean_value;
        public CudaInt32 valid;
        public int rows;
        public int columns;
        public int count;
        public int capacity;
    }

    [CudaExternal(IsPure = true)]
    private static float mathblocks_arc_cosine(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_positive_infinity() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_quiet_nan() => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_set_matrix_shape(MathBlockSlot* output, int rows, int columns) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_square_root(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static bool mathblocks_probability_distribution([CudaReadOnly] float* values, int count) => throw new NotSupportedException();
    public struct MathBlockGeometryEdge
    {
        public int from;
        public int to;
        public float weight;
    }

    [CudaDevice]
    private static float mathblocks_geometry_distance_coordinates(
        float left_x,
        float left_y,
        float right_x,
        float right_y)
    {
        float x = left_x - right_x;
        float y = left_y - right_y;
        return mathblocks_square_root(x * x + y * y);
    }

    [CudaDevice]
    private static float mathblocks_geometry_distance(
        [CudaReadOnly] float* left,
        int left_index,
        [CudaReadOnly] float* right,
        int right_index)
    {
        return mathblocks_geometry_distance_coordinates(
            left[2 * left_index],
            left[2 * left_index + 1],
            right[2 * right_index],
            right[2 * right_index + 1]);
    }

    // Whether the turn at the middle point is not a left turn. A NaN cross product (inf - inf from overflowing products) sets overflow.
    [CudaDevice]
    private static bool mathblocks_geometry_not_left_turn(
        int* overflow,
        float origin_x,
        float origin_y,
        float left_x,
        float left_y,
        float right_x,
        float right_y)
    {
        float cross = mathblocks_geometry_cross(origin_x, origin_y, left_x, left_y, right_x, right_y);
        if (float.IsNaN(cross))
            *overflow = 1;
        return cross <= 0.0f;
    }

    [CudaDevice]
    private static float mathblocks_geometry_cross(
        float origin_x,
        float origin_y,
        float left_x,
        float left_y,
        float right_x,
        float right_y)
    {
        return (left_x - origin_x) * (right_y - origin_y) -
               (left_y - origin_y) * (right_x - origin_x);
    }

    [CudaDevice]
    private static float mathblocks_geometry_point_to_segment(
        float point_x,
        float point_y,
        float start_x,
        float start_y,
        float end_x,
        float end_y)
    {
        float x = end_x - start_x;
        float y = end_y - start_y;
        float length_square = x * x + y * y;
        if (length_square == 0.0f)
            return mathblocks_geometry_distance_coordinates(point_x, point_y, start_x, start_y);
        float projection = ((point_x - start_x) * x + (point_y - start_y) * y) /
            length_square;
        projection = projection < 0.0f ? 0.0f : projection > 1.0f ? 1.0f : projection;
        return mathblocks_geometry_distance_coordinates(
            point_x,
            point_y,
            start_x + projection * x,
            start_y + projection * y);
    }

    [CudaDevice]
    private static float mathblocks_geometry_barycentric_denominator(
        float first_x,
        float first_y,
        float second_x,
        float second_y,
        float third_x,
        float third_y)
    {
        return (second_y - third_y) * (first_x - third_x) +
               (third_x - second_x) * (first_y - third_y);
    }

    [CudaDevice]
    private static void mathblocks_geometry_barycentric(
        float point_x,
        float point_y,
        float first_x,
        float first_y,
        float second_x,
        float second_y,
        float third_x,
        float third_y,
        float* result)
    {
        float denominator = mathblocks_geometry_barycentric_denominator(
            first_x, first_y, second_x, second_y, third_x, third_y);
        // A denominator that overflowed would divide the numerators by an infinity and give finite weights near zero.
        if (!float.IsFinite(denominator))
        {
            result[0] = mathblocks_quiet_nan();
            result[1] = mathblocks_quiet_nan();
            result[2] = mathblocks_quiet_nan();
            return;
        }
        float first_weight = ((second_y - third_y) * (point_x - third_x) +
                               (third_x - second_x) * (point_y - third_y)) / denominator;
        float second_weight = ((third_y - first_y) * (point_x - third_x) +
                                (first_x - third_x) * (point_y - third_y)) / denominator;
        result[0] = first_weight;
        result[1] = second_weight;
        result[2] = 1.0f - first_weight - second_weight;
    }

    [CudaDevice]
    private static bool mathblocks_geometry_try_circumcircle(
        [CudaReadOnly] float* points,
        int first,
        int second,
        int third,
        float* center_x,
        float* center_y,
        float* radius_square)
    {
        float first_x = points[2 * first];
        float first_y = points[2 * first + 1];
        float second_x = points[2 * second];
        float second_y = points[2 * second + 1];
        float third_x = points[2 * third];
        float third_y = points[2 * third + 1];
        float denominator = 2.0f * (first_x * (second_y - third_y) +
                                    second_x * (third_y - first_y) +
                                    third_x * (first_y - second_y));
        if (denominator == 0.0f)
        {
            *center_x = 0.0f;
            *center_y = 0.0f;
            *radius_square = 0.0f;
            return false;
        }
        float first_square = first_x * first_x + first_y * first_y;
        float second_square = second_x * second_x + second_y * second_y;
        float third_square = third_x * third_x + third_y * third_y;
        *center_x = (first_square * (second_y - third_y) +
                     second_square * (third_y - first_y) +
                     third_square * (first_y - second_y)) / denominator;
        *center_y = (first_square * (third_x - second_x) +
                     second_square * (first_x - third_x) +
                     third_square * (second_x - first_x)) / denominator;
        float x = first_x - *center_x;
        float y = first_y - *center_y;
        *radius_square = x * x + y * y;
        return true;
    }

    [CudaDevice]
    private static bool mathblocks_geometry_point_less(
        [CudaReadOnly] float* points,
        int left,
        int right)
    {
        float left_x = points[2 * left];
        float right_x = points[2 * right];
        if (left_x < right_x)
            return true;
        if (right_x < left_x)
            return false;
        float left_y = points[2 * left + 1];
        float right_y = points[2 * right + 1];
        if (left_y < right_y)
            return true;
        if (right_y < left_y)
            return false;
        return left < right;
    }

    // The point indices 0 .. count - 1 in the stable order of mathblocks_geometry_point_less; buffer holds count ints.
    [CudaDevice]
    private static void mathblocks_geometry_index_order(
        [CudaReadOnly] float* points,
        int count,
        int* order,
        int* buffer)
    {
        for (int index = 0; index < count; index++)
            order[index] = index;
        int* source = order;
        int* target = buffer;
        for (int width = 1; width < count; width += width)
        {
            for (int start = 0; start < count; start += width + width)
            {
                int middle = start + width < count ? start + width : count;
                int end = middle + width < count ? middle + width : count;
                int left = start;
                int right = middle;
                int position = start;
                while (left < middle && right < end)
                {
                    bool take_right = mathblocks_geometry_point_less(points, source[right], source[left]);
                    target[position++] = take_right ? source[right++] : source[left++];
                }
                while (left < middle)
                    target[position++] = source[left++];
                while (right < end)
                    target[position++] = source[right++];
            }
            int* sorted = target;
            target = source;
            source = sorted;
        }
        if (source != order)
            for (int index = 0; index < count; index++)
                order[index] = source[index];
    }

    // The count (x, y) pairs of points in the stable lexicographic order of the source's CompareHullPoints (x, then y;
    // -0.0 and +0.0 compare equal and keep their input order), merged between points and buffer (2 * count doubles each).
    // The sorted pairs end in points.
    [CudaDevice]
    private static void mathblocks_geometry_sort_points(float* points, float* buffer, int count)
    {
        float* source = points;
        float* target = buffer;
        for (int width = 1; width < count; width += width)
        {
            for (int start = 0; start < count; start += width + width)
            {
                int middle = start + width < count ? start + width : count;
                int end = middle + width < count ? middle + width : count;
                int left = start;
                int right = middle;
                int position = start;
                while (left < middle && right < end)
                {
                    bool take_right = source[2 * right] < source[2 * left] ||
                        (source[2 * right] == source[2 * left] && source[2 * right + 1] < source[2 * left + 1]);
                    int from = take_right ? right++ : left++;
                    target[2 * position] = source[2 * from];
                    target[2 * position + 1] = source[2 * from + 1];
                    position++;
                }
                while (left < middle)
                {
                    target[2 * position] = source[2 * left];
                    target[2 * position + 1] = source[2 * left + 1];
                    position++;
                    left++;
                }
                while (right < end)
                {
                    target[2 * position] = source[2 * right];
                    target[2 * position + 1] = source[2 * right + 1];
                    position++;
                    right++;
                }
            }
            float* sorted = target;
            target = source;
            source = sorted;
        }
        if (source != points)
            for (int index = 0; index < 2 * count; index++)
                points[index] = source[index];
    }

    [CudaDevice]
    private static int mathblocks_geometry_find(int* parent, int value)
    {
        while (parent[value] != value)
        {
            parent[value] = parent[parent[value]];
            value = parent[value];
        }
        return value;
    }

    [CudaDevice]
    private static bool mathblocks_geometry_edge_less(
        in MathBlockGeometryEdge left,
        in MathBlockGeometryEdge right)
    {
        if (left.weight < right.weight)
            return true;
        if (right.weight < left.weight)
            return false;
        if (left.from < right.from)
            return true;
        if (right.from < left.from)
            return false;
        return left.to < right.to;
    }

    // The count edges in the stable order of mathblocks_geometry_edge_less (a strict total order: weight, then from, then
    // to), merged between edges and buffer (count edges each). The sorted edges end in edges.
    [CudaDevice]
    private static void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count)
    {
        MathBlockGeometryEdge* source = edges;
        MathBlockGeometryEdge* target = buffer;
        for (int width = 1; width < count; width += width)
        {
            for (int start = 0; start < count; start += width + width)
            {
                int middle = start + width < count ? start + width : count;
                int end = middle + width < count ? middle + width : count;
                int left = start;
                int right = middle;
                int position = start;
                while (left < middle && right < end)
                {
                    if (mathblocks_geometry_edge_less(source[right], source[left]))
                        target[position++] = source[right++];
                    else
                        target[position++] = source[left++];
                }
                while (left < middle)
                    target[position++] = source[left++];
                while (right < end)
                    target[position++] = source[right++];
            }
            MathBlockGeometryEdge* sorted = target;
            target = source;
            source = sorted;
        }
        if (source != edges)
            for (int index = 0; index < count; index++)
                edges[index] = source[index];
    }

    [CudaDevice(Name = "mathblocks_geometry_dispatch")]
    private static void mathblocks_geometry(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        int thread = (int)Cuda.ThreadIdx.X;
        MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);
        MathBlockSlot* second = Cuda.ReadOnly(input_count > 1 ? inputs[1] : null);
        if (thread == 0)
        {
            output->scalar_value = 0.0f;
            output->boolean_value = 0;
            output->rows = 0;
            output->columns = 0;
            output->count = 0;
            output->valid = first == null || first->valid;
            if (second != null)
                output->valid = output->valid && second->valid;
        }
        Cuda.SyncThreads();
        if (!output->valid)
            return;

        float* a = Cuda.ReadOnly(first == null ? null : (float*)first->data_pointer);
        float* b = Cuda.ReadOnly(second == null ? null : (float*)second->data_pointer);
        float* result = (float*)output->data_pointer;
        float* scratch = (float*)output->scratch_pointer;

        if (thread == 0)
        {
            switch (opcode)
            {
                case 0:
                    mathblocks_sequence_set_vector_shape(output, 3);
                    if (first->count != 1 || second->count != 3)
                    {
                        output->valid = 0;
                        break;
                    }
                    mathblocks_geometry_barycentric(
                        a[0], a[1], b[0], b[1], b[2], b[3], b[4], b[5], result);
                    for (int index = 0; index < 3; index++)
                        if (!float.IsFinite(result[index])) output->valid = 0;
                    break;
                case 1:
                    output->rows = 1;
                    output->count = 1;
                    if (first->count <= 0 || output->capacity < 1)
                    {
                        output->valid = 0;
                        break;
                    }
                    result[0] = 0.0f;
                    result[1] = 0.0f;
                    for (int index = 0; index < first->count; index++)
                    {
                        result[0] += a[2 * index];
                        result[1] += a[2 * index + 1];
                    }
                    result[0] /= first->count;
                    result[1] /= first->count;
                    if (!float.IsFinite(result[0]) || !float.IsFinite(result[1])) output->valid = 0;
                    break;
                case 2:
                    if (first->count != 3)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float first_length = mathblocks_geometry_distance(a, 1, a, 2);
                    float second_length = mathblocks_geometry_distance(a, 0, a, 2);
                    float third_length = mathblocks_geometry_distance(a, 0, a, 1);
                    float cross = mathblocks_geometry_cross(
                        a[0], a[1], a[2], a[3], a[4], a[5]);
                    output->scalar_value = first_length * second_length * third_length /
                        (2.0f * MathF.Abs(cross));
                    break;
                }
                case 3:
                    if (first->count < 3 || second->count != 1)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    bool inside = false;
                    float point_x = b[0];
                    float point_y = b[1];
                    for (int current = 0; current < first->count; current++)
                    {
                        int previous = current == 0 ? first->count - 1 : current - 1;
                        float left_x = a[2 * current];
                        float left_y = a[2 * current + 1];
                        float right_x = a[2 * previous];
                        float right_y = a[2 * previous + 1];
                        if (mathblocks_geometry_point_to_segment(
                            point_x, point_y, left_x, left_y, right_x, right_y) == 0.0f)
                        {
                            inside = true;
                            break;
                        }
                        if ((left_y > point_y) != (right_y > point_y))
                        {
                            // The crossing lies between the edge's end points, so it is finite unless a product overflowed.
                            float crossing = (right_x - left_x) * (point_y - left_y) /
                                              (right_y - left_y) + left_x;
                            if (!float.IsFinite(crossing))
                                output->valid = 0;
                            if (point_x < crossing)
                                inside = !inside;
                        }
                    }
                    output->boolean_value = inside ? 1 : 0;
                    break;
                }
                case 4:
                    if (first->count <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float* sorted = scratch;
                    float* hull = scratch + first->count * 4;
                    for (int index = 0; index < first->count * 2; index++)
                        sorted[index] = a[index];
                    mathblocks_geometry_sort_points(sorted, scratch + first->count * 2, first->count);
                    int unique_count = 0;
                    for (int index = 0; index < first->count; index++)
                    {
                        float x = sorted[2 * index];
                        float y = sorted[2 * index + 1];
                        if (unique_count > 0 && sorted[2 * (unique_count - 1)] == x && sorted[2 * (unique_count - 1) + 1] == y)
                            continue;
                        sorted[2 * unique_count] = x;
                        sorted[2 * unique_count + 1] = y;
                        unique_count++;
                    }
                    int count = 0;
                    int hull_overflow = 0;
                    if (unique_count <= 1)
                    {
                        count = unique_count;
                        if (count == 1)
                        {
                            hull[0] = sorted[0];
                            hull[1] = sorted[1];
                        }
                    }
                    else
                    {
                        for (int index = 0; index < unique_count; index++)
                        {
                            while (count >= 2 && mathblocks_geometry_not_left_turn(
                                &hull_overflow,
                                hull[2 * (count - 2)], hull[2 * (count - 2) + 1],
                                hull[2 * (count - 1)], hull[2 * (count - 1) + 1],
                                sorted[2 * index], sorted[2 * index + 1]))
                            {
                                count--;
                            }
                            hull[2 * count] = sorted[2 * index];
                            hull[2 * count + 1] = sorted[2 * index + 1];
                            count++;
                        }
                        int lower_count = count;
                        for (int index = unique_count - 2; index >= 0; index--)
                        {
                            while (count > lower_count && mathblocks_geometry_not_left_turn(
                                &hull_overflow,
                                hull[2 * (count - 2)], hull[2 * (count - 2) + 1],
                                hull[2 * (count - 1)], hull[2 * (count - 1) + 1],
                                sorted[2 * index], sorted[2 * index + 1]))
                            {
                                count--;
                            }
                            hull[2 * count] = sorted[2 * index];
                            hull[2 * count + 1] = sorted[2 * index + 1];
                            count++;
                        }
                        count--;
                    }
                    if (hull_overflow != 0)
                        output->valid = 0;
                    output->rows = count;
                    output->count = count;
                    if (count > output->capacity)
                    {
                        output->valid = 0;
                        break;
                    }
                    for (int index = 0; index < count * 2; index++)
                        result[index] = hull[index];
                    break;
                }
                case 5:
                    if (first->count < 2 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    int count = first->count;
                    int* adjacency = (int*)scratch;
                    int* ordered = adjacency + count * count;
                    for (int index = 0; index < count * count; index++)
                        adjacency[index] = 0;
                    for (int first_index = 0; first_index < count; first_index++)
                    {
                        for (int second_index = first_index + 1; second_index < count; second_index++)
                        {
                            for (int third_index = second_index + 1; third_index < count; third_index++)
                            {
                                float center_x;
                                float center_y;
                                float radius_square;
                                if (!mathblocks_geometry_try_circumcircle(
                                    a, first_index, second_index, third_index,
                                    &center_x, &center_y, &radius_square))
                                {
                                    continue;
                                }
                                bool empty = true;
                                for (int index = 0; index < count; index++)
                                {
                                    if (index == first_index || index == second_index || index == third_index)
                                        continue;
                                    float x = a[2 * index] - center_x;
                                    float y = a[2 * index + 1] - center_y;
                                    if (x * x + y * y < radius_square)
                                    {
                                        empty = false;
                                        break;
                                    }
                                }
                                if (!empty)
                                    continue;
                                adjacency[first_index * count + second_index] = 1;
                                adjacency[first_index * count + third_index] = 1;
                                adjacency[second_index * count + third_index] = 1;
                            }
                        }
                    }
                    int edge_count = 0;
                    for (int left = 0; left < count; left++)
                        for (int right = left + 1; right < count; right++)
                            edge_count += adjacency[left * count + right];
                    if (edge_count == 0)
                    {
                        mathblocks_geometry_index_order(a, count, ordered, ordered + count);
                        for (int index = 1; index < count; index++)
                        {
                            int left = ordered[index - 1] < ordered[index]
                                ? ordered[index - 1]
                                : ordered[index];
                            int right = ordered[index - 1] < ordered[index]
                                ? ordered[index]
                                : ordered[index - 1];
                            adjacency[left * count + right] = 1;
                        }
                    }
                    MathBlockGeometryEdge* edges = (MathBlockGeometryEdge*)output->data_pointer;
                    edge_count = 0;
                    for (int left = 0; left < count; left++)
                    {
                        for (int right = left + 1; right < count; right++)
                        {
                            if (!Cuda.Bool(adjacency[left * count + right]))
                                continue;
                            if (edge_count >= output->capacity)
                            {
                                output->count = output->capacity == 2147483647
                                    ? -1
                                    : output->capacity + 1;
                                output->valid = 0;
                                break;
                            }
                            edges[edge_count].from = left;
                            edges[edge_count].to = right;
                            edges[edge_count].weight = mathblocks_geometry_distance(a, left, a, right);
                            if (!float.IsFinite(edges[edge_count].weight)) output->valid = 0;
                            edge_count++;
                        }
                    }
                    output->rows = count;
                    if (output->valid)
                        output->count = edge_count;
                    break;
                }
                case 6:
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float maximum = 0.0f;
                    for (int left = 0; left < first->count; left++)
                        for (int right = left + 1; right < first->count; right++)
                        {
                            float distance = mathblocks_geometry_distance(a, left, a, right);
                            maximum = maximum > distance ? maximum : distance;
                        }
                    output->scalar_value = maximum;
                    break;
                }
                case 7:
                    if (first->count <= 0 || second->count <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    for (int left = 0; left < first->count; left++)
                    {
                        for (int right = 0; right < second->count; right++)
                        {
                            float distance = mathblocks_geometry_distance(a, left, b, right);
                            int target = left * second->count + right;
                            if (left == 0 && right == 0)
                                scratch[0] = distance;
                            else if (left == 0)
                                scratch[right] = scratch[right - 1] > distance
                                    ? scratch[right - 1]
                                    : distance;
                            else if (right == 0)
                                scratch[left * second->count] = scratch[(left - 1) * second->count] > distance
                                    ? scratch[(left - 1) * second->count]
                                    : distance;
                            else
                            {
                                float preceding = scratch[(left - 1) * second->count + right];
                                float candidate = scratch[(left - 1) * second->count + right - 1];
                                preceding = preceding < candidate ? preceding : candidate;
                                candidate = scratch[left * second->count + right - 1];
                                preceding = preceding < candidate ? preceding : candidate;
                                scratch[target] = preceding > distance ? preceding : distance;
                            }
                        }
                    }
                    output->scalar_value = scratch[first->count * second->count - 1];
                    break;
                }
                case 8:
                    if (first->count <= 0 || second->count <= 0)
                        output->valid = 0;
                    else
                        output->scalar_value = mathblocks_geometry_distance(a, 0, b, 0);
                    break;
                case 9:
                    if (first->count <= 0 || first->count != second->count ||
                        !mathblocks_probability_distribution(a, first->count) ||
                        !mathblocks_probability_distribution(b, second->count))
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float affinity = 0.0f;
                    for (int index = 0; index < first->count; index++)
                        affinity += mathblocks_square_root(a[index] * b[index]);
                    affinity = affinity < -1.0f ? -1.0f : affinity > 1.0f ? 1.0f : affinity;
                    output->scalar_value = 2.0f * mathblocks_arc_cosine(affinity);
                    break;
                }
                case 10:
                    if (first->count < 2)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    MathBlockGeometryEdge* edges = (MathBlockGeometryEdge*)output->data_pointer;
                    int edge_count = 0;
                    for (int left = 0; left < first->count; left++)
                    {
                        for (int right = left + 1; right < first->count; right++)
                        {
                            float center_x = (a[2 * left] + a[2 * right]) / 2.0f;
                            float center_y = (a[2 * left + 1] + a[2 * right + 1]) / 2.0f;
                            float radius = mathblocks_geometry_distance(a, left, a, right) / 2.0f;
                            bool empty = true;
                            for (int index = 0; index < first->count; index++)
                            {
                                if (index != left && index != right &&
                                    mathblocks_geometry_distance_coordinates(
                                        a[2 * index], a[2 * index + 1], center_x, center_y) < radius)
                                {
                                    empty = false;
                                    break;
                                }
                            }
                            if (!empty)
                                continue;
                            if (edge_count >= output->capacity)
                            {
                                output->count = output->capacity == 2147483647
                                    ? -1
                                    : output->capacity + 1;
                                output->valid = 0;
                                break;
                            }
                            edges[edge_count].from = left;
                            edges[edge_count].to = right;
                            edges[edge_count].weight = 2.0f * radius;
                            if (!float.IsFinite(edges[edge_count].weight)) output->valid = 0;
                            edge_count++;
                        }
                    }
                    output->rows = first->count;
                    if (output->valid)
                        output->count = edge_count;
                    break;
                }
                case 11:
                    if (first->count <= 0 || second->count != 1)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float point_x = b[0];
                    float point_y = b[1];
                    int coincident = 0;
                    int vector_count = 0;
                    for (int index = 0; index < first->count; index++)
                    {
                        float x = a[2 * index] - point_x;
                        float y = a[2 * index + 1] - point_y;
                        if (x == 0.0f && y == 0.0f)
                            coincident++;
                        else
                            vector_count++;
                    }
                    if (vector_count == 0)
                    {
                        output->scalar_value = 1.0f;
                        break;
                    }
                    int maximum = 0;
                    for (int pivot = 0; pivot < first->count; pivot++)
                    {
                        float pivot_x = a[2 * pivot] - point_x;
                        float pivot_y = a[2 * pivot + 1] - point_y;
                        if (pivot_x == 0.0f && pivot_y == 0.0f)
                            continue;
                        int count = 0;
                        for (int index = 0; index < first->count; index++)
                        {
                            float x = a[2 * index] - point_x;
                            float y = a[2 * index + 1] - point_y;
                            if (x == 0.0f && y == 0.0f)
                                continue;
                            float cross = pivot_x * y - pivot_y * x;
                            float dot = pivot_x * x + pivot_y * y;
                            // A NaN (inf - inf, 0 * inf from an overflowing product) fails both tests and would count the point as outside.
                            if (float.IsNaN(cross) || float.IsNaN(dot))
                                output->valid = 0;
                            if (cross > 0.0f || (cross == 0.0f && dot > 0.0f))
                                count++;
                        }
                        maximum = maximum > count ? maximum : count;
                    }
                    output->scalar_value = (float)(coincident + vector_count - maximum) /
                        first->count;
                    break;
                }
                case 12:
                    if (first->count <= 0 || second->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float directed_left = 0.0f;
                    for (int left = 0; left < first->count; left++)
                    {
                        float minimum = mathblocks_positive_infinity();
                        for (int right = 0; right < second->count; right++)
                        {
                            float distance = mathblocks_geometry_distance(a, left, b, right);
                            minimum = minimum < distance ? minimum : distance;
                        }
                        directed_left = directed_left > minimum ? directed_left : minimum;
                    }
                    float directed_right = 0.0f;
                    for (int right = 0; right < second->count; right++)
                    {
                        float minimum = mathblocks_positive_infinity();
                        for (int left = 0; left < first->count; left++)
                        {
                            float distance = mathblocks_geometry_distance(b, right, a, left);
                            minimum = minimum < distance ? minimum : distance;
                        }
                        directed_right = directed_right > minimum ? directed_right : minimum;
                    }
                    output->scalar_value = directed_left > directed_right
                        ? directed_left
                        : directed_right;
                    break;
                }
                case 13:
                case 14:
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float total = 0.0f;
                    int start = opcode == 13 ? 1 : 0;
                    for (int index = start; index < first->count; index++)
                    {
                        int previous = opcode == 13 ? index - 1 : index;
                        int next = opcode == 13 ? index : (index + 1) % first->count;
                        total += mathblocks_geometry_distance(a, previous, a, next);
                    }
                    output->scalar_value = total;
                    break;
                }
                case 15:
                    if (first->count != 1 || second->count != 2)
                    {
                        output->valid = 0;
                        break;
                    }
                    output->scalar_value = mathblocks_geometry_point_to_segment(
                        a[0], a[1], b[0], b[1], b[2], b[3]);
                    break;
                case 16:
                case 17:
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float twice_area = 0.0f;
                    for (int index = 0; index < first->count; index++)
                    {
                        int next = (index + 1) % first->count;
                        twice_area += a[2 * index] * a[2 * next + 1] -
                                      a[2 * next] * a[2 * index + 1];
                    }
                    output->scalar_value = opcode == 16 ? MathF.Abs(twice_area / 2.0f) : twice_area / 2.0f;
                    break;
                }
                case 18:
                    if (first->count < 3 || second->count != 1)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    int containing = 0;
                    int total = 0;
                    float* coordinates = stackalloc float[3];
                    for (int one = 0; one < first->count; one++)
                        for (int two = one + 1; two < first->count; two++)
                            for (int three = two + 1; three < first->count; three++)
                            {
                                total++;
                                // A degenerate triangle holds no point; a coordinate that is not finite makes the depth invalid.
                                if (mathblocks_geometry_barycentric_denominator(
                                        a[2 * one], a[2 * one + 1],
                                        a[2 * two], a[2 * two + 1],
                                        a[2 * three], a[2 * three + 1]) == 0.0f)
                                    continue;
                                mathblocks_geometry_barycentric(
                                    b[0], b[1],
                                    a[2 * one], a[2 * one + 1],
                                    a[2 * two], a[2 * two + 1],
                                    a[2 * three], a[2 * three + 1],
                                    coordinates);
                                if (!float.IsFinite(coordinates[0]) || !float.IsFinite(coordinates[1]) ||
                                    !float.IsFinite(coordinates[2]))
                                    output->valid = 0;
                                if (coordinates[0] >= 0.0f && coordinates[0] <= 1.0f &&
                                    coordinates[1] >= 0.0f && coordinates[1] <= 1.0f &&
                                    coordinates[2] >= 0.0f && coordinates[2] <= 1.0f)
                                {
                                    containing++;
                                }
                            }
                    output->scalar_value = (float)containing / total;
                    break;
                }
                case 19:
                    output->rows = first->rows;
                    output->count = first->rows;
                    if (first->columns != 2 || first->rows > output->capacity)
                    {
                        output->valid = 0;
                        break;
                    }
                    for (int index = 0; index < first->rows * 2; index++)
                        result[index] = a[index];
                    break;
                case 20:
                    mathblocks_sequence_set_matrix_shape(output, first->count, 2);
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                    for (int index = 0; index < first->count * 2; index++)
                        result[index] = a[index];
                    break;
                case 21:
                    if (first->count <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    if (first->count == 1)
                    {
                        mathblocks_sequence_set_vector_shape(output, 0);
                        break;
                    }
                {
                    int vertex_count = first->count;
                    int edge_capacity = vertex_count * (vertex_count - 1) / 2;
                    MathBlockGeometryEdge* edges = (MathBlockGeometryEdge*)scratch;
                    int edge_count = 0;
                    for (int left = 0; left < vertex_count; left++)
                        for (int right = left + 1; right < vertex_count; right++)
                        {
                            edges[edge_count].from = left;
                            edges[edge_count].to = right;
                            edges[edge_count].weight = mathblocks_geometry_distance(a, left, a, right);
                            edge_count++;
                        }
                    mathblocks_geometry_sort_edges(edges, edges + edge_capacity, edge_count);
                    int* parent = (int*)(edges + 2 * edge_capacity);
                    byte* rank = (byte*)(parent + vertex_count);
                    for (int index = 0; index < vertex_count; index++)
                    {
                        parent[index] = index;
                        rank[index] = 0;
                    }
                    int selected = 0;
                    for (int index = 0; index < edge_count && selected < vertex_count - 1; index++)
                    {
                        int left = mathblocks_geometry_find(parent, edges[index].from);
                        int right = mathblocks_geometry_find(parent, edges[index].to);
                        if (left == right)
                            continue;
                        if (rank[left] < rank[right])
                            parent[left] = right;
                        else if (rank[left] > rank[right])
                            parent[right] = left;
                        else
                        {
                            parent[right] = left;
                            rank[left]++;
                        }
                        result[selected++] = edges[index].weight;
                    }
                    mathblocks_sequence_set_vector_shape(output, selected);
                    for (int index = 0; index < selected; index++)
                        if (!float.IsFinite(result[index])) output->valid = 0;
                    break;
                }
            }
            if (output->valid &&
                opcode != 0 && opcode != 1 && opcode != 3 && opcode != 4 && opcode != 5 &&
                opcode != 10 && opcode != 19 && opcode != 20 && opcode != 21 &&
                !float.IsFinite(output->scalar_value))
            {
                output->valid = 0;
            }
        }
    }
}
