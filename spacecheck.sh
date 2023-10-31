#!/bin/bash

var=""  # Variable to store the value after -n
count=0


# Função para calcular o espaço ocupado pelos ficheiros 
dir=${@: -1}
opts="$@"
find_opts=""
sort_cmd="sort -nr"

echo "$opts"
echo "$dir"
# Verificar opções de seleção de ficheiros
if [[ "$opts" == *"-n "* ]]; then
  name_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  find_opts="$find_opts -name $name_pattern"

  echo "name"
  echo "$name_pattern"
fi
  
if [[ "$opts" == *"-d "* ]]; then
  date_limit=$(echo "$opts" | sed -n 's/.*-d \([^ ]*\).*/\1/p')
  find_opts="$find_opts -newermt $date_limit"

  echo "$date_limit"
fi
  
if [[ "$opts" == *"-s "* ]]; then
  size_limit=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  find_opts="$find_opts -size +${size_limit}c"
fi



#LIXO
for i in "$@"; do 
  ((count++))  # Increment the counter

  if [ "$i" == "-n" ] ; then
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
  else 
    echo "Falso" 
  fi 
done

echo "The value after -n is: $var"

echo "SIZE    NAME $(date +%Y%m%d) $*"
(du "$var" | sort -n -r | cut -d '%' -f1) #| grep $2)




# Function to reverse an array
reverse_array() {
    local -n arr=$1  # Create a reference to the input array
    local arrayLength=${#arr[@]}  # Get the length of the array

    local reversedArray=()  # Declare an array to store the reversed elements

    # Iterate through the original array in reverse order and populate the reversed array
    for ((i = arrayLength - 1; i >= 0; i--)); do
        reversedArray+=("${arr[i]}")
    done

    # Update the original array with the reversed elements
    arr=("${reversedArray[@]}")
}