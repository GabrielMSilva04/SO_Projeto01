#!/bin/bash

files=${@: -2}
filenew=${@: -2:1}
fileold=${@: -1}
opts=$*

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

sort_cmd="sort -nr"

if [[ "$opts" == *"-r "* ]]; then
  sort_cmd="sort -n"

elif [[ "$opts" == *"-a "* ]]; then
  sort_cmd="sort -t '/' -k2,2"

elif [[ "$opts" == *"-ra "* ]]; then
  sort_cmd="sort -r -t '/' -k2,2"
fi


#ler os ficheiros
if [ -f "$fileold" ] && [ -f "$filenew" ]; then # Check if the file exists
  mapfile -t linesold < <(
    # Read the file line by line
    firstLine=true
    while IFS= read -r line
    do
      if [ "$firstLine" = true ]; then
        firstLine=false
        continue  # Skips the first line
        fi
        echo "$line"
    done < "$fileold"
  )
  

  mapfile -t linesnew < <(
    # Read the file line by line
    firstLine=true
    while IFS= read -r line
    do
      if [ "$firstLine" = true ]; then
        firstLine=false
        continue  # Skips the first line
        fi
        #if [ echo "$line" | cut -d ' ' -f 1 != "0" ]; then
        #  continue
        #fi
        echo "$line"
    done < "$filenew"
  )
fi


mapfile -t array < <( 
  for (( i = 0; i < ${#linesold[@]}; i++ )); do
    found=false
    for (( j = 0; j < ${#linesnew[@]}; j++ )); do
      if [ "$(echo "${linesold[i]}" | cut -d ' ' -f 2-)" = "$(echo "${linesnew[j]}" | cut -d ' ' -f 2-)" ]; then
        found=true
        sizeold=$(echo "${linesold[i]}" | cut -d ' ' -f 1)
        sizenew=$(echo "${linesnew[j]}" | cut -d ' ' -f 1)
        unset 'linesnew[j]' #remove a linha do array para não ser comparada novamente
        break
      fi
    done
    
    if [ "$found" = "true" ]; then #se a linha foi encontrada
      echo "$((sizeold - sizenew)) $(echo "${linesold[i]}" | cut -d ' ' -f 2-)"
    elif [ "$found" = "false" ]; then
      sizeold=$(echo "${linesold[i]}" | cut -d ' ' -f 1)
      echo "$((0 - sizeold)) $(echo "${linesold[i]}" | cut -d ' ' -f 2-) REMOVED"
    fi
  done

  for (( i = 0; i < ${#linesnew[@]}; i++ )); do
    if [ -n "${linesnew[i]}" ]; then
      sizenew=$(echo "${linesnew[i]}" | cut -d ' ' -f 1)
      echo "$sizenew $(echo "${linesnew[i]}" | cut -d ' ' -f 2-) NEW"
    fi
  done
)

echo "SIZE NAME"
print_array array | eval "$sort_cmd"