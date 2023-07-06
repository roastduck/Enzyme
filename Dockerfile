ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG LLVM

WORKDIR /opt/enzyme

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends lsb-release software-properties-common

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add -
RUN DEBIAN_FRONTEND=noninteractive apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -c | cut -f2`/ llvm-toolchain-`lsb_release -c | cut -f2`-${LLVM} main" || true
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cmake ninja-build gcc g++ llvm-${LLVM}-dev clang-${LLVM} libclang-${LLVM}-dev libomp-${LLVM}-dev
RUN python3 -m pip install lit

COPY . .

WORKDIR /opt/enzyme/build
RUN cmake -G Ninja ../enzyme -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_EXTERNAL_LIT=`which lit` -DLLVM_DIR=/usr/lib/llvm-${LLVM}/lib/cmake/llvm -DClang_DIR=/usr/lib/llvm-${LLVM}/lib/cmake/clang
RUN ninja

WORKDIR /workspace
