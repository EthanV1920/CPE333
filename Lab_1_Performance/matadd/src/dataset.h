
#ifndef __DATASET_H
#define __DATASET_H
#define ARRAY_SIZE 25 


#define DIM_SIZE 5 


typedef int data_t;static data_t input1_data[ARRAY_SIZE] = 
{
    3,   2,   2,   2,   2,   1,   2,   2,   1,   3,   3,   1,   1,   3,   2,   1,   0,   0,   0,   0, 
    1,   0,   0,   1,   3
};

static data_t input2_data[ARRAY_SIZE] = 
{
    0,   3,   0,   2,   3,   3,   3,   2,   3,   0,   1,   3,   2,   0,   2,   0,   3,   3,   1,   0, 
    0,   2,   2,   3,   2
};

static data_t verify_data[ARRAY_SIZE] = 
{
    8,  31,  18,  20,  17,   8,  24,  17,  18,  13,   4,  28,  17,  18,  15,   0,   3,   0,   2,   3, 
    0,  12,   9,  12,   9
};


#endif //__DATASET_H