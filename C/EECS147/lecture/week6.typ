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
