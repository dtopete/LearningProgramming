Week 6

May 5th, 2026
= Matrix Multiplication

- Tyically by doing this sequetially, we are going row by column
```C
int Row = blockIdx.y * blockDim.y + threadIdx.y;
int Col = blockIdx.x * blockDim.x + threadIdx.x;

// N is the width of the matrix

if (Row < N && Col < N) {
    float value = 0;
    for (int k = 0; k < N; ++k) {
        value += A[Row * N + k] * B[k * N + Col];
    }
    C[Row * N + Col] = value;
}

```

= Tiled Parallel Algorithms
- We can use shared memory to load tiles of the input matrices into shared memory, and then perform the multiplication on those tiles. This can significantly reduce the number of global memory accesses and improve performance.
```C
__global__ void MatrixMulKernel(float* A, float* B, float* C, int N) {
    __shared__ float As[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float Bs[BLOCK_SIZE][BLOCK_SIZE];
    int Row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    int Col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    float value = 0;
    for (int m = 0; m < N / BLOCK_SIZE; ++m) {
        As[threadIdx.y][threadIdx.x] = A[Row * N + m * BLOCK_SIZE + threadIdx.x];
        Bs[threadIdx.y][threadIdx.x] = B[(m * BLOCK_SIZE + threadIdx.y) * N + Col];
        __syncthreads();
        for (int k = 0; k < BLOCK_SIZE; ++k) {
            value += As[threadIdx.y][k] * Bs[k][threadIdx.x];
        }
        __syncthreads();
    }
    if (Row < N && Col < N) {
        C[Row * N + Col] = value;
    }
}
```

- We are loading tiles of the input matrices A and B into shared memory, and then performing the multiplication on those tiles. This can significantly reduce the number of global memory accesses and improve performance.

#pagebreak()
== Outline of Tiling Technique
+ Identifyt a tile of global memory to load into shared memory.
+ Load the tile from global mem into onchip shared memory.
+ Use barrier synchronization to make sure all threads are ready to start the phase
+ Have multiple threads to access their data from shared memory
+ Use barrier synchronization to make sure all threads are done with the phase
+ Move to the next tile, repate step 4

=== Now, Tiling memory in Matrix Multiplication
- We only load tiles of the input matrices A and B into shared memory, and then perform the multiplication on those tiles. This can significantly reduce the number of global memory accesses and improve performance.
- Phase 0, load Block (0,0) from A and block (0,0) from B into shared memory, and compute the partial product for block (0,0) of C. The block of (0,0) in both A and B are both loaded into shared memory, and then we compute the partial product for block (0,0) of C.
- To put it into context, for phase 0, lets say we have two computing blocks A and B, we have a 4x4 matrix, then in shared memory we take a 2x2 tile of A and a 2x2 tile of B, and then we compute the partial product for block (0,0) of C. Then we move to phase 1, we load block (0,1) from A and block (1,0) from B into shared memory, and compute the partial product for block (0,0) of C. We repeat this process until we have computed the entire matrix C.

= Now to the coding portion of Tiled Matrix Multiplication
- Each thread is responsible for computing one element
```C
int Row = by * blockDim.y + ty;
int Col = bx * blockDim.x + tx;
```
- This is similar to how we have strides that we jump over in between each computed tile

== Tile (Thead Block) Size Constraints
- Each thread bloick should have many threads
-- TILE_WIDTH of 16 gives 16*16 = 256 threads per block, which is a good number for occupancy on most GPUs.

-- TILE_WIDTH of 32 gives 32*32 = 1024 threads per block, which is the maximum number of threads per block on many GPUs. However, this may not always be the best choice for performance, as it can lead to increased register usage and reduced occupancy.

== Shared Memory and Threading
- Each SM has 16KB of shared memory
-- Shared memory size is implementation dependent
 
- For TILE_WIDTH of 16, we need 2 tiles of 16x16 floats, which is 2*16*16*4 bytes = 2048 bytes of shared memory, which is well within the shared memory limit.

- For TILE_WIDTH of 32, we need 2 tiles of 32x32 floats, which is 2*32*32*4 bytes = 8192 bytes of shared memory, which is also within the shared memory limit.
-- Allows 2 thread blocks active at the same time, which can help hide latency and improve performance.

- Syncthreads blocks all the threads in a block until they have all finished.
-- If all of these threads are waiting on a single slow thread, it makes synchreads to be blocking and cause stall. This is why we want to have a good number of threads per block, to help hide latency and improve performance.

== Handling Arbitrary matrix sizes in Tiled Algorithms
- If the matrix size is not a multiple of the tile size, we need to handle the edge cases where the tiles may go out of bounds. This can be done by adding boundary checks in the kernel to ensure that we do not access out-of-bounds memory.
- We would also need to turn off threads that are out of bounds, which can be done by adding a check at the beginning of the kernel to ensure that the thread is within the bounds of the matrix. If the thread is out of bounds, we can simply return from the kernel without doing any work.

== Boundary conditions for Input M Tile
- Each thread loads
```C
N[p*TILE_WIDTH + tx][Row]
N[p*TILE_WIDTH + ty][Col]
```
- For each thread, the conditions are different for loading M element or N element
- Calculating and storing output elements

- Effect of control divergence should be small for large matrices


== Handling General Rectangular Matrices
- In general, mat mul is deined in terms of rectangular matricoes
- j $crossmark$ k *M* mult with a k $crossmark$ I *N* gives a j $crossmark$  I *P*

- We represented square matrix multiplication, a special case

- Kernel function needs to be generalized to handle general rectangular matrices
-- Width argument is replaced by three arugments: j, k, i

-- when Width is used to refer to height of M or height of P, replace it with j

-- when width is used to refer to width of M or height of N, replace it with k

-- when width is used to refer to width of N or width of P, replace it with i

#pagebreak()
= Midterm Solutions
+ Thread and block question
    - How many warps in a block , 256/32 = 8 warps
    - How many tortal threads, 32*256 = 8192 threads

+ vecAddKernel question
    - int i = 8(threadIdx.x + blockDim.x*blockIdx.x);
+ Can vector add be made faster with shared memory?
    - No, because each thread is only accessing one element of the input arrays, so there is no reuse of data that would benefit from shared memory. The overhead of loading data into shared memory would likely outweigh any potential performance gains.
    - You would be doing a second memory copy for no reason, no benefit

+ Reduction 1,000 elements and block size of 256 threads
    - Reduction will take 9 steps, 256->128->64->32->16->8->4->2->1 
    - How many steps are divergent, 5 of them, ceiling function
    - Optimized kernel, warp distribution has 20 for W1, W2, W4, W8. Those are 5 divergent steps, because 1,000/256/2 = 20. 1 from each block.
        - This ges to show that 
+ The ones that don't diverge are D and E
    - Which one would you move in front of another one? Move D after F or G, but not under H
    - If SegSize = 256, and n = 8192, how many VecAdd kernels will launch? 8192/256 = 32 kernels, because we are doing a reduction, so we are halving the number of elements each time.

+ CUDA device's SM can take up 2048 threads and up to 32 thread blocks. which of the following 2D block config would be result in greatest number of threads in each SM
    - 32x32
+ How many streams to utilize all the kernel and copy engines on the GPU
    - Minimun of 3, but 4 isn't wrong

+ Going host to device
    - Host Mem -> Pinned Memory -> DMA Engine -> Global Memory

+ Memory type with fastests access speed 
    - Registers, they are on chip

+ Dev functions are only callable from kernel/device
+ cudaMemCopy is synchronous
+ Blocks don't depend on each other
+ SIMT core doesn't have 4 independent schedulers
+ all cudamemcpy 
+ Not true that max number of threads and blocks can reside in an SM is fixed per GPU vender

+ 2D kernel operate an ijmage of 500x800, assume thread block 16x16
    - x-dimension of grid size, 50
    - y-dim of grid size, 32
    - Warps will be divergent in this scenario, 0

+ Active Mask questions were quite easy
+ Assume kernel is launched with 100 thread blocks, each with 512 threads,
    - There will be 1 per block, so 100 blocks. 100 variations of s_var

#pagebreak()

= Memory Performance - Thursday Lecture

- Global Memory (DRAM) bandwidth
- It seems like there's a flood gate, but it really is a small straw
- Can't really program programs that way
- A very small (8x2-bit) DRAM core array
    - Programs generally have data locality, so we can take advantage of that to improve performance. We can use shared memory to load data into on-chip memory, and then access it from there, which can significantly reduce the number of global memory accesses and improve performance.

- DRAM core arrays are slow, reading from a cell in core array is a slow process
    - DDR: Core speed = $1/2$ interface speed
    - DDR2/GDDR3: Core speed = $1/4$ interface speed
    - DDR3/GDDR5: Core speed = $1/8$ interface speed
    - We are busy making things faster and tinier

- Do bursts of DRAM memory transfer
- DDR{2,3} SDRAM cores are clocked at 1/N speed of this interface:
    - DDR2: N = 4
    - DDR3: N = 8
    - GDDR5: N = 8
    - Loan N $crossmark$ of SDRAM

- Without DRAM bursts, we would spend a lot of time reading time from the core array, which is slow. By doing bursts, we can amortize the cost of reading from the core array over multiple data transfers, which can significantly improve performance.
- If we don't have bursts, we are reading all this data and doing only one transfer at a time for each read.
Doing bursts of doing transfers after another, so transfer out all the data after a buffer is full

== Multiple DRAM Banks
- Having multiple DRAM banks allows us to have multiple memory accesses in flight at the same time, which can help hide latency and improve performance. Each bank can be accessed independently, so if one bank is busy servicing a request, we can still access other banks.
- When one bank is transfering, have another one loading/reading in data
- This is good for making sure the memory interface is not idle and great utilization of memory bandwidth
- Each bank has a row cache

== DRAM Bursts - A System View
- First brust does data 0-3, then 4-7, then 8-11, then 12-15
- Each address space is partitioned into burst sections

== Memory Coalescing
- When threads in a warp access memory, if they access *contiguous memory addresses*, the memory accesses
== Uncoalesced Accesses
- When accessed locations spread across bursts section boundaries:
    - Coalescing is not possible, and each thread's access results in a separate memory transaction, which can significantly reduce performance.
    - Multiple DRAM requests are made
    - The access is not fully coalesced, and we end up with multiple memory transactions, which can significantly reduce performance.
- Some bytes accessed and transferred are not used by the threads, which can also reduce performance.
- When threads in a warp access memory, if they access contiguous memory addresses, the memory accesses
- This is when there loads are not correctly aligned and the bursts is missing some data and skipping it instead of doing the 4 consecutive elements at a time.

== How to judge if access is coalesced or not?
- Access in a warp are to consecutive locations if the index in an array access is in the form of
    - A[threadIdx.x + blockDim.x*blockIdx.x], where the thread index is the fastest changing index, and the block index is the slowest changing index. This ensures that threads in a warp access contiguous memory addresses, which allows for coalescing and can significantly improve performance.

== Basic Mat Mul
- Get one row and one column, and do the dot product to get one element of the output matrix. This is a simple and straightforward way to perform matrix multiplication, but it may not be the most efficient way to do it, especially for large matrices.
- The Matrix B in the diagram, where they are going veritical, these are coalesced accesses, because the threads in a warp are accessing contiguous memory addresses. However, the Matrix A in the diagram, where they are going horizontal, these are not coalesced accesses, because the threads in a warp are not accessing contiguous memory addresses. This can significantly reduce performance.
- Access in Mat A is growing sideways but each access is a row apart, but this is important because we are using two threads, and these threads are a row apart 
    - Meanwhile, matrix B of +2 memory locations ahead of each other instead of a row apart

== Tiling also optimized for coalescing
- You can tell in the code when it is coalesced when in the code, we have a +tx term
    - Then everything else is independent from tx, which means that the threads in a warp are accessing contiguous memory addresses, which allows for coalescing and can significantly improve performance.
    - As long as the tx term is independent, we should have independent memory access
- *May be on the final for detecting coalesced access*

#pagebreak()
= Modern GPU Memory
- We are covering HBM memory in the workstation GPUs, different from GDDR consumer GPU memory

== GDDR 6 vs 7 
- Higher data rate
- Different signaling
    - PAM3 signaling had two bits of data, 11, 01, and 00
    - PAM4 has GDDR7 and had two bits of data, sending out 4 bits worth of data, 11, 10, 00, 01
- More channels

== HBM Technology
- It is physically on the chip of the GPU meanwhile GDDR is on a separate chip, which means that HBM has much higher bandwidth and lower latency than GDDR. HBM also has a much smaller form factor than GDDR, which allows for more memory to be packed into a smaller space, which can be beneficial for high-performance computing applications.
- HBM is stacked memory, which means that multiple layers of memory are stacked on top of each other, and they are connected by through-silicon vias (TSVs). This allows for
- They are stacked in the base package substrate, they call it 3D (or 2.5D) stacking
- GDDR uses an interconnect to move data into the device, and farther away from the GPU, while HBM is on the same package as the GPU, which allows for much higher bandwidth and lower latency.

== Infinity Cache
- It keeps using more and more cache, and it is a large on-chip cache that is used to store frequently accessed data, which can help improve performance by reducing the number of memory accesses to the slower global memory. The Infinity Cache is designed to be a high-bandwidth, low-latency cache that can help improve performance for a wide range of applications, including gaming, machine learning, and high-performance computing.

== Modern GPU memory consideration
- Modern GPUs can be sliced up (Nvidia MIG, AMD Partitions)
- They support partitioning of memory, so that different applications can have their own partition of memory, which can help improve performance and reduce contention between applications. This is especially important in multi-tenant environments, where multiple applications are running on the same GPU.
- Each GPU Instance has it's own slices 