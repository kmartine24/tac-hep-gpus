#include <iostream> 
#include <stdio.h>
#include <cstdlib> 

using namespace std;

const int DSIZE = 512;
const int radius = 3;
const int A_val = 2;
const int B_val = 3;

// -------- STENCIL FIRST --------
void stencil(const int in[][DSIZE], int out[][DSIZE]) {
    for (int x_idx = 0; x_idx < DSIZE; ++x_idx) {
        for (int y_idx = 0; y_idx < DSIZE; ++y_idx) {
            int in_cell = in[x_idx][y_idx];
	    if (x_idx < radius || x_idx + radius >= DSIZE) {
                out[x_idx][y_idx] = in_cell;
            }
	    else if (y_idx < radius || y_idx + radius >= DSIZE) {
                out[x_idx][y_idx] = in_cell;
            }
	    else {
                int sum_temp = 0; 
		for (int offset = -radius; offset <= radius; ++offset) {
                    sum_temp += in[x_idx + offset][y_idx];
		    sum_temp += in[x_idx][y_idx + offset];
                }
		sum_temp -= in_cell;
		out[x_idx][y_idx] = sum_temp;
            }
        }
    }
}


// -------- MATRIX MULTIPLICATION --------
void matmul(const int A[][DSIZE], const int B[][DSIZE], int C[][DSIZE], int size){
    int A_temp[DSIZE*DSIZE];
    int B_temp[DSIZE*DSIZE];
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            A_temp[i*DSIZE + j] = A[i][j];
            B_temp[i*DSIZE + j] = B[i][j];
        }
    }
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            int add = 0;
	    for (int k = 0; k < size; ++k) {
                add += A_temp[i*size + k]*B_temp[k*size + j];
            }
	    C[i][j] = add;
	}
    }
}

// -------- CHECKERS --------
// Notice that these checks are similar to the one we did in CUDA from the homework
// %%%%%%%% (A) STENCIL %%%%%%%%
// %%%%%%%% (B) MATRIX %%%%%%%%
void matmul_check(const int A[][DSIZE], const int B[][DSIZE], const int C[][DSIZE]) {
    int Aval_stencil = A_val + A_val*4*radius;
    int Bval_stencil = B_val + B_val*4*radius;
    int avg_DSIZE = DSIZE - 2*radius;
    for (int i = 0; i < DSIZE; ++i) {
        for (int j = 0; j < DSIZE; ++j) {
            if ((i < radius || i + radius >= DSIZE) && (j < radius || j + radius >= DSIZE)) {
                if (C[i][j] != A_val*B_val*DSIZE) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[i][j], A_val*B_val*DSIZE);
                }
            }
            else if ((i < radius || i + radius >= DSIZE) && (j >= radius && j + radius < DSIZE)) {
                if (C[i][j] != A_val*B_val*2*radius + A_val*Bval_stencil*avg_DSIZE) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[i][j], A_val*B_val*2*radius + A_val*Bval_stencil*avg_DSIZE);
                }
            }
	    else if ((i >= radius && i + radius < DSIZE) && (j >= radius && j + radius < DSIZE)) {
                if (C[i][j] != A_val*B_val*2*radius + Aval_stencil*Bval_stencil*avg_DSIZE) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[i][j], A_val*B_val*2*radius + Aval_stencil*Bval_stencil*avg_DSIZE);
                }
            }
            else {
                if (C[i][j] != A_val*B_val*2*radius + Aval_stencil*B_val*avg_DSIZE) {
                    printf("Mismatch at index [%d,%d], was: %d, should be: %d\n", i,j, C[i][j], A_val*B_val*2*radius + Aval_stencil*B_val*avg_DSIZE);
                }
            }
        }
    }
    printf("No Errors found\n");
}

int main() {
    int A[DSIZE][DSIZE];
    int B[DSIZE][DSIZE];

    int A_stencil[DSIZE][DSIZE];
    int B_stencil[DSIZE][DSIZE];
    int C[DSIZE][DSIZE];

    for (int i = 0; i < DSIZE; ++i) {
        for (int j = 0; j < DSIZE; ++j) {
            A[i][j] = A_val;
	    B[i][j] = B_val;

	    A_stencil[i][j] = 0;
	    B_stencil[i][j] = 0; 

	    C[i][j] = 0;
	}
    }

    //Stencil:
    stencil(A, A_stencil);
    stencil(B, B_stencil);

    // Matrix Multiplication: 
    matmul(A_stencil, B_stencil, C, DSIZE);
    // Matrix Multiplication Checker: 
    matmul_check(A_stencil, B_stencil, C);

    return 0;
}



