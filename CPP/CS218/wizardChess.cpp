#include <iostream>
#include <string>
#include <vector>
#include <queue>
#include <utility>

using namespace std;

// 8 possible moves for a Knight (rowChange, colChange)
const int dr[] = {2, 2, -2, -2, 1, 1, -1, -1}; 
const int dc[] = {1, -1, 1, -1, 2, -2, 2, -2};

// Constructs "a1" into row/col 0-indexed 32 bit integers
pair<int, int> parseSquare(const string&s){
    int col = s[0] - 'a'; // Turn char into integer in binary by subtracting 'a' offset
    int row = s[1] - '1'; // Board begins at '1'
    return {row, col};
}

void solve(int n, int boardNum){
    // Create an 8x8 grid: 0 = free, -1 = taken
    vector<vector<int>> board(8, vector<int>(8,0));

    // Mark taken squares
    for(int i = 0; i < n; ++i){
        string takenSquare;
        cin >> takenSquare;
        pair<int, int> pos = parseSquare(takenSquare);
        int r = pos.first;
        int c = pos.second;

        board[r][c] = -1;
    }

    // Output the map
    //for(int i = 0; i < 8; ++i){
    //    for(int j = 0; j < 8; ++j){
    //        cout << board[i][j] << " ";
    //    }
    //    cout << endl;
    //}

    // Read starting square and destination
    string startStr, destStr;
    cin >> startStr >> destStr;

    pair<int, int> startPos = parseSquare(startStr);
    pair<int, int> destPos = parseSquare(destStr);
    int startR = startPos.first;
    int startC = startPos.second;
    int destR = destPos.first;
    int destC = destPos.second;

    // Runs BFS graph traversal algorithm
    // BFS setup
    // dist[r][c] holds minimun moves from start to (r,c)
    vector<vector<int>> dist(8, vector<int>(8,-1));
    queue<pair<int,int>> q;
    
    // Initialize BFS if start square isn't blocked
    if(board[startR][startC] != -1){
        q.push({startR, startC});// First item in the queue is the start square
        dist[startR][startC] = 0;
    }

    int nMoves = -1; // -1 = unreachable, if(!= -1) -> it is reachable
    
    // q runs until it is empty
    // The first element it has is the start column and row
    // After each iteration, it has a new element and pops the previous 
    while(!q.empty()){
        pair<int, int> curr = q.front();
        int r = curr.first;
        int c = curr.second;
        q.pop();

        // Target reached, stop looping
        if(r == destR && c == destC){
            nMoves = dist[r][c];
            break;
        }

        // Try all 8 possible moves as Knight
        for(int i = 0; i < 8; ++i){
            // new row/column
            int nr = r + dr[i];
            int nc = c + dc[i];

            // Bound check (within 8x8 board)
            if(nr >= 0 && nr < 8 && nc >= 0 && nc < 8){
                // Move check (move isn't blocked nor visited)
                if(board[nr][nc] != -1 && dist[nr][nc] == -1){
                    dist[nr][nc] = dist[r][c] + 1;
                    q.push({nr, nc});
                }
            }
        }

    }

    // Output result
    cout << "Board " << boardNum << ": ";
    if(nMoves != -1){
        cout << nMoves << " moves\n";
    } else {
        cout << "not reachable\n";
    }

}

// Objective: Find minimun number of moves to arrive to the destination
// Constraint: There are some squares taken by other pieces
// Very likely a DP problem
// Chess piece is y-axis (1-8) and x-axis ('a' to 'h')
int main(){
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    // number of taken squares on the chessboard
    int n = 0; 
    int boardNum = 1;

    // Loop until n = -1
    while(cin >> n && n != -1){
        solve(n, boardNum++);
    }

    return 0;
}