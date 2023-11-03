#!/bin/bash

# Função para calcular o espaço ocupado pelos ficheiros 
dir=${@: -1}
opts="$*"
find_opts=""
sort_cmd="sort -nr"

# Function to print array elements based on start and end indices
print_array() {
  local nlines
  local -n arr=$1  # Using a nameref to reference the array

  if [[ "$opts" == *"-l "* ]]; then
      nlines=$(echo "$opts" | sed -n 's/.*-l \([^ ]*\).*/\1/p')
  else
      nlines=${#arr[@]}
  fi
  
  for (( i = 0; i < nlines && i < ${#arr[@]}; i++ )); do
    trimmed_element=$(echo "${arr[i]}" | xargs)  # Trimming leading and trailing whitespace
      echo "$trimmed_element"
  done
}


if [[ "$opts" == *"-r "* ]]; then
  sort_cmd="sort -n"
fi

if [[ "$opts" == *"-a "* ]]; then
  sort_cmd="sort"
fi

if [[ "$opts" == *"-ra "* ]]; then
  sort_cmd="sort -r"
fi

echo "SIZE    NAME $(date +%Y%m%d) $*"

if [[ "$opts" == *"-n "* ]]; then # n = filtrar nome
  name_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  find_opts="$find_opts -name $name_pattern"

  # Find directories containing files with a specific name pattern
  mapfile -t directories < <(find "$dir" -type f -name "*$name_pattern" -exec dirname {} \; | sort -u)
  mapfile -t array < <(du "${directories[@]}" | $sort_cmd)

  print_array array


elif [[ "$opts" == *"-d "* ]]; then #mostrar dicheiros mdificados depois da data
  # Extracting date argument
  while [[ "$#" -gt 0 ]]; do
      case $1 in
          -d) date_argument="$2"; shift ;;
      esac
      shift
  done

  # Convert "Sep 10 10:00" format to "YYYY-MM-DD HH:MM"
  converted_date=$(date -d "$date_argument" "+%Y-%m-%d %H:%M")

  # Use the converted date with find -newermt to filter files
  mapfile -t array < <(find . -type f -newermt "$converted_date" -exec du {} \; | $sort_cmd)


  print_array array

elif [[ "$opts" == *"-s "* ]]; then
  size_limit=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  find_opts="$find_opts -size +${size_limit}c"






else
  # Execute the du command and store its output into an array
  mapfile -t array < <(du "$dir" | $sort_cmd)

  print_array array
fi