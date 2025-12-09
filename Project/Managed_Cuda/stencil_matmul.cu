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
__global__ void matrix_mul(const int *A, const int *B, int *C, int size) {

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
// Notice the stencil_check() function is similar to the one presented in HW 4
void stencil_check(const int *in, const int *out, const int val) {
    for (int i = 0; i < N + 2 * RADIUS; ++i) {
        for (int j = 0; j < N + 2 * RADIUS; ++j) {
            if (i < RADIUS || i >= N + RADIUS) {
                if (out[j+i*(N + 2 * RADIUS)] != val) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], val);
                }
            }
            else if (j < RADIUS || j >= N + RADIUS) {
                if (out[j+i*(N + 2 * RADIUS)] != val) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], val);
                }
            }		 
            else {
                if (out[j+i*(N + 2 * RADIUS)] != val + val * 4 * RADIUS) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, out[j+i*(N + 2 * RADIUS)], val + val*4*RADIUS);
                }
            }
        }
    }
    printf("No Errors found\n");
}

// %%%%%%%% (B) MATRIX %%%%%%%%
// Notice the matmul_check() function is similar to the stencil checker
void matmul_check(const int *A, const int *B, const int *C) {
    int Aval_stencil = A_val + A_val*4*RADIUS;
    int Bval_stencil = B_val + B_val*4*RADIUS;
    int avg_DSIZE = DSIZE - 2*RADIUS;
    for (int i = 0; i < N + 2 * RADIUS; ++i) {
        for (int j = 0; j < N + 2 * RADIUS; ++j) {
            if ((i < RADIUS || i >= N + RADIUS) && (j < RADIUS || j >= N + RADIUS)) {
                if (C[j+i*(N + 2 * RADIUS)] != A_val*B_val*DSIZE) {
                    printf("(A) Matrix Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[j+i*(N + 2 * RADIUS)], A_val*B_val*DSIZE);
                }
            }
            else if ((i < RADIUS || i >= N + RADIUS) && (j >= RADIUS && j < RADIUS + N)) {
                if (C[j+i*(N + 2 * RADIUS)] != A_val*B_val*2*RADIUS + A_val*Bval_stencil*avg_DSIZE) {
                    printf("(B) Matrix Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[j+i*(N + 2 * RADIUS)], A_val*B_val*2*RADIUS + A_val*Bval_stencil*avg_DSIZE);
                }
            }		 
            else if ((i >= RADIUS || i < N + RADIUS) && (j >= RADIUS && j < RADIUS + N)) {
                if (C[j+i*(N + 2 * RADIUS)] != A_val*B_val*2*RADIUS + Aval_stencil*Bval_stencil*avg_DSIZE) {
                    printf("(C) Matrix Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[j+i*(N + 2 * RADIUS)], A_val*B_val*2*RADIUS + Aval_stencil*Bval_stencil*avg_DSIZE);
                }
            }		 
	    else {
                if (C[j+i*(N + 2 * RADIUS)] != A_val*B_val*2*RADIUS + Aval_stencil*B_val*avg_DSIZE) {
                    printf("(D) Matrix Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[j+i*(N + 2 * RADIUS)], A_val*B_val*2*RADIUS + Aval_stencil*B_val*avg_DSIZE);
                }
            }
        }
    }
    printf("No Errors found\n");
}

// To Fix an error:
void fill_ints(int *x, int n, int val) {
    fill_n(x, n, val);
}

int main(void) {

    int *h_A, *h_B, *h_C, *h_A_stencil, *h_B_stencil;

    // Alloc space for host copies and setup values
    int size = (N + 2*RADIUS)*(N + 2*RADIUS) * sizeof(int);

    // Alloc space for device copies
    cudaMallocManaged((void **)&h_A, size);
    cudaMallocManaged((void **)&h_B, size);
    cudaMallocManaged((void **)&h_C, size);
    cudaMallocManaged((void **)&h_A_stencil, size);
    cudaMallocManaged((void **)&h_B_stencil, size);

    cudaCheckErrors("Check for errors when allocating space");

    fill_ints(h_A, (N+2*RADIUS)*(N+2*RADIUS), A_val);
    fill_ints(h_B, (N+2*RADIUS)*(N+2*RADIUS), B_val);
    fill_ints(h_C, (N+2*RADIUS)*(N+2*RADIUS), 0);
    fill_ints(h_A_stencil, (N+2*RADIUS)*(N+2*RADIUS), A_val);
    fill_ints(h_B_stencil, (N+2*RADIUS)*(N+2*RADIUS), B_val);

    // Launch stencil_2d() kernel on GPU
    int gridSize = (N + BLOCK_SIZE-1)/BLOCK_SIZE;
    dim3 grid(gridSize, gridSize);
    dim3 block(BLOCK_SIZE, BLOCK_SIZE);

    // Launch the kernel 
    // Properly set memory address for first element on which the stencil will be applied
    stencil_2d<<<grid,block>>>(h_A + RADIUS*(N + 2*RADIUS) + RADIUS , h_A_stencil + RADIUS*(N + 2*RADIUS) + RADIUS);
    stencil_2d<<<grid,block>>>(h_B + RADIUS*(N + 2*RADIUS) + RADIUS , h_B_stencil + RADIUS*(N + 2*RADIUS) + RADIUS);
    cudaCheckErrors("Check for proper stencil function performance");

    // Also perform matrix multiplication
    int gridSize_matmul = (DSIZE + BLOCK_SIZE-1)/BLOCK_SIZE;
    dim3 grid_matmul(gridSize_matmul, gridSize_matmul);
    dim3 block_matmul(BLOCK_SIZE, BLOCK_SIZE);
    matrix_mul<<<grid_matmul,block_matmul>>>(h_A_stencil, h_B_stencil, h_C, DSIZE);
    cudaCheckErrors("Check for proper matrix multiplication");

    // Sync
    cudaDeviceSynchronize();

    // Error Checking
    stencil_check(h_A, h_A_stencil, A_val);
    stencil_check(h_B, h_B_stencil, B_val);
    matmul_check(h_A_stencil, h_B_stencil, h_C);

    // Cleanup
    cudaFree(h_A);
    cudaFree(h_B);
    cudaFree(h_C);
    cudaFree(h_A_stencil);
    cudaFree(h_B_stencil);
    printf("Success!\n");

    return 0;




}


