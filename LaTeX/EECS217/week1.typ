#set align(center)
= CS/EE 217 - GPU Architecture and Parallel Programming

#set align(left)
- Maybe later in the lecture, may cover AI (just mat mult)
- Then a TPU is just a mat mult processor

== General architecture
- Usually follows a SIMT, single instruction multiple threads

GPGPU Programming
- lots of microarchitecture and design challenges
- High performance
- Functionality and maintainability, understanding how code runs between microarchitectures, different generations of GPUs

Technical Subjects
- Principles and patterns of parallel algorithms
- Processor arch features and constraints
- Programming API, tools and techniques


== Grade Breakdown
- Assignments 35%
- 2 midterms, testing center 25%
- FInal exam is early, 20%
- Project: 20%

== Assignment policies
- 3 slip days (regular assignments)
- 15% penalty per late day
- No extensions
- All assignments/projects due at the end of the due date

== Architecture Advancements
- Single-core CPU
- Multi-core CPU
- GPU
- FPGA
- ASIC

As we progress, we are getting even more application specific areas. Less general purpose and progressively harder to program. Can't be more efficient than an ASIC design.

As we progress, we get more energy efficient and specialized along with harder to program.

GPUs are great for anything that can be accelerated in parallel

#pagebreak()
= Architecture Overview 
- High level overview on necessary concepts
- We are on the SW and a little of the HW stack for this course.
- From processor/memory/IO (HW)
- To SW (Application, OS, libs, assembly/machine code), then general programming C/C++
- Within a process, a multithreaded process, each thread has it's own registers and stack
  - Each process has it's own code, data, files
- With GPUs, each thread has it's own thread. They are usually in a set of 32 (size of a warp). This is part of the SIMT programming model
- We have an ISA (Instruction Set Architecture), op, rs, rt, rd, shamt, funct. Each one has an amount of bits within each binary instruction

For 203 level content, Out-of-order pipeline
- There's something along the lines of having stacks and buffers. If an instruction is ready, we end up moving it to where it should be
- We have a warp in a GPU, so we have 32 instructions being handled at a time
- Context switching happens between warps

An SM/CU, (forgot what that is)

CUDA cores just goes to computing units, not actual cores

Using virtual memory is essential to have an illusion of infinite memory. Every process has it's own address space. Alluding slowly into memory coalescing
- You need to implement page tables to have a mapping between virtual addrs to physical addrs
- If it doesn't fit in physical memory, it gets swapped into the disk