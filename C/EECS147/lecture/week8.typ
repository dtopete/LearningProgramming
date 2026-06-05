= Tuesday Lecture week 8 

== Some annoucements
- We are almost done with all course content, next lecture last lecture

- Next Frday is the deadline for Histogram assignment

- So work up on the final project

= Picking up where last lecture left off
- The previus lecture was about multi GPU and the complexity of having all of them interconnected and working together
- Left off talking about NCCL and how it helps with communication between GPUs and connecting everything together

= Background on NCCL
- Standard library for communication between GPUs, developed by NVIDIA
- Provides high performance communication primitives for multi-GPU and multi-node systems
- Supports various communication patterns like all-reduce, broadcast, reduce, and more
- Optimized for NVIDIA GPUs and can take advantage of NVLink and PCIe for fast communication
- Can be used in various frameworks like PyTorch, TensorFlow, and more
- Provides a simple API for developers to use in their applications
- Helps to abstract away the complexities of multi-GPU communication and allows developers to focus on their application logic
Efficiency of Parallel computation task
- Amount of exposed parallelism
- AMount of work assigned to each processor
Expensive of communication among tasks

== Communication patterns among tasks
- There is typically a sender and a receiver when it comes to typical GPU tasks
Point to point communication
- Singler sender, single receiver
- Relatively easy to implement efficiently

Collective communication
- Multiple senders and/or receivers

PTP Comm
- most common pattern in HPC is where communication is usually to the nearest neighbor

Collective Communication
- If you have broadcast, you have one sender and multiple receivers

Scatter
- One sender and multuple receivers, but each receiver gets a different partition of the data


#pagebreak()
== In depth in these communication patterns
=== Broadcast
Every receiver has the same copy of data from the single receiver

=== Scatter
- One sender
- Packets A,B,C,D go to receiver 1,2,3,4 respectively
- Each packet is different so they all receiver partitions of different data

=== Gather
- Multiple senders, one receiver
- Each sender has different data packets but receiver gets all data packets

== All-Gather
- Multiple senders, multiple receivers
- Every GPU has a different data packets, but they share it with each other, making all GPUs have the same data packets.
=== Reduce
- Multiple senders, one receiver
- We have multiple senders, all with different data packets, but the receiver gets the reduced value of all the data packets, for example, the sum of all the data packets

== All-Reduce
- Multiple senders, multple receivers,
- All GPUs have different data packets, but they all end up with the same reduced value of all the data packets, for example, the sum of all the data packets in every GPU

== Reduce Scatter
- Each GPU has different data packets, A0, A1, A2, A3 and each for GPU A,B,C,D
- Then GPU receives the reduction of A0, B0, C0, D0 and GPU B receives the reduction of A1, B1, C1, D1 and so on for GPU C and D

== All to All
- Multiple senders, multiple receivers
- Each GPU has different data packets, GP0 has A0, A1, A2, A3 and each for GPU A,B,C,D
- Then GPU receives all the 0 packets or all the 1 packets

#pagebreak()
= Challenges of Collectives
Having multiple senderes and/or receivers compounds communication inefficiencies
- For small transfers, latency dominates; more participants means more latency
- Larger transfers bandwidth is key; bottlenecks are easily exposed with more participants

Challenges of Collectives
- It is expensive, but they are necessary for many algorithms, especially in deep learning where we need to synchronize gradients across GPUs
- Depp Learning (all-reduce, broadcast, gather)
- Parallel FFT (All-Reduce)
- Molecular Dynamics (All-Reduce)
- Graph ANN (All-Reduce)

Challenge of Collectives
- Scaling requires efficient communication algorithms and careful implementations
- Communication algorithns are topology-dependent
- Topologies can be complex and dynamic, especially in multi-node systems

#pagebreak()
= Ring-Base Collectives: A Primer
== Broadcast
with Unidirectional Ring
- We are splitting the data where GPU0 has all the data, then it sends the first packet to GPU1, then GPU1 sends it to GPU2 and so on until all GPUs have the data
- This is efficient like a pipeline where one of the GPUs is always receiving and sending data, so we can achieve good bandwidth utilization
- Latency is O(N) where N is the number of GPUs, but bandwidth is good
- Total time is $$SN / (SB) + (k- 2) N/(SB) = N(S+K-2)/(SB) $$ $arrow$ N/B 

== All-Reduce
With unidirectional ring

+ Doing this chunk by chunk, (because this is the most efficient pattern for large data). GP0[0] $arrow$ GP1[1] $arrow$ GP2[2] $arrow$ GP3[3] $arrow$ GP0 and so on until all GPUs have the reduced value of all the data packets
+ Now that we have each block, we send a new block, and apply reduction with the received block, and send it to the next GPU, and so on until we have the reduced value of all the data packets in each GPU
+ Latency is O(N) and bandwidth is good, total time is $$2N(S+K-2)/(SB)$$ $arrow$ 2N/B
- Eventually we don't need to perform reductions because we have reduced the value from all the chunks from each GPU.
- We keep going on until we have achieved every buffer of memory.
  - Every buffer of memory is N chunks, with N being the number of GPUs, and each chunk is S/N, with S being the total size of the data. So we have N chunks of size S/N, and we have N GPUs, so we have N chunks of size S/N in each GPU, and we need to perform reductions on all of them until we have the reduced value of all the data packets in each GPU.

Ring-Based Collectives (A primer)
- We are using a unidirectional ring
- This helps with transfering data in a pipeline fashion where the GPU sends and receives data at the same time from the neighboring GPU, so we can achieve good bandwidth utilization
- We are restricting ourselves to sending data in a single direction without needing any contention of bandwidth
- There is always data flowing in every GPU, sending and receiving

#pagebreak()
= Introducing NCCL
- The goal of NCCL is the provide an accelerating multi-GPU collective communication library that is optimized for NVIDIA GPUs and can take advantage of NVLink and PCIe for fast communication
- *Goal* Build a research library of accelerated collectives that is easily integrated and topology aware so that to improve scalability and performance of multi-GPU applications
Collectives
- Broadcast
- All-Gather
- Reduce
- All-Reduce
- Reduce-Scatter
(Below are not implemented in NCCL but are common collectives in general)
- Scatter
- Gather
- All-to-All
- Neighborhood

Key Features of NCCL
- Single-Node, up to 8 GPUs
- Host-side API
- Asynchronous / non-blocking interface
- Multi-threaded, multi-process support
- In-place and out-of-place operations
(Below not implemented in NCCL but are common features in general)
- Integration with MPI
- Topology Detection
- NVLink and PCIe / QPI\* support (althoguh PCIe/ QPI support is available in NCCL)

== NCCL Implementation
Implemented as monolithic CUDA C++ Kernels combining the following:
- GPUDirect P2P Direct Access
- Three primitive operations: Copy, Reduce, ReduceAndCopy
- Intra-Kernel synchroniztion between GPUs
- One CUDA thread block per ring-direction
sam
== NCCL Performance
- Broadcast gets to that max memcpy of 10.4 GB/s using NCCL
- Then All-reduce gets close to it at 9.6
- Allgather at 9.5
- Then all-reduce at 9.2

#pagebreak()
= Thursday Lecture
= MPS
== What is MPS
- MPS stands for Multi-Process Service, it is a feature of NVIDIA GPUs that allows multiple processes to share a single GPU context, which can improve the performance of multi-GPU applications by
- Allows for various CPUs and GPUs to share the same GPU context, which can improve performance by reducing the overhead of context switching and allowing for better utilization of the GPU resources 
- CUDA feature that allows various CUDA processors to share the same GPU context
  - A GPU context can be compared to a CPU Process
  - All the context that is accessible by the current process is called the GPU context, and it contains all the resources that are allocated for that process, such as memory, streams, events, and so on
- This is useful for HPC and cloud scenarios where they have multiple users sharing the same GPU resources 
- Allows of overlapping of kernel nad memcopy operations from different processes on the GPU to achieve maximum utilization
- Sure, we can do this manually, but on a server, there is naturally various requests that will be done on the same GPU resources
- Hyper-Q allows for multiple CPU threads to launch work on the same GPU context, but MPS allows for multiple CPU processes to share the same GPU context, which is more efficient and can improve performance by reducing the overhead of context switching and allowing for better utilization of the GPU resources
== Requirements
- Supported on Linux
- Unified virtual addressing
- Tesla with compute capability 3.5 or higher
- Exclusive-mode restrictions are applied to the MPS servers, not MPS clients
  - MPS works in a server model, where it receives requests from clients, and it manages the GPU resources and schedules the work on the GPU, so the exclusive-mode restrictions are applied to the MPS servers, not MPS clients, which means that the MPS server can be running in exclusive mode, but the MPS clients can still access the GPU resources without any restrictions
  - Each new process gets processed as an MPS client
- Without MPS, we would be placed in a queue and wait for the GPU to be available, but with MPS, we can share the GPU resources and achieve better performance by overlapping the work from different processes on the GPU

#pagebreak()
== Arch changes to allows MPS
- GPUs now can run multuple, independent kernels
  - Fermi and later
- Kernels must be launched into different CUDA streams
  - Hyper-Q allows for up to 32 concurrent hardware work queues, so we can have up to 32 concurrent kernels running on the GPU, which allows for better utilization of the GPU resources and can improve performance by reducing the overhead of context switching and allowing for better utilization of the GPU resources

Given that these various streams are running concurrently
- Allows for 32 way concurrency
- Up the 32 streams, launched on the GPU, concurrently, each stream has its own work queue, so we can have up to 32 concurrent kernels running on the GPU, which allows for better utilization of the GPU resources and can improve performance by reducing the overhead of context switching and allowing for better utilization of the GPU resources

Concurrency under MPS
- One work queue per stream, 2 work queues per MPS client
- The limit under Kepler is still 32 concurrent kernels

Serialization/False dependency under MPS
- What if there are more than 32 concurrent kernels?
- Streams wil be serialized, as they can't be ran concurrently
- This is a false dependency, as there is no real dependency between the kernels, but they will be serialized because of the limit of 32 concurrent kernels, so we need to be careful when using MPS to avoid this false dependency and achieve better performance by overlapping the work from different processes on the GPU

Hyper-Q / MPI (MPS): Single/Multi GPUs per Node
- We have various processes running, we label them rank (common label for HPC)
- The MPS server is between every MPI rank and the GPU, so it manages the GPU resources and schedules the work on the GPU, so we can have multiple MPI ranks sharing the same GPU resources and achieve better performance by overlapping the work from different processes on the GPU

== How the MPS server works
- The MPS server is a daemon process that runs on the GPU and manages the GPU resources

Using MPS on a single GPU
- Application modification is not necessary
- Proxy process between user processes and GPU
- Spawn MPS server upon CUDA application startup, and shutdown when the application exits

Settings
- `export CUDA_VISIBLE_DEVICES=0` to set an environment variable about the GPU0
- `nvidia-smi -i 0 -c EXCLUSIVE_PROCESS` to set the exclusive mode for the GPU, which is required for MPS to work
- `nvidia-cuda-mps-control -d` to start the MPS server in daemon mode, which will run in the background and manage the GPU resources

Using MPS on multiple GPUs
+ Set GPU in exclusive mode
  - `sudo nvidia-smi -c 3 -i 0,1` to set the exclusive mode for GPU0 and GPU1, which is required for MPS to work
+ Start MPS server on each GPU
  - `CUDA_VISIBLE_DEVICES=0 nvidia-cuda-mps-control -d`
  - `CUDA_VISIBLE_DEVICES=1 nvidia-cuda-mps-control -d` to start the MPS server on GPU0 and GPU1, which will run in the background and manage the GPU resources for each GPU
  Below not required after CUDA 7.0
  - Then pipe directory
  - Log directory

  Below still required
  - `nvidia-cuda-mps-control -d`
+ Run application with MPS

In nvidia-smi
- Each GPU is viewed as a nvidia-cuda-mps-server process

MPS Profiling with NVPROF
- Without MPS, each process is serialized, there's no concurrency between two processes
- Meanwhile with MPS, there are some overlapping kernels

Stopped at Slide 24

#pagebreak()
= Dynamic Parallelism
- The ability to launch new kernel grids from the GPU itself
- The typical way a kernel is launched, it goes from CPU to GPU
  - With dynamic parallelism, a GPU kernel can launch kernel on the GPU itself, it can create work for itself
GPU is typically seen as a co-processor, this is CPU -> GPU
- With autonomous, dynamic parallelism, we can have GPUs launch child kernels, and keep working until the work is done and send data back to the CPU 
Simplest Parallel program

Serial Program
```C
for i = 1 to N
  for j = 1 to x[i]
    convolution(i, j)
  next j
next i
```
Here we find the maximun size of x[i], then we launch a kernel with N blocks and max(x[i]) threads per block, then each thread will check if it is within the bounds of x[i], if it is, it will perform the convolution, otherwise it will do nothing, this way we can achieve parallelism across both dimensions of the loop and improve performance by utilizing the GPU resources more effectively

CUDA Program
```C
__global__ void convolution_kernel(int N, int *x) {
  for j = 1 to x[blockIdx.x]
    kernel<<<...>>>(blockIdx.x, j)
}

convolution<<< N, 1>>>(x);
```

This is useful when you have regions of interest
- Lets say you need finer blocks in regions of interest (smaller blocks) and coarser blocks elsewhere
- Dynamic sized grids to match the workload

#pagebreak()
Familiar Syntax
- We are doing a kernel launch from the GPU kernel
- INstead of calling kernel from `void main()`, we are calling them from `__global__ void B(float *data)`

We can call a kernel launch per thread
```C
__device__ float buf[1024];
__global__ void A() {
  int tid = threadIdx.x;
  if ( tid % 2){
    buf[tid] = ...; // compute some value
  }
  __syncthreads(); // synchronize all threads in the block

  // Thread 0 launches a new kernel
  if (tid == 0) {
    B<<< 128, 256 >>>(buf); // launch a new kernel from the GPU
    cudaDeviceSynchronize(); // wait for the child kernel to finish
  }
  __syncthreads(); // synchronize all threads in the current block

  cudaMemcpyAsync(data, buf, 1024);
  cudaDeviceSynchronize(); // wait for the memcpy to finish
}
```

Execution Model
- Each block runs CUDA independently
- All launches nad copies are asynchronous, so we need to synchronize them manually using `cudaDeviceSynchronize()`
- Constants set from host
- textures/surface data can only be modified from host
- ECC errors reported at host

Basic Rules
- Launch is per-thread
- Sync is per-block
- CUDA primitives