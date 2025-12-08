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
	}
    }
}

// -------- CHECKERS --------
// %%%%%%%% (A) STENCIL %%%%%%%%
// %%%%%%%% (B) MATRIX %%%%%%%%


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
}



