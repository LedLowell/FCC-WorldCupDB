#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Script to insert data from games.csv to worldcup database.
#Truncate Tables
echo $($PSQL "TRUNCATE teams RESTART IDENTITY CASCADE;")
echo $($PSQL "TRUNCATE games RESTART IDENTITY CASCADE;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
#Skip first line
if [[ $YEAR != year ]]
then
#Insert Teams
#get team_id
WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
#If winner not found
if [[ -z $WINNER_TEAM_ID ]]
then
#Insert winner team
INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
echo $INSERT_WINNER_RESULT $WINNER
#Get new winner_id
WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
echo new winner id $WINNER_TEAM_ID
#If opponent not found
fi
if [[ -z $OPPONENT_TEAM_ID ]]
then
#Insert opponent team
INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
echo $INSERT_OPPONENT_RESULT $OPPONENT
#Get new opponent_id
OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
echo new opponent id $OPPONENT_TEAM_ID
fi
#Insert games
#get game_id
GAME_ID=$($PSQL "SELECT game_id FROM games WHERE (year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_TEAM_ID AND opponent_id=$OPPONENT_TEAM_ID)")
#If not found
if [[ -z $GAME_ID ]]
then
#Insert game
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
echo $INSERT_GAME_RESULT $YEAR $ROUND Game
fi
fi
done