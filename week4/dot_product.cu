#include <stdio.h>
#include <time.h>
#include <iostream>

#define BLOCK_SIZE 32

const int DSIZE = 256;
const int a = 1;
const int b = 1;

// error checking macro
#define cudaCheckErrors()                                       \
	do {                                                        \
		cudaError_t __err = cudaGetLastError();                 \
		if (__err != cudaSuccess) {                             \
			fprintf(stderr, "Error:  %s at %s:%d \n",           \
			cudaGetErrorString(__err),__FILE__, __LINE__);      \
			fprintf(stderr, "*** FAILED - ABORTING***\n");      \
			exit(1);                                            \
		}                                                       \
	} while (0)


// CUDA kernel that runs on the GPU
__global__ void dot_product(const int *A, const int *B, int *C, int N) {

    // FIXME
    // Use atomicAdd	
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N) {
        float product = A[idx]*B[idx];
	atomicAdd(C, product);
    }
}


int main() {
	
    // Create the device and host pointers
    int *h_A, *h_B, *h_C, *d_A, *d_B, *d_C;

    // Fill in the host pointers 
    h_A = new int[DSIZE];
    h_B = new int[DSIZE];
    h_C = new int;
    for (int i = 0; i < DSIZE; i++){
        h_A[i] = a;
        h_B[i] = b;
    }

    *h_C = 0;

    std::cout << "******** Initial Matrix Values ********" << std::endl;
    std::cout << "h_A = ";
    for (int i = 0; i < 5; ++i) {
        std::cout << h_A[i] << " ";
    }
    std::cout << ", ... " << std::endl;
    std::cout << "h_B = ";
    for (int i = 0; i < 5; ++i) {
        std::cout << h_B[i] << " ";
    }
    std::cout << ", ... " << std::endl;
    std::cout << "h_C = " << *h_C << std::endl;

    // Allocate device memoryy
    cudaMalloc(&d_A, DSIZE*sizeof(float));
    cudaMalloc(&d_B, DSIZE*sizeof(float));
    cudaMalloc(&d_C, DSIZE*sizeof(float));

    // Check memory allocation for errors
    // std::cout << "Checking Memory Allocation" << std::endl;
    cudaCheckErrors();

    // Copy the matrices on GPU
    cudaMemcpy(d_A, h_A, DSIZE*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, DSIZE*sizeof(float), cudaMemcpyHostToDevice);
	
    // Check memory copy for errors
    // std::cout << "Checking Memory Copy from Host to Device" << std::endl;
    cudaCheckErrors();

    // Define block/grid dimentions and launch kernel
    const int block_size = 32;
    const int grid_size = DSIZE/block_size;
    dot_product<<<grid_size, block_size>>>(d_A, d_B, d_C, DSIZE);
	
    // Copy results back to host
    cudaMemcpy(h_C, d_C, DSIZE*sizeof(float), cudaMemcpyDeviceToHost);
	
    // Check copy for errors
    // std::cout << "Checking Memory Copy from Device to Host" << std::endl;
    cudaCheckErrors();

    // Verify result
    std::cout << "******** Verifying Results ********" << std::endl;
    std::cout << "h_A = ";
    for (int i = 0; i < 5; ++i) {
        std::cout << h_A[i] << " ";
    }   
    std::cout << ", ... " << std::endl;
    std::cout << "h_B = ";
    for (int i = 0; i < 5; ++i) {
        std::cout << h_B[i] << " ";
    }   
    std::cout << ", ... " << std::endl;
    std::cout << "h_C = " << *h_C << std::endl;
  
    // Free allocated memory
    free(h_A);
    free(h_B);
    free(h_C);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;

}
