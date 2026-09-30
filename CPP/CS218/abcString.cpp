#include <iostream>

using namespace std;

// Precompute length (allocate necessary memory) of S_k for k = 50
// L[1] = 3
// L[k] = 2 * L[k-1] + 3
long long len[51];

void precomputeLength(){
    len[1]=3;
    for(int k = 2; k <= 50; ++k){
        len[k] = 2 * len[k-1] + 3;
    }
}

// Finds teh characters at index (idx) in S_k
char getChar(int k, long long idx){

    // Base Case: k = 1, "ABC" substring
    if(k == 1){
        switch(idx){
            case 1: return 'A';
            case 2: return 'B';
            case 3: return 'C';
        }
    }

    // The following is part of 'A' + S_{k-1} + 'B' + S_{k-1} + 'C', (k >= 2)
    // 'A' Char
    if(idx == 1){
        return 'A';
    }

    // First S_{k-1} (recursive call)
    // if: 2 <= idx <= 1 + L[k-1], recurse to S_{k-1}
    long long lenPrev = len[k-1];
    if (idx <= 1 + lenPrev){
        return getChar(k-1, idx - 1); // S_{k-1}
    }

    // 'B' Char if idx == 2 + L[k-1]
    if (idx == 2 + lenPrev){
        return 'B';
    }

    // Second S_{k-1} (recursive call)
    // if: 3 + L[k-1] <= idx <= 2 + 2*L[k-1]
    // Index = idx - (2 + L[k-1])
    if(idx <= 2 + 2 * lenPrev){
        return getChar(k-1, idx - (2+lenPrev));
    }
   
    // Return last char, 'C'
    // idx == 3 + 2 * L[k-1]
    return 'C';

}

void solve(){
    short k;
    long long l, r;
    // Grabs entire line (runs n times)
    cin >> k >> l >> r;

    // Gets the char substring from l^th to r^th (inclusive) substring
    for(long long i = l; i <= r; ++i){
        cout << getChar(k, i);
    }
    cout << '\n';

}

// Divide and conquer problem with a recurrence relation
// Can be solved recursively
int main(){
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    // n holds amount of strings
    // Output substring between lth and rth characters of S_k
    // S_k = { ABC, k=1
    // A * S_k-1 * B * S_k-1 * C, k >= 2 }
    precomputeLength();

    short n;
    // Runs n times, solving input string
    if(cin >> n){
        while(n--){
            solve();
        }
    }
    return 0;

}