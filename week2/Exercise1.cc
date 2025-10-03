#include <iostream> 
#include <vector> 

struct vals {
    int val1; 
    int val2;
};

vals swap(int &a, int &b) {
    int x = a;
    a = b; 
    b = x;

    vals answer = {a, b};
    return answer;
}

int main() {
    std::vector<int> arrA = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    std::vector<int> arrB = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19};

    std::cout << "******** Before Swap ********" << std::endl;
    std::cout << "arrA = ";
    for (int i = 0; i < arrA.size(); ++i) {
        std::cout << arrA[i] << " ";
    }
    std::cout << std::endl;
    std::cout << "arrB = ";
    for (int i = 0; i < arrB.size(); ++i) {
        std::cout << arrB[i] << " ";
    }
    std::cout << std::endl;
    for (int i = 0; i < arrA.size(); ++i) {
        swap(arrA[i], arrB[i]);
    }
    std::cout << "******** After Swap *********" << std::endl;
    std::cout << "arrA = ";
    for (int i = 0; i < arrA.size(); ++i) {
        std::cout << arrA[i] << " ";
    }
    std::cout << std::endl;
    std::cout << "arrB = ";
    for (int i = 0; i < arrB.size(); ++i) {
        std::cout << arrB[i] << " ";
    }
    std::cout << std::endl;


    return 0;
}

