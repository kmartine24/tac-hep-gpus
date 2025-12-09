# **Final Project**

## C++ and CPU profiling 
- Following the instructions, C++ code was written that created 2D square matrices A,B that were then used for the following operations: 
  - A 2D stencil operation was performed on each matrix with radius 3
  - The two matrices were multiplied together 
  - A stencil check and matrix check were written based off of code used in the homework
- To compile and execute: 
```
g++ mult_stencil.cc -o mult_stencil
./mult_stencil
```
- We were also tasked with using the VTune profiler and to identify the computational intensive parts.
  - To install VTune we ran: `source /opt/intel/oneapi/setvars.sh`
  - Following the commands on VTune Documentation, the following commands were used after slight modification: 
    - `vtune -collect hotspots -quiet ./mult_stencil`
    - `vtune -report summary -format csv -report-output summary.csv`
    - `vtune -report hotspots -format csv -report-output hotspots.csv`
  - For reference, the matrix multiplication function took the most computation time compared to the stencil function (0.52 vs 0.02 respectively)

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
- This is very similar to the previous CUDA code written
  - The only differences occur in `main` where the type of memory usage is determined 
- We want to use `nsys` to compare the different CUDA methods 
  - We had to use the following commands to export the necessary information: 
```
nsys profile --stats=true ./stencil_matmul
nsys stats report1.nsys-rep > base_cuda.txt --force-export=true
```
  - For the managed memory method: 
    - For 98.3% of the time, `cudaMalloc` was running 
    - 77.3% of the GPU time was spent on the matrix multiplication function compared to 22.3% of the time spent on the stencil function
## CUDA using Shared Memory



