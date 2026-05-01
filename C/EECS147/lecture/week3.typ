= Back to Reduction from previous lecture
- Things to note, assignment 2 posted

Reduction sum ends up moving the thread to the left most thread

```C
for (unsigned int stride =1 ; stride <= blockDim.x; stride *=2){
  _syncthreads();
  if(t % stride == 0){
    partialSum[2*t] += partialSum[2*t + stride];
  }
}
```

For an example of 4 threads, we would want all threads to be active
- We start with a stride of 1 and keep halfing it each time, so we have 4 threads active, then 2 threads active, then 1 thread active

- Assignment will have something related to warp divergence, which is when threads in the same warp take different execution paths, leading to performance degradation.
-- There will be inactive threads in a warp and fewer threads upon each iteration, which can lead to inefficient execution.

= CUDA Pinned Memory \& CUDA Streams
- CUDA pinned memory is a type of memory that is allocated on the host (CPU) and is page-locked, meaning it cannot be swapped out to disk. This allows for faster data transfer between the host and the device (GPU) because it can use direct memory access (DMA) instead of going through the CPU.
- CUDA streams are a sequence of operations that are executed in order on the GPU. They allow
for concurrent execution of multiple operations, which can improve performance by overlapping computation and data transfer. Each stream can execute independently, allowing for better utilization of the GPU resources.

== CPU-GPU Data Transfer using DMA
- DMA (Direct Memory Access) allows for data transfer between the host and device without involving the CPU, which can significantly improve performance. When using pinned memory, the GPU can directly access the data in the host memory, reducing latency and increasing throughput.
-- Used by cudaMemcpy() for better efficiency
-- Frees up CPU and prevents bogging down the system
-- Hardware unit specialized to transfer a number of bytes request by OS
-- Between physical memory address space regions 
-- Uses system interconnect (PCIe) to transfer data between host and device

== Virtual Memory Management
- Modern computers use virtual memory management 
-- Each virt addr spacve is divided into pages (4KB) that are mapped ito and out of the phys memory by the OS
-- Virt Mem pages can be paged out of phys memory to make room for other pages, and paged back in when needed
-- Whether or not a variable is in phys memory is checked at address translation timeo

= Pinned Memory and DMA Data Transfer
- Pinned memory is page-locked, meaning it cannot be paged out to disk. This allows for faster data transfer between the host and device using DMA, as the GPU can directly access the data in the host memory without involving the CPU.
-- They cannot be paged out
-- Allocated with special API (cudaMallocHost) and freed with cudaFreeHost
-- CPU memory that serves as the soruce or destination of a DMA transfer must be pinned memory

== CUDA Data transfer uses pinned memory
- We never worked with memory in the lab, it was all abstracted by cudaMemcpy()
- DMA used by cudaMemcpy() requires any source or destination in the host memory is allocated as pinned memory.
- If Source or Destination of cudaMemcpy() is not pinned memory, it needs to be first copied to a pinned memory - extra overhead

== Allocate/Free Pinned Memory
- cudaHostAlloc(), three parameters
+ Address of pointer to alloc memory
+  Size of alloc memory in bytes
+  Option - use `cudaHostAllocDefault` for default behavior, `cudaHostAllocPortable` to make it accessible by all CUDA contexts, `cudaHostAllocMapped` to map it into the device's address space, and `cudaHostAllocWriteCombined` for write-combined memory that is optimized for write operations.
- cudaFreeHost() to free pinned memory, one parameter
+ Pointer to pinned memory to free

== Using Pinned Memory in CUDA
- Use allocated pinned memory and its pointer the same wayt as those returned by `malloc();`
- Only difference is that allocated memory is page-locked and cannot be paged out to disk, which allows for faster data transfer between host and device using DMA.

== Putting it together - Vector Addition Host Code Example
```C
int main(){
  float *h_A, *h_B, *h_C; // Host pointers
...

cudaHostAlloc((void**)&h_A, N* sizeof(float), cudaHostAllocDefault);
cudaHostAlloc((void**)&h_B, N* sizeof(float), cudaHostAllocDefault);
cudaHostAlloc((void**)&h_C, N* sizeof(float), cudaHostAllocDefault);
...
// cudaMemcpy() runs 2x faster with pinned memory

}

```
#pagebreak()

= Serialized Data Transfer and Computation
- So far, the way we use `cudaMemcpy()` serializes data transfer and GPU computation for `VecAddAKernel()`

== Device Overlap
- Some CUDA devices support device overlap
-- Simulataneous execute a kernel while copying data between host and device

== Ideal, Pipelined Timing
- Divide large vectors into segments
- Overlap transfer and compute of adjacent segments
-- In the pipeline, we are copying in the data as we are computing the data.
We are parallelizing the data transfer and computation, which can lead to significant performance improvements by reducing idle time for both the CPU and GPU.

= CUDA Streams
- CUDA supports breaking things into concurrent streams of execution, which can be used to achieve device overlap.
- Each stream is a queue of operations that execute in order on the GPU, but different streams can execute concurrently. This allows for overlapping data transfer and computation, improving performance by maximizing GPU utilization.
- Operations (tasks) in different streams can go in parallel
-- "Task parallelism" - different tasks in different streams can execute concurrently

== Streams
- Requests are made from the host code are put in FIFO queues
- Queues are read and processed asynchronously by the driver and device

- To allow concurrent copy/execution, you require multiple streams
- CUDA "events" allow the host thread to query and synchronize with individual queues

== Conceptializing View of Streams
- Stream 0 goes into copy engine
- Stream 1 goes into compute engine

#pagebreak()
== Simple Multi-Stream Host Code Example
```C
cudaStream_t stream0, stream1;
cudaStreamCreate(&stream0);
cudaStreamCreate(&stream1);
// Copy data for stream 0

for(int i = 0; i<n; i+= SegSize*2){
  cudaMemcpyAsync(d_A0 , h_A + i, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream0);
  cudaMemcpyAsync(d_B0 , h_B + i, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream0);
  VecAddAKernel<<<gridSize, blockSize, 0, stream0>>>(d_A0, d_B0, d_C0, SegSize);
  cudaMemcpyAsync(h_C + i, d_C + i, SegSize*sizeof(float), cudaMemcpyDeviceToHost, stream0);

  // Copy data for stream 1
  cudaMemcpyAsync(d_A1 , h_A + i + SegSize, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream1);
  cudaMemcpyAsync(d_B1 , h_B + i + SegSize, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream1);
  VecAddAKernel<<<gridSize, blockSize, 0, stream1>>>(d_A1, d_B1, d_C1, SegSize);
  cudaMemcpyAsync(h_C + i + SegSize, d_C + i + SegSize, SegSize*sizeof(float), cudaMemcpyDeviceToHost, stream1);
}

```
- We have two streams, not completely ideal because we have slight overlap, but we can have more streams to further improve performance by increasing the granularity of the tasks and allowing for more concurrent execution.
- We can reorder these asynchronous instructions for further optimization of pipeline.
- Have kernel 0 for copy the data and kernel 1 for computing the data, so we can have more overlap and better performance.
```C
for (int i=0;i<n; i+=SegSize*2){
  // Copy data for stream 0
  cudaMemcpyAsync(d_A0 , h_A + i, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream0);
  cudaMemcpyAsync(d_B0 , h_B + i, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream0);

  // Copy data for stream 1
  cudaMemcpyAsync(d_A1 , h_A + i + SegSize, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream1);
  cudaMemcpyAsync(d_B1 , h_B + i + SegSize, SegSize*sizeof(float), cudaMemcpyHostToDevice, stream1);

  // Compute for stream 0
  VecAddAKernel<<<gridSize, blockSize, 0, stream0>>>(d_A0, d_B0, d_C0, SegSize);
  cudaMemcpyAsync(h_C + i, d_C + i, SegSize*sizeof(float), cudaMemcpyDeviceToHost, stream0);

  // Compute for stream 1
  VecAddAKernel<<<gridSize, blockSize, 0, stream1>>>(d_A1, d_B1, d_C1, SegSize);
  cudaMemcpyAsync(h_C + i + SegSize, d_C + i + SegSize, SegSize*sizeof(float), cudaMemcpyDeviceToHost, stream1);
}
```

#pagebreak()
=== Now, the completely ideal Pipelined Timing
- We would need 3 buffers for our code
-- After the first computation, we have stream0 with the C0 transfer, stream1 with C1 = A1 + B1, and stream 2 with A2 and B2 transfer.

-- Wouldn't be possible with 2 streams becuase of the transfer of the previous result and the next transfer of the next data concurrently without another stream to handle the next transfer.

== Wait until all tasks have completed
- `cudaStreamSynchronize(stream_id)` to wait for all tasks in all streams to complete for current device
-- Takes one parameter - stream identifier
-- Wait all tasks in a stream to complete
-- `cudaStreamSynchronize(stream0)` to wait for all tasks in all streams to complete for current device

- `cudaDeviceSynchronize()` to wait for all tasks in all streams to complete
-- Also use for host code
-- No parameter

= Midterm on week5
- They will be quite conceptual
- What order is this code executed in?
- What's missing from this code?
-- nothing too complicated, just basic understanding of how to use streams and pinned memory
-- Answers from reports on the assignment
- Seems like everything until today's lecture
-- In class, week5 Tuesday

#pagebreak()
= Talking About Projects

- Any application that would be faster on GPUs
- Even better if I can merge a project that I am already working on in another class
-- Lowkey, databases, GPU Accelerated Database accelerators
- GPU Netowrk Packet Processing (mini DPDK)
-- Simulate or implement pakcet processing on GPU
- GPU-Based Log Processing / Search Engine
-- Big search engine over large logs

-- Then ranking the results

- Bioinformatics: Sequence Alignment (GPU BLAST-lite)

- GPU Graph Processing Engine
Implement:
-- BFS/DFS
-- PageRank

- GPU Cryptography (Hashing / Encryption)

- GPU Compression / Decompression Engine
-- Seems very interesting

-- Parallel decompression of large files using GPU
- Parallel SAT Solver / Constraint Solver
- Graphics Ray Tracer (Progressive Path Tracing)
-- Start: Spheres + Basic light

- Real-Time Volumetric Rendering (Fog/Smoke)
-- Rendering fog, smoke, clouds

-- Simulating light scattering

- Real-time Fluid SImulation (Stable fluids in 2D)
-- 2D Fluid solver, of velocity + preassure grids

- GPU Terrain Rendering + LOD

- Neural Rendering (Tiny NeRF / Instant-NGP)

- Image Processing Pipeline on GPU
-- Build a GPU image pipeline, then applying a number of filters and processing

-- Lowkey, sharpening of anime in real time would be awesome

-- Real time using webcam feed or anime video feed

- FlashAttetnion-style Kernel from scratch
-- Not very easy to do, naive version from PyTorch

- Fuck around and simulate a black hole or something

- KV Cache Optimization for LLM Inference

- Custom GPU Kernel for Softmax / Reduction
-- Kernel fusion, input PyTorch model graph

-- Fuse: Matmul + bias + activation

-- Softmax + scaling

- Mixed Precision + Quantization Kernel Study
-- Implement kernels for: FP32 vs  FP16 vs BF16

-- Measure: Accuracy loss, speedup, Memory savings

- Project Proposal gets submitted Week 5 Thursday!!
-- Week5 Tuesday is the midterm, 2 page short report

-- Mentions the scope of the project and technologies needed to run in Bender

- With many of these projects, you can find resources online, try to know that you can understand and make a presentation and Q/A on this

#pagebreak()
= One of the main Ideas
+ Filters
- Can apply automatic filters to your images, such as grayscale, saturation
- Gaussian blur and more intense with edge detection, computer vision stuff

#pagebreak()
= Midterm Review
== Short brief look at the final project
- Submit your final project proposal and look through the website
to see information regarding Final Project
- One of the last lectures will be dedicated to final project presentations
- Can make the project in CUDA, OpenCL, HOP, C++, Numba, CUDA Python, etc

== back to midterm review
- We will cover CUDA streams, pinned memory, reduction, the stack, warps and divergence, and more

For the following basic reduction kernel code fragment, if block size is 2048 and warp size is 32. How many warps in a block will have divergence during the iteration where stride is equal to 1?
Stride equal to 32? Stride equal to 128?
```C
// Note, Naive reduction
// Naive has no divergence, but it is not very efficient because of the way it accesses memory and the fact that it does not take advantage of shared memory or other optimization techniques.
for (unsigned int stride =1 ; stride <= blockDim.x; stride *=2){
  _syncthreads();
  if(t % stride == 0){
    partialSum[2*t] += partialSum[2*t + stride];
  }
}
```
stride = 1: 0 warps will have divergence, because all threads will be active and executing the same instruction.

stride = 32: 2048 blocks / 32 threads per warp = 64 warps, and only the first 2 warps (threads 0-63) will be active and executing the instruction, while the remaining.
Every warp will have divergence, because only the first 2 warps (threads 0-63) will be active and executing the instruction, while the remaining warps will be inactive.


stride = 128: 2048 blocks / 32 threads per warp = 64 warps, and only the first 4 warps (threads 0-127) will be active and executing the instruction, while the remaining warps will be inactive, leading to divergence.
1 in every 4 warps will be active, so 1/4 of the warps will have divergence.


== Next Q
In a parallel Reduction implementation, each thread loads two input elements from global memory
to shared memory. The input elements are stored in:
`__shared__ float partialSum[blockDim.x * 2];`
For simplicity, you do not need boundary condition checking. Answer the following(hint: start with the thread indexing first)

Complete the ode for a thread to load two adjacent input elements (i.e. thread 0 loads [0] and [1], and thread 1 loads [2] and [3], etc) from global memory to shared memory.

`unsigned int start = 2*blockIdx.x * blockDim.x;`

`unsigned int t = ___; ` `{threadIdx.x}`

`partialSum[t] = input[start + ___];` `{t}`

`partialSum[t+1] = input[start + ___];` `{t + 1}`

#pagebreak()
= Next Q
You need to write a kernel that oeprates on am image of size 400x900.
You would like to allocate one thread to each pixel.
You would like the thread blcoks to be sqaure and to use the max number of threads per block possible on the device (assume 1536 thread limit and 8 thread block limit)

a) What would you select as the grid and block dimension?
- We would want to maximize the number of threads per SM
- We have the limitation of square blocks, so they must be x by x
- We have the options of 8x8, 16x16, 32x32, and 64x64 blocks, but we cannot use 64x64 because it exceeds the thread limit of 1536 threads per block.
- 16x16 = 256 threads per block, which is the largest square block size that does not exceed the thread limit. Giving us 6 blocks.
- 32x32 = 1024 threads per block, which is also a valid option, but it is not the maximum number of threads per block possible. Giving us 1 block

-16x16 is ideal because it allows us to use the maximum number of threads per block while still being a square block, which is a requirement. This would give us a grid dimension of (25, 57) and a block dimension of (16, 16).

- With a block size of 16x16, we have 256 threads per block, which means we have 256 / 32 = 8 warps per block.

#pagebreak()
= next Q
Below Vector Add kernel anwer the following question. Assume vector size of n, block
size of 256 threads and (n-1)/256+1 thread blocks.

```C
__global__ void VecAdd(int n, const float *A, const float *B, float *C) {
  for(unsigned int i = 0; i<n;i++){
    C[i] = A[i] + B[i];
  }
}
```
a) Does the kernel produce the desired result?
- Yes it does, just really stupid

b) How many additions are performed in this VecAdd compared to the VecAdd implemeted for assignment 1?
- Let nBlocks = `(n-1)/256 + 1, and nThreads = 256`
- This VecAdd: `256*nBlocks * n = 256 * ((n-1)/256 + 1) * n = 256 * (n/256) * n = n^2`

What about this vector add?
```C
__global__ void VecAdd(int n, const float *A, const float *B, float *C) {
  unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
  for(unsigned int j = 0; j < n; j += blockDim.x * gridDim.x) {
    C[j] = A[j] + B[j];
  }
}
```

c) How many total loads to memory are performed in this VecAdd compared to the VecAdd from assignemnt 1?
```
Let nBlocks = (n-1)/256 + 1, and nThreads = 256
This VecAdd: `256*nBlocks * n = 256 * ((n-1)/256 + 1) * n = 256 * (n/256) * n = n^2`
Lab 1 VecAdd: 2*n loads
```

d) Would this parallel VecAdd run faster or serial implementation of VecAdd?
Most likely the serial implementation would be faster as both code will run O(n) time,
but GPU has overhead of memory allocation/data transfer.
- CPU will perform this faster because they have faster cores than GPU cores, GPUs are just good at concurrency

= Next Q
Explain how this could harm performance and possible ways to program can be modified
to reduce this effect.

a) Application needs access global memory to get one value for every operation. Does this harm perf?

Memory accessis slow and can cause stalls, use shared memory to reduce global memory access and improve performance.


Control Divergence: (Warp divergence)

When threads in warp execute different code paths....

Technique /change that could reduce this effetct:
You can change thread indexing, like in reduction, to minimize divergence


a) DMA transfers data between what what types of addresses?

Looks into physical memory, requiring pinned memory for host memory transfers, and virtual memory for device memory transfers.

b) cudaMalloc allocates memory in:

- Device memory

c) cudaHostALloc allocates memory in:

- Pinned host memory

d) If your CUDA application has a single stream, can you concurrently copy data and execute a kernel?
- No, with a single stream, operations are executed sequentially, so you cannot concurrently copy data and execute a kernel. You would need to use multiple streams to achieve concurrent execution.

e) each CUDA stream is a `__` of operations
- sequence, a Queue of operations. Going FIFO. String of operations.

f) Commands (aka Events) in CUDA streams can be executed out of order?
- False, it is a queue of events, going FIFO

g) Which is false?
+ Events in CUDA streams are processed in FIFO
  - True
+ The OS can accidentally swap a page that is being transfered by DMA
  - False because pinned memory is locked
+ Kernel launches are CUDA events
  - True
+ Copies are CUDA events
  - True
+ ALL CUDA API calls are CUDA events
  - False

h) Following T/F

+ Virt mem addr are translated to memory addresses using page tables
  - True
+ All warps in thread blocks must execute the same instruction at the same time
  - False, this is warp divergence
+ Warps can finish at different times
  - True
+ In GPU, a scheduler exists to pick warps to issue for execution
  - True
+ PTX is an intermediate representation for GPU code
  - True, resides a layer above machine langauge of CUDA (SASS)
+ GPUs can boot an OS
  - False, they are not general purpose enough to boot an OS
+ If CUDA device's SM can take up 1536 threads and up to 8 threads whcih of the following is 1D block config?
  - 1024 Threads per block
  - 64 threads per block
  - 256 threads per block
    - The corrct answer here
  - 128 threads per block

+ Whcih of the following condition checks will cause warp divergence?
  - if (threadIdx.x > 4)
  - Meanwhile not, blockDim.x, blockIdx.x because the way they operate is that they are the same for all threads in a block, so they will not cause divergence