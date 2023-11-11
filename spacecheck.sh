#!/bin/bash

# Função para calcular o espaço ocupado pelos ficheiros 
dir="${@: -1}"
opts=$*
sort_cmd="sort -nr"

if [[ "$opts" == *"-r "* ]]; then
  sort_cmd="sort -n"

elif [[ "$opts" == *"-a "* ]]; then
  sort_cmd="sort -t '/' -k2,2"

elif [[ "$opts" == *"-ra "* ]]; then
  sort_cmd="sort -r -t '/' -k2,2"
fi

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
  
if [[ "$opts" == *"-n "* ]]; then
  regex_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  name_opt="-regex $regex_pattern"
fi

if [[ "$opts" == *"-d "* ]]; then
  # Extracting date argument
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -d) date_argument="$2"; shift ;;
    esac
    shift
  done

  # Convert "Sep 10 10:00" format to "YYYY-MM-DD HH:MM"
  converted_date=$(date -d "$date_argument" "+%Y-%m-%d %H:%M")
fi

if [[ "$opts" == *"-s "* ]]; then
  size_min=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  size_opt="-size +${size_min}c"
fi

# Find directories containing files with a specific name pattern
# Use the converted date with find -newermt to filter files
mapfile -t directories < <(find "$dir" -type d 2>/dev/null | sort -u) #filta a lista de diretorios

if [[ ${#directories[@]} -eq 0 ]]; then
  echo "No files found"
  exit 1
else

  mapfile -t directories_size < <(
    for d in "${directories[@]}"; do
      sum=0
      if [[ "$opts" == *"-d "* ]]; then
        mapfile -t filtered_list < <(find "$d" -type f ${name_opt:+$name_opt} -newermt "$converted_date" ${size_opt:+$size_opt} 2>/dev/null | sort -u)
      else
        mapfile -t filtered_list < <(find "$d" -type f ${name_opt:+$name_opt} ${size_opt:+$size_opt} 2>/dev/null | sort -u)
      fi

      if [[ ${#filtered_list[@]} -gt 0 ]]; then
        for e in "${filtered_list[@]}"; do
          if ! [[ -r $e ]]; then # caso nao tenha permissao de leitura
            sum="NA"
            break
          fi
          space=$(du -s -b "$e" | cut -f1)
          sum=$((sum + space))
        done
      fi
      echo "$sum $d"
      
    done | sort -u
  )

  # Execute the du command and store its output into an array
  if [[ ${#directories_size[@]} -gt 0 ]]; then
    if [[ "$opts" == *"-a "* ]] || [[ "$opts" == *"-ra "* ]]; then
      mapfile -t array < <(printf "%s\n" "${directories_size[@]}" | awk -F'/' '{print NF-1, $0}' | eval "$sort_cmd" | cut -d' ' -f2-)
    else
      mapfile -t array < <(printf "%s\n" "${directories_size[@]}" | eval "$sort_cmd")
    fi
  else
    echo "No files found"
    exit 1
  fi

  print_array array
fi