#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
R=$(($RANDOM%1001))
echo Enter your username: 
read USERNAME
USERNAME_EXIST=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_EXIST ]]
  then 
   echo Welcome, $USERNAME! It looks like this is your first time here.
   INSERT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  else
 
  echo $USERNAME_EXIST | while IFS="|" read USER_NAME GAMES_PLAYED BEST_GAME
   do
     echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
   done  
fi

echo Guess the secret number between 1 and 1000:
read NUMBER
NUMBER_OF_GUESSES=1
MAIN_MENU() {
 if [[ ! $1 =~ ^[0-9]+$ ]]
    then 
    echo That is not an integer, guess again:
    read NUMBER
    MAIN_MENU $NUMBER
  
 fi
 if [[ $1 > $R ]]
    then 
    echo -e It\'s lower than that, guess again:
    read NUMBER
    ((NUMBER_OF_GUESSES++))
    MAIN_MENU $NUMBER

  elif [[ $1 < $R ]]
    then
    echo -e It\'s higher than that, guess again:
    read NUMBER
    ((NUMBER_OF_GUESSES++))
    MAIN_MENU $NUMBER
  elif [[ $1 == $R ]]
  then
  echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $R. Nice job!
  INCREMENT=$($PSQL "UPDATE users SET games_played= games_played + 1 WHERE username='$USERNAME'")
  BEST=$($PSQL "SELECT best_game FROM users WHERE (best_game>$NUMBER_OF_GUESSES OR best_game=0) AND username='$USERNAME'")
    if [[ $BEST ]]
      then 
      INSERT=$($PSQL "UPDATE users SET best_game= $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
    fi
  exit
 fi
}
MAIN_MENU $NUMBER