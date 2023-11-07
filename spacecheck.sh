#!/bin/bash

# Função para calcular o espaço ocupado pelos ficheiros 
dir="${@: -1}"
opts=$*
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
  echo "SIZE NAME $(date +%Y%m%d) $opts"
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

if [[ "$opts" == *"-n "* ]]; then # n = filtrar nome
  regex_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  
  # Find directories containing files with a specific name pattern
  mapfile -t directories < <(find "$dir" -type f -regex "$regex_pattern" -exec dirname {} \; | sort -u)
  if [[ ${#directories[@]} -eq 0 ]]; then
    echo "No files found matching the pattern '$regex_pattern'"
    exit 1
  else
    mapfile -t array < <(du -b "${directories[@]}" | $sort_cmd)
  fi

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
  mapfile -t array < <(find . -type f -newermt "$converted_date" -exec du -b {} \; | $sort_cmd)
  if [[ ${#array[@]} -eq 0 ]]; then
    echo "No files found modified after '$date_argument'"
    exit 1
  else
    print_array array
  fi

elif [[ "$opts" == *"-s "* ]]; then
  size_min=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  
  mapfile -t directories < <(find "$dir" -type d)
  
  mapfile -t directory_sizes < <(
    for d in "${directories[@]}"; do
      sum=0
      mapfile -t filtered_list < <(find "$d" -size +"$size_min"c )
      if [[ ${#filtered_list[@]} -gt 0 ]]; then
        for e in "${filtered_list[@]}"; do
          space=$(du -s -b "$e" | cut -f1)
          sum=$((sum + space))
        done
      fi
      echo "$sum $d"
    done | sort -u
  )

  mapfile -t sorted_directory_sizes < <(printf "%s\n" "${directory_sizes[@]}" | $sort_cmd)

  
  print_array sorted_directory_sizes


else
  # Execute the du command and store its output into an array
  mapfile -t array < <(du -b "$dir" | $sort_cmd)

  print_array array
fi