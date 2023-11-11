#!/bin/bash

files=${@: -2}
file1=${@: -2:1}
file2=${@: -1}
opts=$*

print_array() {
  local nlines
  local -n arr=$1  # Using a nameref to reference the array

  if [[ "$opts" == *"-l "* ]]; then
    nlines=$(echo "$opts" | sed -n 's/.*-l \([^ ]*\).*/\1/p')
  else
    nlines=${#arr[@]}
  fi
  echo "SIZE NAME"
  for (( i = 0; i < nlines && i < ${#arr[@]}; i++ )); do
    trimmed_element=$(echo "${arr[i]}" | xargs)  # Trimming leading and trailing whitespace
    echo "$trimmed_element"
  done
}

#comandos spacecheck.sh
#./spacecheck.sh -d "Oct 1 00:00" -n ".*mlx" "/home/gabriel-silva/Insync/gabrielmsilva4@ua.pt/OneDrive Biz" > ./output1

#./spacecheck.sh -d "Oct 20 00:00" -n ".*mlx" "/home/gabriel-silva/Insync/gabrielmsilva4@ua.pt/OneDrive Biz" > ./output2

# Função para calcular o espaço ocupado pelos ficheiros
sort_cmd="sort -nr"

if [[ "$opts" == *"-r "* ]]; then
  sort_cmd="sort -n"
fi

if [[ "$opts" == *"-a "* ]]; then
  sort_cmd="sort"
fi

if [[ "$opts" == *"-ra "* ]]; then
  sort_cmd="sort -r"
fi


# Check if the file exists
if [ -f "$file1" ] && [ -f "$file2" ]; then
  mapfile -t lines1 < <(
    # Read the file line by line
    firstLine=true
    while IFS= read -r line
    do
      if [ "$firstLine" = true ]; then
        firstLine=false
        continue  # Skips the first line
        fi
        echo "$line"
    done < "$file1"
  )
  

  mapfile -t lines2 < <(
    # Read the file line by line
    firstLine=true
    while IFS= read -r line
    do
      if [ "$firstLine" = true ]; then
        firstLine=false
        continue  # Skips the first line
        fi
        echo "$line"
    done < "$file2"
  )
fi

#print_array lines1
#echo "--------------------------------------------------"
#print_array lines2

#print_array lines2 | cut -d ' ' -f 1 #numeros


for (( i = 0; i < ${#lines1[@]}; i++ )); do
  found=false
  for (( j = 0; j < ${#lines2[@]}; j++ )); do
    if [ "$(echo "${lines1[i]}" | cut -d ' ' -f 2-)" = "$(echo "${lines2[j]}" | cut -d ' ' -f 2-)" ]; then
      found=true
      size1=$(echo "${lines1[i]}" | cut -d ' ' -f 1)
      size2=$(echo "${lines2[j]}" | cut -d ' ' -f 1)
      break
    fi
  done
  
  if [ "$found" = "true" ]; then
    echo "$((size1 - size2)) $(echo "${lines1[i]}" | cut -d ' ' -f 2-)"
  elif [ "$found" = "false" ]; then
    size1=$(echo "${lines1[i]}" | cut -d ' ' -f 1)
    #echo ${lines1[i]}
    echo "-$size1 $(echo "${lines1[i]}" | cut -d ' ' -f 2-) REMOVED"
  fi
done

#print_array lines1 | cut -d ' ' -f 2 #nomes
#echo "--------------------------------------------------"
#print_array lines2 | cut -d ' ' -f 2 #nomes