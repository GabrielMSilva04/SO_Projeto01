#!/bin/bash

# Função para calcular o espaço ocupado pelos ficheiros 
dir=${@: -1}
opts="$*"
find_opts=""
sort_cmd="sort -nr"

# Function to print array elements based on start and end indices
print_array() {
    local -n arr=$1  # Using a nameref to reference the array
    local start=$2
    local end=$3

    for (( i = start; i <= end-1; i++ )); do
        echo "${arr[i]}"
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

# Verificar opções de seleção de ficheiros
if [[ "$opts" == *"-n "* ]]; then #n = filtrar nome
  name_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  find_opts="$find_opts -name $name_pattern"

  # Find directories containing files with a specific name pattern (e.g., .txt extension)
  mapfile -t directories < <(find "$dir" -type f -name "*$name_pattern" -exec dirname {} \; | sort -u)
  mapfile -t array < <(du "${directories[@]}")

  if [[ "$opts" == *"-l "* ]]; then
    nlines=$(echo "$opts" | sed -n 's/.*-l \([^ ]*\).*/\1/p')
  else
    nlines=${#array[@]}
  fi

  print_array array 0 "$nlines"

elif [[ "$opts" == *"-d "* ]]; then
  date_limit=$(echo "$opts" | sed -n 's/.*-d \([^ ]*\).*/\1/p')
  find_opts="$find_opts -newermt $date_limit"

  # Execute the du command and store its output into an array
  mapfile -t array < <(du --time "$dir")

  print_array array 0 "$nlines"

elif [[ "$opts" == *"-s "* ]]; then
  size_limit=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  find_opts="$find_opts -size +${size_limit}c"

else
  # Execute the du command and store its output into an array
  mapfile -t array < <(du "$dir" | $sort_cmd)

  if [[ "$opts" == *"-l "* ]]; then
    nlines=$(echo "$opts" | sed -n 's/.*-l \([^ ]*\).*/\1/p')
  else
    nlines=${#array[@]}
  fi

  print_array array 0 "$nlines"
fi

#(du "$dir" | sort -n -r | grep "objects")