#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

START_GAME(){
    if [[ -z $USER_GUESS ]]
        then
                echo "Guess the secret number between 1 and 1000:"
                TRIES=1
        else
                if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
                    then
                        echo "That is not an integer, guess again:"
                elif (( $USER_GUESS > $SECRET_NUMBER ))
                    then
                        echo "It's lower than that, guess again:"
                        TRIES=$(( TRIES+1 ))
                elif (( $USER_GUESS < $SECRET_NUMBER ))
                    then
                        echo "It's higher than that, guess again:"
                        TRIES=$(( TRIES+1 ))
                else
                        echo -e "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
                        if [[ -z $BEST_GAME  ]] || (( $TRIES < $BEST_GAME ))
                            then
                                UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $(( GAMES_PLAYED+1 )), best_game = $TRIES WHERE user_id = $USER_ID")
                            else
                                UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $(( GAMES_PLAYED+1 )) WHERE user_id = $USER_ID")
                        fi
                        exit 0
                fi
    fi
    read USER_GUESS
    START_GAME
}

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

SECRET_NUMBER=$(( RANDOM%1000 + 1 ))

echo "Enter your username: "
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
echo $USER_ID
if [[ -z $USER_ID ]]
    then
        echo "Welcome, $USERNAME! It looks like this is your first time here."
        INSERT_USER_RESULT=$($PSQL "INSERT INTO users (name) VALUES ('$USERNAME')")
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
    else
        USER_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE user_id = $USER_ID")
        GAMES_PLAYED=$(echo $USER_RESULT | sed -E 's/(^[0-9]+).+$/\1/')
        BEST_GAME=$(echo $USER_RESULT | sed -E 's/^.+\ ([0-9]+)$/\1/')
        echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

START_GAME



