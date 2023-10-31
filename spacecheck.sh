#!/bin/bash 

#!/bin/bash

var=""  # Variable to store the value after -n
count=0

for i in "$@"; do 
  ((count++))  # Increment the counter

  if [ "$i" == "-n" ] ; then 
    echo "Verdadeiro"
    nextIndex=$((count + 1))  # Calculate the index of the next argument
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


#echo $count
#echo "$var"

#echo "SIZE    NAME $(date +%Y%m%d) $*"
#(du "$1" | sort -n -r | cut -d '%' -f1) #| grep $2)