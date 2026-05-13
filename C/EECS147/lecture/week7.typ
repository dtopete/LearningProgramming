Tuesday week 6 Lecture
= Histograms
- A method to extracting notable features and patterns from large datasets
- Feature extraction for object recognition in images
- Fraud detection in credit card transactions

- Basic histograms

== Read-modify-write Text Histogram Example (Data Race)
- If multiple bank tellers have a count of total amount of cash in a safe
- Each grab a pile and count
- Have central display of running total
- Whenever someone finishes counting a pile, read the current running total (read), and add subtotal of the pile to the running total (modify-write)
- A bad outcome beause some piles were not accounted for in the total write
- Hence, the Read-modify-write pattern is a common source of data races
  - Data is read, modified, and written back to memory without proper synchronization

== Data Race without Atomic Operations
- If multiple threads perform read-modify-write operations on the same memory location without synchronization, it can lead to a data race
```C
Code
```
- Both threads receive - in Old
- Mem[x] becomes 1

=== Key concepts of Atomic Operations
- R-M-W operations perform by a single hardware instruction on a memory location address
- Atomic operations are indivisible, meaning that once a thread starts an atomic operation, no other
    - Read the old value, calculate the new value, and write the new value to the location
- Basically just a semaphore, lock, or mutex that protects the critical section of code that performs the R-M-W operation
- Atomic operations are used to prevent data races

- For a mutex, it is 
```C
mutex(lock)
{
    // critical section
}
mutex_unlock(lock);
```

#pagebreak()
== Basic Text Histogram Kernel
```C
__global__ void histogram_kernel(unsigned char* buffer, long size, unsigned int *histogram) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;

// Stride is total \# of threads in the grid
  int stride = blockDim.x * gridDim.x;

  while (i < size) {
    // Atomic operation to prevent data races
    int alphabet_position = buffer[i] - 'a';
    if(alphabet_position >= 0 && alphabet_position < 26) {
      atomicAdd(&(histogram[alphabet_position/4]), 1);
    }
    i += stride;
  }

}
```
- Issues with the code, if all locations are writting to the same location, then the code will be serialized and will not be efficient
- To fix this, we can use a local histogram for each thread block and then combine the local histograms into a global histogram at the end of the kernel

= Atomic Operation Performance

== Atomic Operation on Global Memory (DRAM)
- Atomic operations on DRAM location starts with a read, which latency of a few hundred cycles, and then a write, which also has a latency of a few hundred cycles
- Then this defeats the purpose of parallelism because the threads will be serialized and will not be efficient
- Each R-M-W op has two full mem access delays
  - All atomic ops on the same variable (DRAM location) will be serialized, which can lead to a performance bottleneck

== Latency Determines throughput
- Thourghput of atomic opeartions on the same DRAM location is the rate at which applications can ex an atomic op
- Rate of atomic op for particular location is limited to tot lat of the R-M-W op, which is the sum of the read and write latencies

== Hardware Improvements
- Atomic Operations on Fermi L2 Cache
  - Medium lat, about 1/10 of DRAM latency
  - Shared among all blocks
  - "Free Improvement" on Global Memory atomics
- Atomic Operations on Shared Memory
  - Very low latency, about 1/100 of DRAM latency
  - Shared among threads in the same block
  - "Free Improvement" on Shared Memory atomics
  - There's a private copy of the data per each block, so no contention between blocks
  - Need algorithm work by programmers 

#pagebreak()
= Privatization Technique for improved throughput
- Heavy contention and serialization 
- Privatization technique to reduce contention and improve throughput
- There would be a shared memory copy of the histogram for each block, and then at the end of the kernel, we would combine the local histograms into a global histogram
- This would reduce contention and improve throughput because each block would be working on its own local histogram

== Cost and Benefits of Privatization
- *Cost*: Additional memory usage for local histograms, and additional computation to combine local histograms
- Overhead For creating and initializing local histograms, and for combining local histograms into a global histogram at the end of the kernel
- *Benefits*: Reduced contention and improved throughput, especially for large histograms with many bins
- 10x improved performance for 256-bin histogram, and 100x improved performance for 1024-bin histogram

#pagebreak()

== Shared Memory Atomic for Histogram

- Less contention - only threads in the same block will be contending for the same shared memory location, which can lead to improved performance
- Very important use case for shared memory
- Each ubset of threads are in the same block, so they can use shared memory to store their local histogram, and then at the end of the kernel, they can combine their local histograms into a global histogram in global memory
- Higher througput than DRAM (100x) or L2 cache (10x) atomics, but still has some overhead due to contention between threads in the same block
```C
__global__ void histogram_kernel(unsigned char* buffer, long size, unsigned int *histogram) {
  __shared__ unsigned int local_histogram[7];

if (threadIdx.x < 7) {
    local_histogram[threadIdx.x] = 0;
  }
  __syncthreads();

  int i = threadIdx.x + blockIdx.x * blockDim.x;
  int stride = blockDim.x * gridDim.x;

  while (i < size) {
    int alphabet_position = buffer[i] - 'a';
    if(alphabet_position >= 0 && alphabet_position < 26) {
      atomicAdd(&(local_histogram[alphabet_position/4]), 1);
    }
    i += stride;
  }
  __syncthreads();

  if (threadIdx.x < 7) {
    atomicAdd(&(histogram[threadIdx.x]), local_histogram[threadIdx.x]);
  }
  __syncthreads();
}

```

=== Build Privacy Histogram with Shared Memory Atomics
```C
int i = threadIdx.x + blockIdx.x * blockDim.x;
int stride = blockDim.x * gridDim.x;
while (i < size) {
  int alphabet_position = buffer[i] - 'a';
  if(alphabet_position >= 0 && alphabet_position < 26) {
    atomicAdd(&(local_histogram[alphabet_position/4]), 1);
  }
  i += stride;
}
__syncthreads(); // Make sure all the threads are done
if (threadIdx.x < 7) {
  atomicAdd(&(histogram[threadIdx.x]), local_histogram[threadIdx.x]);
}
```

#pagebreak()
== More on Privatization
- Powerful and frequently used for parallelizing applications
- Operations must be associative and commutative to be parallelized using privatization
- Examples of associative and commutative operations include addition, multiplication, and logical operations
- Non-associative and non-commutative operations cannot be parallelized using privatization, such as subtraction and division
- Privacy historygram size *must be small* to fit in *shared memory*
- If Histograms are too large, you must partially privatize, which means that you would have multiple local histograms per block, and then at the end of the kernel, you would combine the local histograms into a global histogram in global memory
  - You break up the histogram into chunks either in global or shared memory, and then you would have multiple local histograms per block, and then at the end of the kernel, you would combine the local histograms into a global histogram in global memory

*Histogram will be assignment 4, the code is on the slides*
- Mat Mul is one of the trickier assignments, start is now