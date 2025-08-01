FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update

RUN apt-get install -y \
    vim gcc g++ make cmake valgrind gdb \
    ninja-build cppcheck iperf python3-pip python3-venv \
    lsb-release wget software-properties-common gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 17 all

RUN ln -s /usr/bin/clangd-17 /usr/bin/clangd
RUN ln -s /usr/bin/clang-format-17 /usr/bin/clang-format
