//
// Seena Mohebpour
// CS 4220.02
// Tue Apr 21, 2026
//

#include <iostream>
#include <fstream>
#include <string>
#include <cuda_runtime.h>
#include <ctime>
using namespace std;

#define BLOCK_SIZE 256
#define TILE_SIZE (BLOCK_SIZE + 64)

// ============
//   CPU Test
// ============

// Converts Upper to Lower Case
char toLowerChar(char c) {
    if (c >= 'A' && c <= 'Z') {
        return c + ('a' - 'A');
    }

    return c;
}

// Check character is letter.
bool isLetter(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

// Count total words, and frequency of specific word.
void countWords(const string &content, const string &target,
                int &wordCount, int &targetCount, int &charCount) {
    
    // Counters to 0 before counting.
    wordCount  = 0;
    targetCount = 0;
    charCount  = 0;
    
    // Total size in file.
    int n = content.size();

    // Loop every character in text.
    for (int i = 0; i < n; i++) {
        
        // Letter -> Character Total.
        if (isLetter(content[i])) charCount++;  // count letters as characters

        if (isLetter(content[i]) && (i == 0 || !isLetter(content[i - 1]))) {
            wordCount++;
            bool match = true;

            // Compare each character of target word against text.
            for (int j = 0; j < (int)target.size(); j++) {
                // Run out of text before finishing, no match.
                if (i + j >= n) { 
                    match = false; 
                    break; 
                }
                
                // Characters don't match, no match.
                if (toLowerChar(content[i + j]) != toLowerChar(target[j])) {
                    match = false; 
                    break;
                }
            }

            // Full Word Match, not partial.
            if (match && i + (int)target.size() < n &&
                isLetter(content[i + target.size()])) {
                match = false;
            }

            // All checks passed, valid word count.
            if (match) targetCount++;
        }
    }
}

// ============
//   GPU Test
// ============


__device__ char gpu_toLower(char c) {
    if (c >= 'A' && c <= 'Z') {
        return c + ('a' - 'A');
    }

    return c;
}

__device__ bool gpu_isLetter(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

__global__ void kernel
(const char *text, int n, const char *target, int tlen, int *wordCount, int *targetCount, int *charCount) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i >= n) return;

    // Character Count
    if (gpu_isLetter(text[i])) {
        atomicAdd(charCount, 1);
    }

    // Word Check
    if (!gpu_isLetter(text[i])) return;

    if (i > 0 && gpu_isLetter(text[i - 1])) return;

    // Word Count
    atomicAdd(wordCount, 1);

    // Target Match
    if (i + tlen > n) return;
    

    for (int j = 0; j < tlen; j++) {
        if (gpu_toLower(text[i + j]) != gpu_toLower(target[j])) return;
    }

    if (i + tlen < n && gpu_isLetter(text[i + tlen])) return;
    
    atomicAdd(targetCount, 1);

}

// =============
//   Main Test
// =============

int main(int argc, char *argv[]) {
    
    // How to Run Script. User Provides Word.
    if (argc < 2) {
        cout << "Usage: ./my_script \"word\"" << endl;
        return 1;
    }

    string target = argv[1];

    // Open File.
    ifstream file("input.txt");

    if (!file) {
        cout << "Error: Could Not Open input.txt" << endl;
        return 1;
    }

    // Entire File into String.
    string content((istreambuf_iterator<char>(file)), 
                    istreambuf_iterator<char>());

    int n = content.size();

    // CPU TEST

    int wordCount = 0;
    int targetCount = 0;
    int charCount = 0;

    clock_t cpuStart, cpuEnd;

    cpuStart = clock();
    countWords(content, target, wordCount, targetCount, charCount);
    cpuEnd = clock();
    double cpuTime = double(cpuEnd - cpuStart);
    
    // Print Results.
    cout << "===== CPU RESULTS =====" << endl << endl;
    cout << "Total Word Count: " << wordCount << endl;
    cout << "Total Character Count: " << charCount << endl;
    cout << "Frequency of \"" << target << "\": " << targetCount << endl;
    cout << "CPU Processing Time: " << cpuTime << " ms" << endl;
    cout << endl;

    // GPU Setup
    char *d_text;
    char *d_target;

    int *d_wordCount;
    int *d_targetCount;
    int *d_charCount;

    int h_wordCount;
    int h_targetCount;
    int h_charCount;

    cudaMalloc(&d_text, n * sizeof(char));
    cudaMalloc(&d_target, target.size() * sizeof(char));
    cudaMalloc(&d_wordCount, sizeof(int));
    cudaMalloc(&d_targetCount, sizeof(int));
    cudaMalloc(&d_charCount, sizeof(int));

    cudaMemcpy(d_text, content.c_str(), n, cudaMemcpyHostToDevice);
    cudaMemcpy(d_target, target.c_str(),  target.size(), cudaMemcpyHostToDevice);

    int threads = BLOCK_SIZE;
    int blocks = (n * threads - 1) / threads;

    cudaEvent_t gpuStart, gpuEnd;

    cudaEventCreate(&gpuStart);
    cudaEventCreate(&gpuEnd);
    float gpuTime = 0;

    // GPU TEST
    h_wordCount = h_targetCount = h_charCount = 0;

    cudaMemcpy(d_wordCount, &h_wordCount, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_targetCount, &h_targetCount, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_charCount, &h_charCount, sizeof(int), cudaMemcpyHostToDevice);

    cudaEventRecord(gpuStart);
    kernel<<<blocks, threads>>>(d_text, n, d_target, target.size(), 
                                d_wordCount, d_targetCount, d_charCount);

    cudaEventRecord(gpuEnd);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&gpuTime, gpuStart, gpuEnd);

    cudaMemcpy(&h_wordCount, d_wordCount, sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(&h_targetCount, d_targetCount, sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(&h_charCount, d_charCount, sizeof(int), cudaMemcpyDeviceToHost);

    // Print Results.
    cout << "===== GPU RESULTS =====" << endl << endl;
    cout << "Total Word Count: " << h_wordCount << endl;
    cout << "Total Character Count: " << h_charCount << endl;
    cout << "Frequency of \"" << target << "\": " << h_targetCount << endl;
    cout << "GPU Processing Time: " << gpuTime << " ms" << endl;
    cout << endl;

    return 0;
}

