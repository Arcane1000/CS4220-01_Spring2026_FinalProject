# CS4220-01 Spring 2026 Final Project

## Description.
For my Final Project in my CS 4220-01 Course at Cal Poly Pomona, I am creating a code to determine word count and frequency of a word or character in a text file. I am using GPU's to prove the processing time to be faster than CPU's.

## How to Run
Step 1: Compile
- Compile the CUDA source file using the NVIDIA compiler (nvcc)
    nvcc my_script.cu -o my_script

Step 2: Run
- Execute the compiled code and provide a target character or word(s) in parenthesis for the frequency test
    ./my_script "____"

## Dependencies
C++ Library: Used for reading the file, handling string variables, and printing the output (results of the code).

CUDA Toolkit (nvcc): Used to compile CUDA (.cu) files and run GPU kernels on an NVIDIA GPU.

## Hardware/Software
An NVIDIA GPU is used with CUDA support to run the GPU Kernels. It is developed and tested on the NCSA GPU Cluster, provided by my school. I was able to access and use these tools through my NCSA student account and VS Code.

## Code Structure
Source File: my_script.cu
- The main CUDA Source File that contains all three versions of the word count: the CPU, the GPU (Global Memory), and the new GPU (Shared Memory).

Text File: input.txt
- The text file used as an input for all three versions. It contains the content so the program can read, count, and search through.