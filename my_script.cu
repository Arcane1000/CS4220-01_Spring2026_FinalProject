//
// Seena Mohebpour
// CS 4220.02
// Tue Apr 21, 2026
//

#include <iostream>
#include <fstream>
#include <string>
using namespace std;

// Upper to Lower Case
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
                int &wordCount, int &targetCount) {
    
    wordCount = 0;
    targetCount = 0;

    int n = content.size();

    // Loop through text
    for (int i = 0; i < n; i++) {
        
        // 
        if (isLetter(content[i]) && (i == 0 || !isLetter(content[i - 1]))) {
            
            wordCount++;

            bool match = true;

            // 
            for (int j = 0; j < target.size(); j++) {
                
                // 
                if (i + j >= n) {
                    match = false;
                    break;
                }

                // 
                if (toLowerChar(content[i + j]) != toLowerChar(target[j])) {
                    match = false;
                    break;
                }
            }

            // Full Word, not Partial (Like "he" in "hello")
            if (match) {
                if (i + target.size() < n && isLetter(content[i + target.size()])) {
                    match = false;
                }
            }

            // Count Valid Match.
            if (match) {
                targetCount++;
            }
        }
    }
}

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

    int wordCount = 0;
    int targetCount = 0;

    countWords(content, target, wordCount, targetCount);

    // Print Results.
    cout << "Total Word Count: " << wordCount << endl;
    cout << "Frequency of \"" << target << "\": " << targetCount << endl;
    cout << endl;

    return 0;
}
