#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> stairs(n);
    for (int i = 0; i < n; ++i) cin >> stairs[i];

    long long d;
    // Check if end points give valid integer step height
    if ((stairs[n - 1] - stairs[0]) % (n - 1) == 0) {
        long long cand = (stairs[n - 1] - stairs[0]) / (n - 1);
        // Verify candidate against at least one difference
        if (cand == stairs[1] - stairs[0] || cand == stairs[n - 1] - stairs[n - 2] || cand == stairs[2] - stairs[1]) {
            d = cand;
        } else {
            // Endpoints were affected
            if (stairs[2] - stairs[1] == stairs[n - 1] - stairs[n - 2]) d = stairs[2] - stairs[1];
            else d = stairs[1] - stairs[0];
        }
    } else {
        // Endpoints are definitely corrupted
        d = stairs[n - 1] - stairs[n - 2];
        if (stairs[1] - stairs[0] == stairs[2] - stairs[1]) d = stairs[1] - stairs[0];
    }

    // Now reconstruct correct array and find the mismatch index!
    // Try building correct sequence starting from stairs[0]
    int wrong_count = 0;
    int wrong_idx = -1;

    for (int i = 0; i < n; ++i) {
        long long expected = stairs[0] + i * d;
        if (stairs[i] != expected) {
            wrong_count++;
            wrong_idx = i + 1;
        }
    }

    // If exactly 1 element mismatched, stairs[0] was correct and wrong_idx is our answer!
    if (wrong_count == 1) {
        cout << wrong_idx << "\n";
    } else {
        // Otherwise stairs[0] itself was the wrong element!
        cout << 1 << "\n";
    }

    return 0;
}
