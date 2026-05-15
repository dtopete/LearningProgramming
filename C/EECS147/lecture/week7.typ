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

#pagebreak()
= Thursday week 6 Lecture

= Multi GPU
Minimal review on streams and asynch API
- We can do the memory transfer in one stream, and then do the kernel execution in another stream, and then we can use events to synchronize between the two streams
- This allows us to overlap the memory transfer and kernel execution, which can improve performance
- Asynch memcopy don't overlap unless you use streams and events to synchronize between the memory transfer and kernel execution.
- If you do not use streams and events to synchronize between the memory transfer and kernel execution, then the memory transfer and kernel execution will be serialized, which can lead to a performance bottleneck

Communication for single host, multi GPU
- If you have multiple GPUs on the same host, you can use CUDA's peer-to-peer (P2P) communication to allow the GPUs to communicate directly with each other without going through the CPU
- This can improve performance because it allows the GPUs to communicate directly with each other without going through the CPU
- We are issuing CUDA calls to a single GPU
- P2P mem copy
```C
cudaMemcpyPeer(void *dest_addr, int dst_device,
                void *src_addr, int src_device,
                size_t count, cudaStream_t stream);
```
- Copies data between two devices without going through the host
- Currently data is "pushed" from source test GPU's DMA engine carries ou thte copy
- There is also blocking (as opposed to Async) version 
If peer-access is enabled
- Bytes are transferred along shortest PCIe path
- No staging through CPU memory


- we need to enable P2P access between the GPUs using the `cudaDeviceEnablePeerAccess` function, and then we can use the `cudaMemcpyPeer` function to copy data between the GPUs without going through the host
- We need to enable peer access because we don't want GPUs to transfer data,
   - If it is enabled, a hacker on a GPU server can access the memory of another GPU, which can lead to security vulnerabilities
   - If it is not enabled, then the GPUs will have to transfer data through the host, which can lead to a performance bottleneck
   - Less likely to have malicious code on the GPU and have it access memory from another GPU
  
How does P2P memcopy help multi-GPU applications?
- Ease of Programming: It allows developers to write code that can easily transfer data between GPUs without having to worry about the underlying communication details
- Performance: It can improve performance by allowing GPUs to communicate directly with each other without going through
- INcrease throughput: Especially when GPUs are connected to a PCIe switch, which can provide high bandwidth and low latency communication between the GPUs
- SIngle directional transfer can achieve up to 6.6Gb/s (12 GB/s gen 3), which is much faster than transferring data through the host
- Bidirectional transfer can achieve up to 22 GB/s for gen3, which is much faster than transferring
  - Meanwhile 5 GB/s if going through host

Example: 1D Domain Decomposition and P2P
- Each subdomain has at most two neighbors
  - "Left" and "Right" neighbors
  - Communication graph = path 

We would have 4 GPUs, GP0 and GP1 are connected through a PCIe switch, and GP2 and GP3 are connected through another PCIe switch, and then the two PCIe switches are connected to each other through a PCIe bridge (Tree like topology)
- This architecture explains to "left" and "right" neighbors, because GP0 and GP1 are connected to each other, and GP2 and GP3 are connected to each other, but GP0 and GP2 are not directly connected to each other, so they are not neighbors
- For GP2 to talk to GP1, it would have to go through the GP2-GP2 birdge and enter the GP0-GP1 switch to talk to GP1, which can lead to a performance bottleneck because it has to go through multiple hops to communicate between the GPUs

Code for Left-Right Approach
Below unfinished
```C
for (int i= 0; i < num_gpus; ++i){
  cudaMemcpyPeerAsync(d_a[i+1], left_neighbor_gpu_id[i], d_a[i], local_gpu_id,
                      buffer_size, stream[i]);
}
```

#pagebreak()
== Host (CPU) NUMA and CPU/GPU Transfers
- NUMA = Non-Uniform Memory Access
- CPU NUMA affects PCIe transfer throughput in dual-IOH systems
  - Transfer to "remote" GPUs achieve lower throughput than transfer to "local" GPUs
- NUMA-aware GPU selection can improve performance by selecting the GPU that is local to the CPU, which can provide higher throughput for CPU-GPU transfers
- With servers with multiple GPUs and multiple CPUs, it is important to be aware of the NUMA architecture of the system and to select the GPU that is local to the CPU to improve performance for CPU-GPU transfers
- "Local" D2D copy: 6.3 GB/s (D2H and H2D for 5.7GB/s)
- "Remote" D2H Copy: 4.3 GB/s (D2H and 4.9 GB/s for H2D)
=== There are three different routes for GPUs to talk to each other 
- Local GPU to local GPU: This is the fastest route because it allows the GPUs to communicate directly with each other without going through the host
- Local GPU to remote GPU: This is slower than local GPU to local GPU because it has to go through the host to communicate between the GPUs
- Remote GPU to remote GPU: This is the slowest route because it has to go through the host to communicate between the GPUs, and it also has to go through the PCIe bridge to communicate between the GPUs, which can lead to a performance bottleneck
```C
// Local GPU to local GPU
cudaMemcpyPeerAsync(d_a[i+1], left_neighbor_gpu_id[i], d_a[i], local_gpu_id,
                      buffer_size, stream[i]);
// Local GPU to remote GPU
cudaMemcpyPeerAsync(d_a[i+1], right_neighbor_gpu_id[i], d_a[i], local_gpu_id,
                      buffer_size, stream[i]);
// Remote GPU to remote GPU
cudaMemcpyPeerAsync(d_a[i+1], right_neighbor_gpu_id[i], d_a[i], local_gpu_id,
                      buffer_size, stream[i]);
```
- Via PCI Switch (This is local GPU to local GPU communication, which is the fastest route)
- Via IOH Chip (This is local GPU to remote GPU communication, which is slower than local GPU to local GPU communication)
  - This route goes through a PCIe bridge of two GPUs
- Via CPU (This is remote GPU to remote GPU communication, which is the slowest route), especially because it is hGPU to hCPU to rCPU to rGPU, which can lead to a performance bottleneck because it has to go through multiple hops to communicate between the GPUs

#pagebreak()
== GPUs become more specialized
- Modern GPU "Processing Units" (PUs) are designed for specific tasks
- Graphics PUs: Optimized for rendering graphics and visual effects
- Compute PUs: Optimized for general-purpose computing tasks, such as scientific simulations and machine learning
- AI PUs: Optimized for artificial intelligence workloads, such as deep learning and neural network inference
- Specialized PUs can provide higher performance for their specific workloads, but they may not be as versatile as general-purpose GPUs, which can lead to trade-offs in performance and flexibility for different workloads
- 32 Threads
- 16 INT 
- 16 Single-Precision FP
- 16 Double-Precision FP
- 16 Tensor Cores (Mixed Precision FP16/FP32)

GPU STreaming Multiprocessor (SM) Architecture
- COntains 4 "Processing Blocks"
- Each independently schedules

GPU Hardware
- V100 has 80 SMs, and each SM has 4 processing blocks, so it has a total of 320 processing blocks
- 5376 FPU
- Peak 15.7 TFLOPS

GPU "Data Center in a box"
*DGX*
- A multi-GPU "Node"
- 300GB/s interconnect between GPUs

GPU

DGX came to be because GPU inter-connect is complex and there are NUMA issues

=== Accelerator topology is Diverse
- GPUs were the first accelerators, but now there are many different types of accelerators, such as FPGAs, TPUs, and ASICs, which are designed for specific workloads and can provide higher performance for those workloads
- Now there are many different types of accelerators and they each have diverse topologies
- Topologies such as Summit (ORNL) for multi-GPU systems, and Cerebras for multi-accelerator systems, which have different interconnects and communication patterns between the accelerators, which can lead to different performance characteristics for different workloads.
  - Each GPU is connect to each other, but communicate to another CPU if it is in another system
- Then a DGX-1 / Big Basin system where every GPU is connected to each other, even passing through CPUs
  - Advanced version of the ORNL

- NVLink: Fast communication between GPUs

NCCL: Accelerated Multi-GPU collective communication library
- Takes care of multi-GPU communication and synchronization for you, which can improve performance and ease of programming for multi-GPU applications