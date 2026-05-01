Week5 Thursday April 30th

= Unified Memory
Reduce Developer Effect
- Unified Memory (UM) is a single memory address space accessible from any processor in a system.
- Has been available since CUDA 6.0, but only for Kepler and later GPUs.
- CUDA 8+ for Pascal and later GPUs has improved UM performance, making it more viable for general use.
-- Can allocate beyond GPU memory limits, with the system automatically managing data movement between CPU and GPU.

-- Lets you page in and page out data as needed, which can simplify programming and reduce the need for explicit data management.

-- Page out old data to make room for new data, which can help manage memory more efficiently.

Simplified Memory Management
```C
void sortfile(FILE *fp, int N){
  char *data;
  data = (char*)malloc(N*sizeof(char));
  fread(data, sizeof(char), N, fp);
  qsort(data, N, sizeof(char), compare);
  use_data(data);
  free(data);
}

```

CUDA Code with Unified Memory
```C
void sortfile(FILE *fp, int N){
  char *data;
  data = (char*)malloc(N*sizeof(char));
  fread(data, sizeof(char), N, fp);
  qsort(data, N, sizeof(char), compare);
  use_data(data);
  free(data);
}

```

CUDA Code with Unified Memory
```C
void sortfile(FILE *fp, int N){
  char *data;
  cudaMallocManaged(&data, N*sizeof(char));

  fread(data, sizeof(char), N, fp);

  qsort<<...>>>(data, N, sizeof(char), compare);
  cudaDeviceSynchronize(); // Ensure GPU has finished processing before using data

  use_data(data);

  cudaFree(data);
}
```

#pagebreak()
== How does unified memory work?
- Lets say we have two devices
- Each have their page tables that maps to physical memory
- We can view that we have page1 in device A's page table, and page2 in device B's page table
- If we want page 3 (located in B's page table) from device A, we can request it from B.
A pages in the memory from B, and then A can access it as if it were local memory. This is done through a process called "page migration," where the requested page is moved from one device's memory to another's.

- The unified memory model allows for oversubscribing
-- Allows you to make a data structure larger than the GPU memory and even up to the address space of the GPU. Can put 64GB of data on a GPU with only 16GB of memory, and the system will manage the data movement for you.

== How are we allowing oversubscription?
- Page tables will move between devices, and the system will manage the movement of data between CPU and GPU memory as needed. When a page is accessed that is not currently in the GPU memory, it will be paged in from the CPU memory, and when a page is no longer needed, it can be paged out to make room for new data.
- If the GPU evicts a page, it will be writen to CPU memory, and if the GPU needs a page that is not currently in its memory, it will be paged in from CPU memory. This allows for efficient memory management and enables the use of larger data sets than what can fit in GPU memory alone.

== Before CUDA 8
- No need to synchronize after calling the kernel because the data was already in GPU memory, so the kernel could access it directly without any additional overhead. However, with unified memory, the data may not be in GPU memory when the kernel is called, so we need to synchronize to ensure that the data is available for the kernel to access.
- No need to call cudaSynchronize()

#pagebreak()
== Performance tuning on Pascal+
- Advise runtime on expeted memory access behaviors with:
`cudaMemAdvise(ptr, count, hint, device);`
- Hints include:
-- `cudaMemAdviseSetReadMostly`: Indicates that the memory will be read mostly,

-- `cudaMemAdviseSetPreferredLocation`: Indicates the preferred location for the memory (CPU or GPU),

-- `cudaMemAdviseSetAccessedBy`: Indicates that the memory will be accessed by

Hints don't trigger data movement by themselves


*Hints: cudaMemAdviseSetPrefferedLocation*
- Suggest which processor is the best location for data
- Does not automatically cause migration
- Data will be migrated to preferred processor on-demand (or pre-fetched)
- If possible, data (P2P) mapping will be provided when other processors touch it
- If mapping is not possibe, data will be migrated

*Hints: cudaMemAdviseSetAccessedBy*
- Does not cause movement or affect location of data
- Indicated processor 

= Enabling Multi-GPU Support
- Working with Multiple GPU, there becomes a single unified system memory.
- There is SYSMEM, and each GPU automatically gets a partition of that memory, and the system manages the movement of data between the GPUs and the CPU as needed.


= Performance Final Words
- Unified memory gives you a great abstraction for memory management
- UM grants ease of programming and programmer productivity
- 