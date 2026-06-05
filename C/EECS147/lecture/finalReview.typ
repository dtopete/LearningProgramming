= Thursday May 28th Exam 2 Review

= Matrix Multiplication
Assume a tiled matrix mult that handles boundary conditions. Assume that we use 32x32 tiles to process square matrices of 1000x1000.

- How many thread blocks are launched?
  - ceil(1000/32) = 32 tiles in each dimension, so 32x32 = 1024 thread blocks total.
  - 32x32 = 1024 thread blocks

- How many warps, in the entire kernel, will have control divergence due to handling boundary conditions when writing to the output matrix
  - Each warp has 32 threads, so 1024 thread blocks x 32 threads/block = 32768 threads total.
  - When writing to the output matrix, so the last tile will have control divergence because the threads in the last tile will be accessing out of bounds memory locations, which will cause some threads to execute different instructions than others.
  - The last tile will have the divergence, in the X dimension will have divergence of threads overlapping the boundary, with 32 threads in each row and 8 threads in the last row, there are 1000 rows so 1000 warps will have divergence in the X direction *(VERIFY)*
  - The Y axis will have no divergence because all threads in the last tile will be accessing valid memory locations in the Y direction, so 0 warps will have divergence in the Y direction.

- For an untiled mat mul multiplication kernel, assume we have an M and N matrix of size 32x32. How many total global memory loads are issued to matrix M?
  - 32x32x32 = 32768 global memory loads for matrix M
  - Every element in M is accessed by 32 threads
  - Each element is needed for 32 threads (Matrix A has 32, Matrix B has 32, so each element in M is needed for 32 threads in the output matrix)

- For the output matrix P, how many stores to global memory are issued?
  - 32x32 = 1024 stores to global memory for the output matrix P
  - We store each element once, and there are 32x32 elements in output matrix P


- For our tiled mat-mat multiplication kernel, if we use 32x32 tiles, how many global memory loads are issued to matrix M?
  - Each tile of M is loaded once, and there are ceil(1000/32) = 32 tiles in each dimension, so 32x32 = 1024 tiles total.
  - Each tile has 32x32 = 1024 elements, so total global memory loads for matrix M is 1024 tiles x 1024 elements/tile = 1,048,576 global memory loads for matrix M.


- For the tiled single-precision (32bit) mat mult kernel
*(FINISH THIS(FINISH THIS)(FINISH THIS)(FINISH THIS)(FINISH THIS)(FINISH THIS)(FINISH THIS)(FINISH THIS)(FINISH THIS))*

#pagebreak()
= Conceptual
For the following, explain how it could harm performance and possible ways the program can be modified to reduce this effect. Be specific
- The application needs to access global memory to get one value for every operation. 
  - How this harms performance:
    - Memory access is slow. Can cause stalls and bottleneck memory

  - Techniche / Change that could reduce this effect:
    - Use shared memory to cache values that are accessed multiple times, reducing the number of global memory accesses.
    - Use registers to store frequently accessed values, which are much faster than global memory.
    - Optimize memory access patterns to ensure coalesced accesses, which can improve memory throughput.

= Atomics
Atomic operations perform r-m-w operations all in a single cycle. In the following instruction `atomicAdd(&Sum, 1)`, explain what happens when multiple threads execute this instruction concurrently. How does the atomic operation ensure correctness, and what are the potential performance implications of using atomic operations in a highly parallel context?
  - Reading? The value of Sum
  - Modifying? Sum + 1
  - Writing? Sum + 1 to Sum
Why do we need atomic operations?
  - To avoid race conditions

= Race conditions
Assume two threads running the following `Mem[x] = 2` initially:

`thread 1: old <- Mem[x] 
New <- old + 5
Mem[x] <- New

thread 2: old <- Mem[x]
New <- Old + 2
Mem[x] <- New`

- What are the possible values of Old?
  - 2,4,7
- What are possible values of Mem[x]
  - 2,4,7,9
- Assume the value to be invremented (5 and 2) is stored in variable, value. What is the corresponding atomicAdd call to ensure this example works?
  - `atomicAdd(&Mem[x], value)` *Check*

#pagebreak()
= MCQ (some may be repeats)
To perform an atomic add op to add the val of an int var Partial to a global mem int var Total. Whcih one of the following statements should be used?
  - `atomicAdd(&Total, Partial)`

DMA Hardware transfers data between
  - Physical addresses

cudaMalloc allocates mem in:
  - Global memory (device memory)

Assume the following simple mat mul kernel (non-tiled)
```C
__global__ void matMul(float* A, float* B, float* C, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    float sum = 0.0f;

if( (Row < Width) && (Col < Width) ) {
    float Pvalue = 0;
    for (int k = 0; k < Width; ++k) { Pvalue += A[row * Width + k] * B[k * Width + col]; }
    C[row * Width + col] = Pvalue;
 }
}
```
Assume a square 1000x1000 matrix. Which of the following is true?
- We are writting to each element once per thread
- Every eleent in C will be written once
- Every element in A and B will be accessed 1000 times


#pagebreak()
= Histogram
Code block shows a histogram kernel
```C
__global__ void histogram(int* data, int* hist, int N, unsigned int numBins) {
  int j = threadIdx.x;
  while (j < 4096){
    __synchthreads();
    private_hist[j] = 0;
    j += blockDim.x;
  }
  __synchthreads();
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  int stride = blockDim.x * gridDim.x;
  while (i < N) {
    atomicAdd(&hist[data[i]], 1);
    i += stride;
  }
  __synchthreads();
  j = threadIdx.x;
  while (j < 4096) {
    atomicAdd(&hist[j], private_hist[j]);
    j += blockDim.x;
  }
  __synchthreads(); // Not necessary
}
```
In this histogram kernel above, which of the synchtreads are required?
- D, it is the end of the kernel

In the first while loop, how many times is 0 written in to private_hist[0]?
-  Block dimension is 1 (or something like that *verify*)

How many atomic add ops are performed in private_hist[] array?
- The size of hte total array, so `size`

How many atomic add ops are issued to hist[2019]?
- will be added gridDim.x times

#pagebreak()
= Dynamic Parallelism
What could be a potential issue in the following code block?
```C
__global__ void libCall(float *a, float *b, float *c) {
  createData(a,b);
  __syncthreads();
  // lib call to cublas
  cublasDgemm(a, b, c);
  cudaDeviceSynchronize();
  __syncthreads();
  consumeData(c);
}
```
* verify*

= GPU Sharing
- In Kepler arch with MPS, the MPS server allows 32 concurr streams. The limit for each PS client is 2 streams
+ How many is the max MPS cient that the server can allows to run concurrently?
  - 32 clients
+ What happens if an MPS client has more than 2 streams?
  - The client puts it into a FIFO and gets serialized
  - Streams get serialized after 2 streams, so the client will have to wait for the first 2 streams to finish before it can execute the next stream
  

#pagebreak()
= Tuesday Review, June 2nd
- Why is this final on Thursday...
= Atomics
=== Instead of reduction tree, reduction can also be implemented usign only atomic operations. Complete following atomic reduction kernel.
Assume our reduction operation performs addition.

```C
__global__ void atomicReduction(float* result, float* in, int size) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  int stride = blockDim.x * gridDim.x;
  while (i < size) {
    atomicAdd(result, in[i]); // result += in[i]
    i += stride;
  }
}
```

= Matrix Multiplication
=== Assume tiled materix that handles boundary conditions. Assume 16x16 tiles to process square matrices of 999x999.

+ How many thread blocks are launched?
  - ceil(999/16) = 63 tiles in each dimension, so 63x63 = 3969 thread blocks total.
+ How many warps, in the entire kernel, will have control divergence due to handling boundary conditions when writing to the output matrix?
  - The last tiles will have control divergence, in the X dimension will have divergence of threads overlapping the boundary, with 16 threads in each row and
  - We are only having divergence in the X direction, so 999 rows so 999 warps will have divergence in the X direction
  - We have 16x16 tiles, each tile has 16 warps, so 16 warps per tile x 63 tiles in Y dimension = 1008 warps total, but only 999 warps will have divergence, so 999 warps will have control divergence due to handling boundary conditions when writing to the output matrix.
  - Two rows make up a warp, so 999 rows will have 999/2 = 499.5 warps with divergence, so 500 warps will have control divergence due to handling boundary conditions when writing to the output matrix in the Y direction.
  - X direction has 63 blocks - 1 (double counting) = 62
  - 500 + 62 = 562 warps will have control divergence due to handling boundary conditions when writing to the output matrix.

+ Assuming single precision (32bit) data types, how much shared memory space (in Bytes) is req for each thread block?
  - Two input matrices, A and B, are loaded into shared memory for each tile. Each tile is 16x16, so each tile has 256 elements. Each element is 4 bytes (32 bits), so each tile requires 256 x 4 = 1024 bytes of shared memory. Since we have two tiles in shared memory (one for A and one for B), the total shared memory space required for each thread block is 1024 bytes x 2 = 2048 bytes.
  - Summing to 2KB of shared memory per thread block.

  - Each tile has 16x16 = 256 elements, each element is 4 bytes (32 bits), so each tile requires 256 x 4 = 1024 bytes of shared memory.
  - We have two tiles in shared memory (one for A and one for B), so total shared memory space required for each thread block is 1024 bytes x 2 = 2048 bytes.
+ How many floating point operations (mul/add) are performed for each global memory load per tile? Hint: Identify the number of operations performed per tile and the number of global memory loads per tile. 
  - (16x16x16x2) operations / (2x16x16) loads = 16 floating point operations per global memory load per tile (operations per tile = 16x16x16x2, loads per tile = 2x16x16)
  *Below is supplemental*

  - Each tile computes a 16x16 output tile, which requires 16x16 = 256 output elements. Each output element is computed using a dot product of a row from A and a column from B, which involves 16 multiplications and 15 additions (since the first multiplication does not require an addition). Therefore, each output element requires 16 multiplications and 15 additions, for a total of 31 floating point operations per output element. Since there are 256 output elements in the tile, the total number of floating point operations performed for each tile is 256 x 31 = 7936 floating point operations.

  - Each tile requires loading two tiles from global memory (one for A and one for B), so there are 2 global memory loads per tile.
  - Therefore, the number of floating point operations performed for each global memory load per tile is 7936 floating point operations / 2 global memory loads = 3968 floating point operations per global memory load per tile.

== MCQ Mat Mult
+ For a tiled matrix mult kernel, if we use 32x32 tile, in each phase what is the reduction of memory bandwidth usage for in matrix M and N compared to an untiled mat mul kernel?
  - In an untiled mat mul kernel, each element of M and N is loaded from global memory for each output element, so each element is loaded 32 times (for a 32x32 matrix). In a tiled mat mul kernel, each tile of M and N is loaded once into shared memory, and then reused for all output elements in that tile. Therefore, the reduction in memory bandwidth usage for matrix M and N compared to an untiled mat mul kernel is 32 times.
  - ~1/32 of the original usage
+ In simple non-tiled mat mult kernel, which of the following is true regarding access to mat M and N? Assume 32x32 thread block size.
  - Access to N[] are not coalesced
  - Accesses to N[] are coalesced *TRUE*
  - Accesses to P[] are not coalesced
  - None of the above
  The true

== Memory MCQ
+ Which of the following accesses to A[] results in coalesced memory access?
    - `A[threadIdx.x]` *TRUE*
    - `A[threadIdx.x * 2]` *FALSE* (strided access, not coalesced)
    - `A[100 + threadIdx.x]` *TRUE*
+ Which of the follwing mem locations can atomic operations be performed on?
  - Global memory (device memory) *TRUE*
  - Shared memory *TRUE*
  - Local memory (registers, for threads only) *FALSE*
  - L1 cache *FALSE* (no control)
  - L2 cache *FALSE* (no control)

== Unified Mem
=== Choose all that happens after the following schenarion where no *cudamemadvise* has been specified

Page 4 goes to A's Memory

B's phys memory gets page5 of B's memory

- Page 5 is maped out of B's memory *TRUE*
- Page 5 is not mapped out of B's memory
- All the pages in A's memory are apped out and migrated to B's memory
- A page is unmapped migrated out of A's memory to B's memory *TRUE*, GPU makes space
- Page 5 is migrated into A's memory *TRUE*, GPU migrates page 5 into A's memory

Which of the following enables read duplication?
- `cudamMemAdviseSetReadMostly` *TRUE* (memory that will always be read, so it can be duplicated across multiple memory locations to improve read performance)
- `cudaMemAdviseSetPreferredLocation` *FALSE*
- `cudaMemAdviseSetAccessedBy` *FALSE*

=== Given the code
```C
char *data;
cudaMallocManaged(&data, N);
init_data(data, N); //CPU function
cudaMemAdvise(data, N, cudaMemAdviseSetPreferredLocation, gpuID);
myKernel<<<blocks, threads>>>(data);
use_data(data, N); //CPU function
```
In the code above, when we call the function use_data(data, N) where will the data reside?
- GPU (gpuID) *TRUE* (since we set the preferred location to gpuID, the data will be migrated to the GPU when it is accessed by the kernel, and it will remain on the GPU until it is accessed by the CPU again)
- CPU (cpuID)

== Memory
=== Which instruction in the following sequence of memory accesses will lead to a bank conflict?
- Row0,col0
- row0, col1
- 0, 85
- 1, 0 (bank conflict, since it accesses the same bank as row0, col0)
- 1, 12

DRAM bursts happen when -
 - COnsecutive memory locations are accessed
 - Majority of locationswithin the burst will be accessed
 - All the time *TRUE* (DRAM bursts can happen when consecutive memory locations are accessed, and the majority of locations within the burst are accessed, but it can also happen *all the time* if the access pattern is such that it triggers the DRAM burst mechanism)
  - This is part of memory coalescing, where the GPU tries to combine multiple memory accesses into a single burst to improve memory throughput. If the access pattern is such that it triggers the DRAM burst mechanism, then DRAM bursts can happen all the time, regardless of whether consecutive memory locations are accessed or not.

=== A kernel reads from memory locations 0 - 63. Each DRAM bursts transfers 8 memory locations. There are 16 threads in the kernel and they access every 4th location i.e. 0,4,8...

+ Are the memory accesses coalesced?
  - No, not accessing consecuritve memory elements
+ How many DRAM busts will be required for the kernel?
  - 64/8 = 8 DRAM bursts, since each burst transfers 8 memory locations, and there are 64 memory locations being accessed (0-63), so 64/8 = 8 DRAM bursts will be required for the kernel.

= Multi GPU
=== In a mutli-GPU sys using 16 GPUs, how many transfers happen concurrently at each stage (left/right)? We are in a tree
- 15 transfers that can happen concurrently (nGPUs - 1, since one GPU is the root and does not transfer to itself)

=== In the following sytsem, if PCIE-PCIE bandwidth is 5GB/s and PCIE-IOH is 4GB/s, what is the the total bandwidth of the right transfer stage
Note: There are 8 GPUs, GPU0 to GPU7, using an IOH
- 5*6 + 4 = 34 GB/s, since there are 5 PCIE transfers that can happen concurrently at the right transfer stage, each with a bandwidth of 5GB/s, and there is also one PCIE-IOH transfer with a bandwidth of 4GB/s, so the total bandwidth of the right transfer stage is (5 x 5) + 4 = 34 GB/s.

=== Multi GPU System Scenario
+ Which transfer would be the fastest?
  - GPU0 to GPU1 
  - 1 to 2
  - 2 to 3 (Connected via PCIe switch)

+ Whcih transfer would be the slowest?
  - GPU1 to 2 (Connected via IOH)

= Collective Communication
=== Which would be faster for collective comm?
- Transfering all data together
- Transferring data in chunks *TRUE*

=== Broadcasting in multi-GPU system with k GPUs takes how much time when size of bytes to be broadcast in N and bandwidth is N and bandwidth of each link is B?
- N(k-1)/B