#include <iostream>
#include <vector>
using namespace std;

// Outputs the length of the LIS, the highest value in the array holds the longest length for LIS
vector<long> findLIS(const vector<long>&nums){
    long n = nums.size();
    vector<long> inc(n,1);
    for(long i = 0; i < n; ++i){
        for(long j = 0; j < i; ++j){
            // If current [j] is lesser than [i], then keep it as a max
            if(nums[j] < nums[i]) inc[i] = max(inc[i], inc[j] + 1); 
        }
    }
    return inc;

}

// Dynamic Programming problem
int main(){
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);
     
    long n;
    if(!(cin>>n)) return 1;

    vector<long> nums(n);
    for(long i = 0; i < n; ++i){
        cin >> nums[i];
    }

    vector<long> dpInc = findLIS(nums); // Increasing DP Table (LIS left to right)

    // Reverse the nums, look for LIS (right to left), then reverse it back to original order
    vector<long> revNums(nums.rbegin(), nums.rend()); // reversing nums
    vector<long> revdpDec = findLIS(revNums); // Decreasing DP table

    // Moving the solved right to left LIS back to original order
    vector<long>dpDec(n);
    for(long i = 0; i < n; ++i){
        dpDec[i] = revdpDec[n - 1 - i];
    }

    // Looking for max unimodal length
    long maxLen = 0;
    for(long i = 0; i < n; ++i){
        maxLen = max(maxLen, dpInc[i] + dpDec[i] - 1); // Where both tables meet right down the middle
    }

    // Outputs the max length of the unimodal substring
    cout << maxLen << endl;

    return 0;
}