#!/bin/bash

readonly hour=$(date +"%-H")
readonly month=$(date +"%m" | sed 's/0//')
welcome=""
name= # Your name 

if [[ $hour -ge "6" && $hour -lt "12" ]] ; then # whole year
  welcome="Good morning"
elif [[ $hour -ge "12" && $hour -le "17" ]] && [[ $month -ge "10" || $month -le "3" ]] ; then # winter
  welcome="Good afternoon"
elif [[ $hour -ge "12" && $hour -le "20" ]] && [[ $month -gt "3" && $month -lt "10" ]] ; then # summer
  welcome="Good afternoon"
else # whole year
  welcome="Good evening"
fi

echo "$welcome $name\n"
