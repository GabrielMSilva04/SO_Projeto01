#!/bin/bash

# Verifica se existem pelo menos 2 argumentos
if [ $# -lt 2 ]; then
    echo "Missing at least two arguments."
    exit 1
fi

filenew=${@: -2:1} #penultima palavra
fileold=${@: -1} #ultima palavra
opts=$*

print_array() {
  local nlines
  local -n arr=$1 # Usa uma referência de nome para referir a matriz

  if [[ "$opts" == *"-l "* ]]; then #se o utilizador especificar o numero de linhas
    nlines=$(echo "$opts" | sed -n 's/.*-l \([^ ]*\).*/\1/p')
  else
    nlines=${#arr[@]}
  fi
  for (( i = 0; i < nlines && i < ${#arr[@]}; i++ )); do
    trimmed_element=$(echo "${arr[i]}" | xargs) # Remove whitespaces no início e no final
    echo "$trimmed_element"
  done
}

# sort options
sort_cmd="sort -nr"

if [[ "$opts" == *"-r "* ]]; then
  sort_cmd="sort -n"

elif [[ "$opts" == *"-a "* ]]; then
  sort_cmd="sort -t '/' -k2"

elif [[ "$opts" == *"-ra "* ]]; then
  sort_cmd="sort -r -t '/' -k2"
fi


#ler os ficheiros
if [ -f "$fileold" ] && [ -f "$filenew" ]; then # Check if the files exist
  mapfile -t linesold < <(
    firstLine=true
    # Ler o ficheiro linha por linha
    while IFS= read -r line
    do
      if [ "$firstLine" = true ]; then
        firstLine=false
        continue # Ignora a primeira linha
        fi
        echo "$line"
    done < "$fileold"
  )
  

  mapfile -t linesnew < <(
    firstLine=true
    # Ler o ficheiro linha por linha
    while IFS= read -r line
    do
      if [ "$firstLine" = true ]; then
        firstLine=false
        continue # Ignora a primeira linha
        fi
        echo "$line"
    done < "$filenew"
  )
else
  echo "File not found"
  exit 1
fi


mapfile -t array < <( 
  for (( i = 0; i < ${#linesold[@]}; i++ )); do
    found=false
    for (( j = 0; j < ${#linesnew[@]}; j++ )); do
      # se o nome do ficheiro for igual
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
    elif [ "$found" = "false" ]; then #se a linha não foi encontrada (foi removida)
      sizeold=$(echo "${linesold[i]}" | cut -d ' ' -f 1)
      echo "$((0 - sizeold)) $(echo "${linesold[i]}" | cut -d ' ' -f 2-) REMOVED"
    fi
  done

  #verificar se existem ficheiros novos
  for (( i = 0; i < ${#linesnew[@]}; i++ )); do
    if [ -n "${linesnew[i]}" ]; then
      sizenew=$(echo "${linesnew[i]}" | cut -d ' ' -f 1)
      echo "$sizenew $(echo "${linesnew[i]}" | cut -d ' ' -f 2-) NEW"
    fi
  done
)

echo "SIZE NAME"
if [[ "$opts" == *"-a "* ]] || [[ "$opts" == *"-ra "* ]]; then
  print_array array | awk -F'/' '{print "1 " $0 " IGNORE"}' | eval "$sort_cmd" | cut -d' ' -f2- | rev | cut -d' ' -f2- | rev
else
  print_array array | eval "$sort_cmd"
fi