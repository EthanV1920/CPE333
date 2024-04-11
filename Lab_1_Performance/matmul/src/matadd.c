#include "dataset.h"
#include <stddef.h>

/* NxM matrices */
void matadd(int N, int M, const data_t A[], const data_t B[], data_t C[])
{
  int i, j;
  
  for (i = 0; i < N; i++) {
    for (j = 0; j < M; j++) {
      C[i*N + j] = A[i*N + j] + B[i*N + j];
    }
  }
}