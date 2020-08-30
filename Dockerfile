FROM nvidia/cuda:11.0-cudnn8-devel-centos7
LABEL maintainer "An-Cheng Yang acyang0903@gmail.com"
# For now, only CentOS-Base.repo (USTC source, only users in China mainland should use it) and bazel.repo are in 'repo' directory with version 0.15.0. The latest version of bazel may bring failures to the installment.
# COPY repo/*repo /etc/yum.repos.d/
# Add additional source to yum
RUN yum makecache && yum install -y epel-release centos-release-scl && rpm --import /etc/pki/rpm-gpg/RPM* 
# bazel, gcc, gcc-c++ and path are needed by tensorflow;   
# autoconf, automake, cmake, libtool, make, wget are needed for protobut et. al.;  
# epel-release, cmake3, centos-release-scl, devtoolset-4-gcc*, scl-utils are needed for deepmd-kit(need gcc5.x);
# unzip are needed by download_dependencies.sh.
RUN yum install -y automake autoconf bzip2 cmake cmake3 devtoolset-7-gcc* git gcc gcc-c++ gcc-gfortran libtool make patch scl-utils unzip zip vim wget openmpi3 openmpi3-devel java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless eigen3-devel 
#ENV tensorflow_root=/opt/tensorflow xdrfile_root=/opt/xdrfile \
#    deepmd_root=/opt/deepmd deepmd_source_dir=/root/deepmd-kit \
#    PATH="/opt/conda3/bin:${PATH}"
#ARG tensorflow_version=1.12
#ENV tensorflow_version=$tensorflow_version
# Install NCCL for multi-GPU communication
RUN cd /root && git clone https://github.com/NVIDIA/nccl.git && cd nccl && \
  make CUDA_HOME=/usr/local/cuda -j NVCC_GENCODE="-gencode=arch=compute_70,code=sm_70" && \
  make PREFIX=/usr/local/cuda install
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/cuda/lib:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH 
ENV PATH /usr/local/cuda/bin:$PATH 
# If download lammps with git, there will be errors during installion. Hence we'll download lammps later on.
#RUN cd /root && \
#    git clone https://github.com/deepmodeling/deepmd-kit.git deepmd-kit && \
#    git clone https://github.com/tensorflow/tensorflow tensorflow -b "r$tensorflow_version" --depth=1 && \
#    cd tensorflow
# install bazel for version 0.15.0
#RUN wget https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel-0.15.0-installer-linux-x86_64.sh && \
#    bash bazel-0.15.0-installer-linux-x86_64.sh 
# install tensorflow C lib
#COPY install_input /root/tensorflow
#RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
#    cd /root/tensorflow && ./configure < install_input && \
#    LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} && \
#    bazel build -c opt \
    # --incompatible_load_argument_is_label=false
#    --copt=-msse4.2 --config=cuda //tensorflow:libtensorflow_cc.so \ 
#    --action_env="LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
# install the dependencies of tensorflow and xdrfile
COPY install*.sh /root
#RUN cd /root/tensorflow && sed -i 's;PROTOBUF_URL=.*;PROTOBUF_URL=\"https://mirror.bazel.build/github.com/google/protobuf/archive/v3.6.0.tar.gz\";g' tensorflow/contrib/makefile/#download_dependencies.sh && \
#    tensorflow/contrib/makefile/download_dependencies.sh && \
#    cd /root && sh -x install_protobuf.sh && sh -x install_eigen.sh && \
#    sh -x install_nsync.sh && sh -x install_absl.sh && sh -x copy_lib.sh && sh -x install_xdrfile.sh 
# `source /opt/rh/devtoolset-4/enable` to set gcc version to 5.x, which is needed by deepmd-kit.
# install deepmd
#RUN cd /root && source /opt/rh/devtoolset-4/enable && \ 
#    LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} && \ 
#    sh -x install_deepmd.sh
# install lammps
RUN cd /root && LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} && \
    source /opt/rh/devtoolset-7/enable && sh -x install_lammps.sh
# install tensorflow in python3 module
#RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.5.1-Linux-x86_64.sh && \
#    sh Miniconda3-4.5.1-Linux-x86_64.sh -b -p /opt/conda3/ && \
#    conda config --add channels conda-forge && \
    # conda install -c conda-forge -y tensorflow-gpu=$tensorflow_version
#    pip install tensorflow-gpu==${tensorflow_version}.0
CMD ["/bin/bash"]
