#!/bin/bash

readonly API_KEY= # Your API's key
readonly CITY_NAME= # Your city name

#   ****************** AirQuality ******************

readonly lat= # Your city's latitude
readonly lon= # Your city's longitude

aqi_data=""

function download_weather_data() {
  local url="http://api.openweathermap.org/data/2.5/air_pollution?lat=${lat}&lon=${lon}&appid=${API_KEY}"
  aqi_data=$(curl -s "$url")
}

function parseData() {
  # $1-key
  local key="\"${1}\":"
  local value=$(echo "$aqi_data" | awk -F"$key" '{print $2}' | awk -F"[,}]" '{print $1}')
  echo "$value"
}

function calcParamVal() {
  # $1 - param key, $2 - param quota
  local value=$(parseData "$1")
  local percent=$(echo "scale=3; ${value}/${2}*100" | bc | sed 's/^\./0./' | cut -d'.' -f1)
  echo "$percent%"
}

download_weather_data

pm25=$(calcParamVal "pm2_5" "15")
pm10=$(calcParamVal "pm10" "25")
no2=$(calcParamVal "no2" "50")

readonly aqi_info=" -air quality: PM2.5: ${pm25}, PM10: ${pm10}, NO2: ${no2}"

#   ****************** Weather ******************

# Krakow
readonly CITY_CODE= # your city' code

temp=""
press=""
humi=""
wind_speed=""
weather_data=""
weather_info=""

function download_weather_data() {
  local url="api.openweathermap.org/data/2.5/weather?id=${CITY_CODE}&units=metric&appid=${API_KEY}"
  weather_data=$(curl -s "$url")
}

function get_value_for_keyword() {
  # $1-line, $2-keyword
  local value=$(echo "${1}" | awk -F"\"${2}\":" '{print $NF}' | cut -d "," -f1 | awk '{print $1}')
  echo "$value"
}

function parse_wind_info() {
  local wind=$(echo "$weather_data" | awk -F'"wind":' '{print $NF}' | cut -d "}" -f1)
  wind_speed=$(get_value_for_keyword "$wind" 'speed')
}

function parse_main_info() {
  local main=$(echo "$weather_data" | awk -F'"main":' '{print $NF}' | cut -d "}" -f1)
  temp=$(get_value_for_keyword "$main" 'temp')
  press=$(get_value_for_keyword "$main" 'pressure')
  humi=$(get_value_for_keyword "$main" 'humidity')
}

function convert_mps_to_kmph() {
  # $1 - value in m/s (without a uint)
  local kmph=$(echo "scale=1;$1*3.6" | bc)
  echo "$kmph km/h"
}

function prepare_weather_info() {
  temp=" -temperature: $temp °C"
  pressure=" -pressure: $press hPa"
  humidity=" -humidity: $humi %"
  wind_speed=$(convert_mps_to_kmph $wind_speed)
  wind_speed=" -wind speed $wind_speed"
}

download_weather_data
parse_main_info
parse_wind_info
prepare_weather_info

readonly weather_info="Current weather in Kraków:\n${temp}\n${pressure}\n${humidity}\n${wind_speed}\n${aqi_info}\n"

echo -e "$weather_info"
