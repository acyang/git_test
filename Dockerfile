FROM nvidia/cuda:11.0-cudnn8-devel-centos7
LABEL maintainer "An-Cheng Yang acyang0903@gmail.com"

RUN yum makecache && yum install -y epel-release centos-release-scl && rpm --import /etc/pki/rpm-gpg/RPM* 

RUN yum install -y automake autoconf bzip2 cmake cmake3 devtoolset-7-gcc* git gcc gcc-c++ gcc-gfortran libtool make patch scl-utils unzip zip vim wget openmpi3 openmpi3-devel java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless eigen3-devel

ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/cuda/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH 
ENV PATH /usr/local/cuda/bin:$PATH 

COPY install*.sh /root

# install lammps
RUN cd /root && LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} && \
    source /opt/rh/devtoolset-7/enable && sh -x install_lammps.sh

CMD ["/bin/bash"]
