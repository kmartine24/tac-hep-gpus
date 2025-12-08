#include <stdio.h>
#include <algorithm>
#include <iostream>

using namespace std;

#define N 512
#define RADIUS 3
#define BLOCK_SIZE 32
const int DSIZE = N+2*RADIUS;
const int A_val = 2;
const int B_val = 3; 


// -------- Stencil --------
// Very similar to the homework
__global__ void stencil_2d(int *in, int *out) {

    int gindex_x = threadIdx.x + blockIdx.x * blockDim.x;
    int gindex_y = threadIdx.y + blockIdx.y * blockDim.y;

    // Read input elements into shared memory
    int size = N + 2 * RADIUS;

    __syncthreads();

    // Apply the stencil
    int result = 0;
    for (int offset = -RADIUS; offset <= RADIUS; offset++){
        result += in[size*(gindex_x+offset)+gindex_y];
	result += in[size*gindex_x+gindex_y+offset];
    }

    result -= in[gindex_x*size + gindex_y]; // Shout out to Taylor for helping with this part

    // Store the result
    out[gindex_y+size*gindex_x] = result;
}

// -------- Matrix Multiplication --------
// Similar to HW 3
__global__ void matrix_mul(const float *A, const float *B, float *C, int size) {

    // create thread x index
    // create thread y index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int idy = threadIdx.y + blockIdx.y * blockDim.y;

    // Make sure we are not out of range
    if ((idx < size) && (idy < size)) {
        float temp = 0;
        for (int i = 0; i < size; i++){
            temp += A[idy*size+i] * B[i*size + idx];
	}
        C[idy*size+idx] = temp;
    }
}

// -------- CHECKERS --------
// error checking macro
// This was provided in the homework
#define cudaCheckErrors(msg)                                   \
   do {                                                        \
       cudaError_t __err = cudaGetLastError();                 \
       if (__err != cudaSuccess) {                             \
           fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n",  \
                   msg, cudaGetErrorString(__err),             \
                   __FILE__, __LINE__);                        \
           fprintf(stderr, "*** FAILED - ABORTING\n");         \
           exit(1);                                            \
       }                                                       \
   } while (0)

// %%%%%%%% (A) STENCIL %%%%%%%%
// Notice the stencil_check() function is similar to the one presented in the homework
void stencil_check(const int *in, const int *out, const int val) {
    for (int i = 0; i < N + 2 * RADIUS; ++i) {
        for (int j = 0; j < N + 2 * RADIUS; ++j) {
            if (i < RADIUS || i >= N + RADIUS) {
                if (out[j+i*(N + 2 * RADIUS)] != val) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], 1);
                    return -1;
                }
            }
            else if (j < RADIUS || j >= N + RADIUS) {
                if (out[j+i*(N + 2 * RADIUS)] != val) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], 1);
                    return -1;
                }
            }		 
            else {
                if (out[j+i*(N + 2 * RADIUS)] != val + val * 4 * RADIUS) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], 1 + 4*RADIUS);
                    return -1;
                }
            }
        }
    }
    printf("No Errors found\n");
}

// %%%%%%%% (B) MATRIX %%%%%%%%
// Notice the matmul_check() function is similar to the one presented in the homework
void matmul_check(const int *A, const int *B, const int *C) {
    // Error Checking
    for (int i = 0; i < N + 2 * RADIUS; ++i) {
        for (int j = 0; j < N + 2 * RADIUS; ++j) {
            if (i < RADIUS || i >= N + RADIUS) {
                if (out[j+i*(N + 2 * RADIUS)] != 1) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], 1);
                    return -1;
                }
            }
            else if (j < RADIUS || j >= N + RADIUS) {
                if (out[j+i*(N + 2 * RADIUS)] != 1) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], 1);
                    return -1;
                }
            }		 
            else {
                if (out[j+i*(N + 2 * RADIUS)] != 1 + 4 * RADIUS) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], 1 + 4*RADIUS);
                    return -1;
                }
            }
        }
    }
    printf("No Errors found\n");
}

int main(void) {

    int *h_A, *h_B, *h_C, *h_A_stencil, *h_B_stencil, *d_A, *d_B, *d_C, *d_A_stencil, *d_B_stencil;

    // Alloc space for host copies and setup values
    int size = (N + 2*RADIUS)*(N + 2*RADIUS) * sizeof(int);
    h_A = (int *)malloc(size); fill_ints(h_A, (N + 2*RADIUS)*(N + 2*RADIUS));
    h_B = (int *)malloc(size); fill_ints(h_B, (N + 2*RADIUS)*(N + 2*RADIUS));
    h_B = (int *)malloc(size); fill_ints(h_C, (N + 2*RADIUS)*(N + 2*RADIUS));
    h_A_stencil = (int *)malloc(size); fill_ints(h_A_stencil, (N + 2*RADIUS)*(N + 2*RADIUS));
    h_B_stencil = (int *)malloc(size); fill_ints(h_B_stencil, (N + 2*RADIUS)*(N + 2*RADIUS));

    // Alloc space for device copies
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);
    cudaMalloc((void **)&d_A_stencil, size);
    cudaMalloc((void **)&d_B_stencil, size);

    // Copy to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_A_stencil, h_A_stencil, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B_stencil, h_B_stencil, size, cudaMemcpyHostToDevice);

    cudaCheckErrors("Check for errors when copying to device");

    // Launch stencil_2d() kernel on GPU
    int gridSize = (N + BLOCK_SIZE-1)/BLOCK_SIZE;
    dim3 grid(gridSize, gridSize);
    dim3 block(BLOCK_SIZE, BLOCK_SIZE);

    // Launch the kernel 
    // Properly set memory address for first element on which the stencil will be applied
    stencil_2d<<<grid,block>>>(d_A + RADIUS*(N + 2*RADIUS) + RADIUS , d_B_stencil + RADIUS*(N + 2*RADIUS) + RADIUS);
    stencil_2d<<<grid,block>>>(d_B + RADIUS*(N + 2*RADIUS) + RADIUS , d_B_stencil + RADIUS*(N + 2*RADIUS) + RADIUS);
    cudaCheckErrors("Check for proper stencil function performance");

    // Also perform matrix multiplication
    int gridSize_matmul = (DSIZE + BLOCK_SIZE-1)/BLOCK_SIZE;
    dim3 grid_matmul(gridSize_matmul, gridSize_matmul);
    dim3 block_matmul(BLOCK_SIZE, BLOCK_SIZE);
    matrix_mul<<<grid_matmul,block_matmul>>>(d_A_stencil, d_B_stencil, d_C, DSIZE);
    cudaCheckErrors("Check for proper matrix multiplication");

    // Copy result back to host
    cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_B, d_B, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_A_stencil, d_A_stencil, size, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_B_stencil, d_B_stencil, size, cudaMemcpyDeviceToHost);

    // Error Checking

    // Cleanup
    free(h_A);
    free(h_B);
    free(h_C);
    free(h_A_stencil);
    free(h_B_stencil);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    cudaFree(d_A_stencil);
    cudaFree(d_B_stencil);
    printf("Success!\n");

    return 0;




}


