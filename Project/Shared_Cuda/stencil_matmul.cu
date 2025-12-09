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

    __shared__ int temp[BLOCK_SIZE + 2 * RADIUS][BLOCK_SIZE + 2 * RADIUS];
    int gindex_x = threadIdx.x + blockIdx.x * blockDim.x;
    int lindex_x = threadIdx.x + RADIUS;
    int gindex_y = threadIdx.y + blockIdx.y * blockDim.y;
    int lindex_y = threadIdx.y + RADIUS;

    // Read input elements into shared memory
    int size = N + 2 * RADIUS;
    temp[lindex_x][lindex_y] = in[gindex_x * size + gindex_y];

    if (threadIdx.x < RADIUS) {
        temp[lindex_x-RADIUS][lindex_y] = in[size*(gindex_x - RADIUS) + gindex_y];
        temp[lindex_x+BLOCK_SIZE][lindex_y] = in[size*(gindex_x + BLOCK_SIZE) + gindex_y];
    }

    if (threadIdx.y < RADIUS ) {
        temp[lindex_x][lindex_y-RADIUS] = in[size*gindex_x + gindex_y-RADIUS];
        temp[lindex_x][lindex_y+BLOCK_SIZE] = in[size* + gindex_y+BLOCK_SIZE];
    }
    __syncthreads();

    // Apply the stencil
    int result = 0;
    for (int offset = -RADIUS; offset <= RADIUS; offset++){
        result += temp[lindex_x+offset][lindex_y];
	result += temp[lindex_x][lindex_y+offset];
    }

    result -= temp[lindex_x][lindex_y]; // Shout out to Taylor for helping with this part
    __syncthreads();

    // Store the result
    out[gindex_y+size*gindex_x] = result;
}


// -------- Matrix Multiplication --------
// Got help from friends (especially Kayleigh & Taylor) with this part and we used these resources 
// github: https://github.com/kberkay/Cuda-Matrix-Multiplication/blob/master/matrix_Multiplication.cu
// stack exchange: https://stackoverflow.com/questions/18815489/cuda-tiled-matrix-matrix-multiplication-with-shared-memory-and-matrix-size-whic
__global__ void matrix_mul(const int *A, const int *B, int *C, int size) {
    __shared__ int tileA[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ int tileB[BLOCK_SIZE][BLOCK_SIZE];

    int idx = blockIdx.x * BLOCK_SIZE + threadIdx.x; // column
    int idy = blockIdx.y * BLOCK_SIZE + threadIdx.y; // row
	
    int temp = 0;

    for (int ntile = 0; ntile < (BLOCK_SIZE+size-1)/BLOCK_SIZE; ntile++){
        if (ntile*BLOCK_SIZE + threadIdx.x < size && idy < size){
            tileA[threadIdx.y][threadIdx.x] = A[idy*size+(ntile*BLOCK_SIZE+threadIdx.x)];
	} else {
            tileA[threadIdx.y][threadIdx.x] = 0;
	}
	if (ntile*BLOCK_SIZE + threadIdx.y < size && idx < size) {
            tileB[threadIdx.y][threadIdx.x] = B[(ntile*BLOCK_SIZE+threadIdx.y)*size+idx];
	} else {
            tileB[threadIdx.y][threadIdx.x] = 0;
        }	
        __syncthreads();

        for (int i = 0; i < BLOCK_SIZE; i++){	
            temp+= tileA[threadIdx.y][i]*tileB[i][threadIdx.x];
        }
        __syncthreads();
    }
	
    // store result
    if(idy < size && idx < size)
        C[((blockIdx.y*blockDim.y+threadIdx.y)*size)+(blockIdx.x*blockDim.x)+threadIdx.x] = temp;
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

    // streams
    cudaStream_t stream1, stream2;
    cudaStreamCreate(&stream1);
    cudaStreamCreate(&stream2);

    // Alloc space for device copies
    cudaMallocManaged((void **)&h_A, size);
    cudaStreamAttachMemAsync(stream1, h_A, size);
    cudaMallocManaged((void **)&h_B, size);
    cudaStreamAttachMemAsync(stream2, h_B, size);
    cudaMallocManaged((void **)&h_C, size);
    cudaMallocManaged((void **)&h_A_stencil, size);
    cudaStreamAttachMemAsync(stream1, h_A_stencil, size);
    cudaMallocManaged((void **)&h_B_stencil, size);
    cudaStreamAttachMemAsync(stream2, h_B_stencil, size);

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
    stencil_2d<<<grid,block,0,stream1>>>(h_A + RADIUS*(N + 2*RADIUS) + RADIUS , h_A_stencil + RADIUS*(N + 2*RADIUS) + RADIUS);
    stencil_2d<<<grid,block,0,stream2>>>(h_B + RADIUS*(N + 2*RADIUS) + RADIUS , h_B_stencil + RADIUS*(N + 2*RADIUS) + RADIUS);
    cudaCheckErrors("Check for proper stencil function performance");

    // Sync streams
    cudaStreamSynchronize(stream1);
    cudaStreamSynchronize(stream2);

    // Also perform matrix multiplication
    int gridSize_matmul = (DSIZE + BLOCK_SIZE-1)/BLOCK_SIZE;
    dim3 grid_matmul(gridSize_matmul, gridSize_matmul);
    dim3 block_matmul(BLOCK_SIZE, BLOCK_SIZE);
    matrix_mul<<<grid_matmul,block_matmul>>>(h_A_stencil, h_B_stencil, h_C, DSIZE);
    cudaCheckErrors("Check for proper matrix multiplication");

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

    cudaStreamDestroy(stream1);
    cudaStreamDestroy(stream2);

    return 0;




}


