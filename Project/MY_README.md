# **Final Project**

## C++ and CPU profiling 
- Following the instructions, C++ code was written that created 2D square matrices A,B that were then used for the following operations: 
  - A 2D stencil operation was performed on each matrix with radius 3
  - The two matrices were multiplied together 
  - A stencil check and matrix check were written based off of code used in the homework
- To compile: 
```g++ my_script.cc - o my_script
```
- We were also tasked with using the VTune profiler and to identify the computational intensive parts.
  - To install VTune we ran: `source /opt/intel/oneapi/setvars.sh`

## Porting to CUDA using Explicit Memory
- The same process that was required for the CPU profiling was also performed for CUDA programming using explicit memory
  - The stencil operation and matrix multiplication (along with their respective checks) all contained the same characteristic information as used in the CPU profiling code. 
- Recall:
**To set-up your environment:**
```
ssh g38nXX # XX:01-16
export LD_LIBRARY_PATH=/usr/local/cuda/lib
export PATH=$PATH:/usr/local/cuda/bin
```
**To compile:**

```
nvcc my_script.cu -o my_script
```

## CUDA using Managed Memory

## CUDA using Shared Memory



