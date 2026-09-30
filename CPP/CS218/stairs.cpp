#include <iostream>
#include <vector>

using namespace std;

// Divide and conquer
int main(){
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    long n; // n stairs
    if(!(cin >> n)) return 1; // Exit if input is invalid

    vector<long> stairs(n);
    long trueDifference = 0; // The difference between the modified stair and the previous stair

    // Grab n inputs
    for(long i = 0; i < n; ++i){
        cin >> stairs[i];
    }       

    // NOTE: Only one step is modified, so we can sample the difference between two steps
        // Then we should have a true difference
    // Search for true difference between steps
    // Check difference between 0 to 1 step and n-1 to n-2 step
    long diff1 = stairs.at(1) - stairs.at(0);
    long diff2 = stairs.at(2) - stairs.at(1); 
    long diff3 = stairs.at(n-1) - stairs.at(n-2);
    if (diff1 == diff2 || diff1 == diff3) {
        trueDifference = diff1;
    } else {
        trueDifference = diff2;
    }

    // Looks like there's two edge cases, step1 and step2 are modified

    // Check if first step is modified
    if(diff1 != diff2 && diff2 == diff3){
        //modifiedIndex = 0;
        cout << 1 << endl;
        return 0;

    // Check if second is modified
    } else if (diff1 != diff2 && diff1 != diff3 && diff2 != diff3){
        cout << 2 << endl;
        return 0;
    } else {
        // Check middle steps (2 to n-1)
        for(long i = 1; i < n; ++i){
            if(stairs.at(i) - stairs.at(i-1) != trueDifference){
                //modifiedIndex = i;
                cout << i+1 << endl;
                return 0;
            }
        }
    }
    // If no steps modified were detected, it must be the final step
    cout << n << endl;

    return 0;
}