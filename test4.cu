//�h�϶�, �h����� (�ϥΰj��)
#include <cuda.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctime>

//----------------------------------------------
//�V�q�[�k���B��֤� (GPU) **�禡�e�[ __global__ �Y���֤�, �֤ߥu�Ǧ^ void**
__global__ void gpu_add(float* c, float* a, float* b, int n){
        int j=blockIdx.x*blockDim.x+threadIdx.x;
        int m=gridDim.x*blockDim.x;
        for(int k=j; k<n; k+=m){
                c[k]=a[k]+b[k];
        }
}


//----------------------------------------------
//�V�q�[�k���@��禡 (Host)
void host_add(float* c, float* a, float* b, int n){
        for(int k=0; k<n; k++){
                c[k]=a[k]+b[k];
        }
}


//----------------------------------------------
//�p��~�t�Ϊ��禡
double diff(float* a, float* b, int n){
        double s=0, r=0;
        for(int k=0; k<n; k++){
                double w=a[k]-b[k];
                s+=w*w;
                r+=a[k]*a[k];
        }
        return sqrt(s/r); //�۹�~�t
}

//----------------------------------------------
//�ɶ���� (�Ǧ^���:�d�����@��)
double ms_time(){
        return (double)clock()/CLOCKS_PER_SEC*1000.0;
}

//----------------------------------------------
//�D�{��
int main(){
        //�]�w�V�q�j�p
        int n=1024*1024;
        int size=n*sizeof(float);

        //����P�϶��]�w
        int block=256;    //blockDim (�C�Ӱ϶��㦳���������)
        int grid=30;     //gridDim  (�C�Ӻ���㦳���϶���)

        //�]�w�I�s���� (���q�����į�)
        int loop=100;

        //�t�m�D���O����
        float *a,*b,*c,*d;
        a=(float*)malloc(size);
        b=(float*)malloc(size);
        c=(float*)malloc(size);
        d=(float*)malloc(size);

        //�]�w�üƪ���J�V�q
        srand(time(0));
        for(int k=0; k<n; k++){
                a[k]=(float)rand()/RAND_MAX*2-1;
                b[k]=(float)rand()/RAND_MAX*2-1;
        }

        //�t�m��ܥd�O����
        float  *ga,*gb,*gc;
        cudaMalloc((void**)&ga, size);
        cudaMalloc((void**)&gb, size);
        cudaMalloc((void**)&gc, size);

        //���J�V�q a,b ����ܥd�O���餤
        cudaMemcpy(ga, a, size, cudaMemcpyHostToDevice);
        cudaMemcpy(gb, b, size, cudaMemcpyHostToDevice);

        //---- part 1 : ���q��T�� --------

        //�I�s�֤ߨӹB�� (GPU)
        gpu_add<<<grid, block>>>(gc, ga, gb, n);

        //�I�s�@���ƨӹB�� (Host)
        host_add(d, a, b, n);

        //��p�⵲�G�s�^�D��
        cudaMemcpy(c, gc, size, cudaMemcpyDeviceToHost);

        //�����̮t��
        printf("vector add N(%d) elements, diff = %g\n", n, diff(c,d,n));



        //---- part 2 : ���q�į� --------

        //���q GPU �֤߮į�
        double gpu_dt = ms_time();
        for(int w=0; w<loop; w++){
                gpu_add<<<grid, block>>>(gc, ga, gb, n);
                cudaThreadSynchronize();  //�קK�֤߰��椣����
        }
        gpu_dt = (ms_time()-gpu_dt)/loop; //�����ɶ�


        //���q Host ��Ʈį�
        double host_dt = ms_time();
        for(int w=0; w<loop; w++){
                host_add(d, a, b, n);
        }
        host_dt = (ms_time()-host_dt)/loop; //�����ɶ�


        //��X��������ɶ�
        printf("host time: %g ms\n", host_dt);
        printf("gpu  time: %g ms\n", gpu_dt);


        //����D���O����
        free(a);
        free(b);
        free(c);
        free(d);

        //������ܥd�O����
        cudaFree(ga);
        cudaFree(gb);
        cudaFree(gc);

        return 0;
}