#include <stdio.h>
#include <iostream>


const int DSIZE_X = 256;
const int DSIZE_Y = 256;

__global__ void add_matrix(float *A, float *B, float *C, int x_dim, int y_dim)
{
    //FIXME:
    // Express in terms of threads and blocks
    int idx = threadIdx.x + blockIdx.x * blockDim.x; 
    int idy = threadIdx.y + blockIdx.y * blockDim.y;

    // Add the two matrices - make sure you are not out of range
    if (idx < x_dim && idy < y_dim) {
        C[idx*y_dim+idy] = A[idx*y_dim+idy] + B[idx*y_dim+idy];
    }
}

int main()
{

    // Create and allocate memory for host and device pointers 
    float *h_A, *d_A, *h_B, *d_B, *h_C, * d_C;
    h_A = new float[DSIZE_X * DSIZE_Y];
    h_B = new float[DSIZE_X * DSIZE_Y];
    h_C = new float[DSIZE_X * DSIZE_Y];

    // Fill in the matrices
    // FIXME
    for (int i = 0; i < DSIZE_X; i++) {
        for (int j = 0; j < DSIZE_Y; j++) {
            //FIXME
	    h_A[DSIZE_Y*i + j] = rand()/(float)RAND_MAX;
	    h_B[DSIZE_Y*i + j] = rand()/(float)RAND_MAX;
	    h_C[DSIZE_Y*i + j] = 0;
        }
    }

    cudaMalloc(&d_A, DSIZE_X*DSIZE_Y*sizeof(float));
    cudaMalloc(&d_B, DSIZE_X*DSIZE_Y*sizeof(float));
    cudaMalloc(&d_C, DSIZE_X*DSIZE_Y*sizeof(float));

    std::cout << "******** Before the Sum: ********" << std::endl;
    for (int i = 0; i < 5; ++i) {
        for (int j = 0; j < 5; ++j) {
	    std::cout << "A["<<i<<"][" << j << "] = "; 
	    std::cout << h_A[i*DSIZE_Y+j] << " ";
	}
	std::cout << std::endl;
    }
    std::cout << std::endl;
    for (int i = 0; i < 5; ++i) {
        for (int j = 0; j < 5; ++j) {
	    std::cout << "B["<<i<<"][" << j << "] = "; 
	    std::cout << h_B[i*DSIZE_Y+j] << " ";
	}
	std::cout << std::endl;
    }

    // Copy from host to device
    cudaMemcpy(d_A, h_A, DSIZE_X*DSIZE_Y*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, DSIZE_X*DSIZE_Y*sizeof(float), cudaMemcpyHostToDevice);

    // Launch the kernel
    // dim3 is a built in CUDA type that allows you to define the block 
    // size and grid size in more than 1 dimentions
    // Syntax : dim3(Nx,Ny,Nz)
    dim3 blockSize(32,32); 
    dim3 gridSize(1,1); 
    
    add_matrix<<<gridSize, blockSize>>>(d_A, d_B, d_C, DSIZE_X, DSIZE_Y);

    // Copy back to host 
    cudaMemcpy(h_C, d_C, DSIZE_X*DSIZE_Y*sizeof(float), cudaMemcpyDeviceToHost);

    // Print and check some elements to make the addition was succesfull
    std::cout << "******** After the Sum: ********" << std::endl;
    for (int i = 0; i < 5; ++i) {
        for (int j = 0; j < 5; ++j) {
	    std::cout << "C["<<i<<"][" << j << "] = "; 
	    std::cout << h_C[i*DSIZE_Y+j] << " ";
	}
	std::cout << std::endl;
    }
    // Free the memory     
    free(h_A);
    free(h_B);
    free(h_C);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}
