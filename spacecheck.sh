#!/bin/bash

var=""  # Variable to store the value after -n
count=0


# Função para calcular o espaço ocupado pelos ficheiros 
dir=${@: -1}
opts="$@"
find_opts=""
sort_cmd="sort -nr"

#echo "$opts"
#echo "$dir"
echo "SIZE    NAME $(date +%Y%m%d) $*"
# Verificar opções de seleção de ficheiros
if [[ "$opts" == *"-n "* ]]; then #n = numerical
  name_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  find_opts="$find_opts -name $name_pattern"

  #echo "name pattern = $name_pattern"
  if [[ "$opts" == *"-r "* ]]; then
    sort_cmd="sort -n"
  fi

  if [[ "$opts" == *"-a "* ]]; then
    sort_cmd="sort"
  fi

  # Execute the du command and store its output into an array
  mapfile -t array < <(du "$dir" | $sort_cmd)

  # Display the array elements (for demonstration)
  for line in "${array[@]}"; do
    echo "$line"
  done
fi
  
if [[ "$opts" == *"-d "* ]]; then
  date_limit=$(echo "$opts" | sed -n 's/.*-d \([^ ]*\).*/\1/p')
  find_opts="$find_opts -newermt $date_limit"


  # Execute the du command and store its output into an array
  mapfile -t array < <(du --time "$dir")

  # Display the array elements (for demonstration)
  for line in "${array[@]}"; do
    echo "$line"
  done

  echo "primeira linha:"
  echo "${array[0]}"

  #echo "$date_limit"
fi
  
if [[ "$opts" == *"-s "* ]]; then
  size_limit=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  find_opts="$find_opts -size +${size_limit}c"
fi



#LIXO
for i in "$@"; do 
  ((count++))  # Increment the counter

  if [ "$i" == "-n" ] ; then
    echo "numerical"
    nextIndex=$((count + 1))  # Calculate the index of the next argument
    if [ $count != 1 ] ; then
      case $1 in
        "-a")
            Message="Alfabeticamente"
            ;;
        "-r")
            Message="Reverso"
            ;;
      esac

      echo "$Message"
    fi  
    if [ $nextIndex -le $# ]; then
        var="${!nextIndex}"  # Get the argument at the next index
        break  # Stop the loop as we found the value after -n
    else
        echo "No value found after -n" >&2
        exit 1  # Exit with an error if there's no value after -n
    fi
  fi 
done

#(du "$var" | sort -n -r | cut -d '%' -f1) | grep $2)