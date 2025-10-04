#include <iostream> 

using namespace std; 

void game(string &player1, string &player2) {
    // rock beats scissors 
    // scissors beat paper 
    // paper beats rock

    if (player1 == player2) {
        cout << "Players Tied! Play again" << endl;
    }
    if (player1 == "scissors" && player2 == "rock") {
        cout << "Player 2 wins! Rock beats scissors" << endl;
    }
    if (player2 == "scissors" && player1 == "rock") {
        cout << "Player 1 wins! Rock beats scissors" << endl;
    }
    if (player1 == "scissors" && player2 == "paper") {
        cout << "Player 1 wins! Scissors beat paper" << endl;
    }
    if (player2 == "scissors" && player1 == "paper") {
        cout << "Player 2 wins! Scissors beat paper" << endl;
    }
    if (player1 == "paper" && player2 == "rock") {
        cout << "Player 1 wins! Paper beats rock" << endl;
    }
    if (player2 == "paper" && player1 == "rock") {
        cout << "Player 2 wins! Paper beats rock" << endl;
    }

}

int main() {
    string player1; 
    string player2; 

    cout << "Player 1, enter your move: " << endl;
    cin >> player1; 
    cout << "Player 2, enter your move: " << endl;
    cin >> player2; 

    game(player1, player2);
    return 0;
}


