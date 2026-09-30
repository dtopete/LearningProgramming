#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

// Greedy Problem
int main(){
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    long long n; // n candies
    if(!(cin >> n)) return 1;

    vector<long> candies(n);
    // We have three ratings, (3 zones in our string)
    int c1 = 0, c2 = 0, c3 = 0;

    for(long long i = 0; i < n; ++i){
        cin >> candies.at(i);
        // Counts how many candies pertain to each zone
        switch (candies.at(i)){
            case 1: ++c1;
            case 2: ++c2;
            case 3: ++c3;
        }
    }

    // loc[x][y] = count of element value y sitting in region x (1-indexed region)
    long loc[4][4] = {0};

    // ideally, 1st are 0<i<c1
    // 2s are c1<i<c2
    // 3s are c3<i<c3

    // Check variables of c1,c2,c3
    //cout << "c1: " << c1 << " c2: " << c2 << " c3: " << c3 << endl;
    for(long i = 0; i < n; ++i){
        int region;
        if (i < c1) region = 1;
        else if (i < c2) region = 2;
        else region = 3;

        // Helps locate out of place numbers
        loc[region][candies[i]]++;
    }

    // Pair up direct swaps
    long swap12 = min(loc[1][2], loc[2][1]); 
    long swap13 = min(loc[1][3], loc[3][1]);
    long swap23 = min(loc[2][3], loc[3][2]);

    long directSwaps = swap12 + swap13 + swap23;
    // Visualize 2D matrix for debugging
    //for(int i = 0; i < 4; ++i){
    //    for(int k = 0; k < 4; ++k){
    //        cout << loc[i][k] << ' ';
    //    }
    //    cout << endl;
    //}

    // Remaining misplaced elements that require 2 swaps
   //long rem1 = (loc[1][2] - swap12) + (loc[1][3] - swap13) + (loc[2][3] - swap23);
   long rem1 = (loc[1][2] - swap12) + (loc[1][3] - swap13);
   //long rem1 = 0;

    // The last 3 element cycle that require 2 swaps
    long cycleSwaps = 2 * rem1;

    long totalSwaps = directSwaps + cycleSwaps;


    cout << totalSwaps << '\n';

    return 0;
}