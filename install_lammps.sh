#!/bin/bash

#Now clone your favorite Lammps code
cd /root
git clone https://github.com/lammps/lammps.git --depth=1
cd /root/lammps/src

#Now build Lammps
make yes-user-omp
make serial -j20

mkdir -p /opt/lammps/bin
cp lmp_serial /opt/lammps/bin
