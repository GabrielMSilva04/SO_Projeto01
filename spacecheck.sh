#!/bin/bash

# Verifica se existem argumentos
if [ $# -eq 0 ]; then
    echo "Arguments required."
    exit 1
fi

dir="${@: -1}" #ultima palavra
opts=$*

# sort options
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
  local -n arr=$1  # Usa uma referência de nome para referir a matriz

  if [[ "$opts" == *"-l "* ]]; then
    nlines=$(echo "$opts" | sed -n 's/.*-l \([^ ]*\).*/\1/p')
  else
    nlines=${#arr[@]}
  fi
  echo "SIZE NAME $(date +%Y%m%d) $opts"
  for (( i = 0; i < nlines && i < ${#arr[@]}; i++ )); do
    trimmed_element=$(echo "${arr[i]}" | xargs)  # Remove whitespaces no início e no final
    echo "$trimmed_element"
  done
}
  
# Encontra diretórios com ficheiros com um padrão de nome específico
if [[ "$opts" == *"-n "* ]]; then
  regex_pattern=$(echo "$opts" | sed -n 's/.*-n \([^ ]*\).*/\1/p')
  name_opt="-regex $regex_pattern"
fi

if [[ "$opts" == *"-d "* ]]; then
  # Extrai argumento de data
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -d) date_argument="$2"; shift ;;
    esac
    shift
  done

  # Converte o formato "Sep 10 10:00" para "YYYY-MM-DD HH:MM"
  converted_date=$(date -d "$date_argument" "+%Y-%m-%d %H:%M")
  if [[ "$converted_date" == "" ]]; then
    echo "Data inválida"
    exit 1
  fi
fi

if [[ "$opts" == *"-s "* ]]; then
  size_min=$(echo "$opts" | sed -n 's/.*-s \([^ ]*\).*/\1/p')
  size_opt="-size +${size_min}c" # define a opção de tamanho mínimo
fi

# Encontra todos os diretórios
mapfile -t directories < <(find "$dir" -type d 2>/dev/null | sort -u) #filta a lista de diretorios

if [[ ${#directories[@]} -eq 0 ]]; then
  echo "No directories found"
  exit 1
else

  mapfile -t directories_size < <(
    for d in "${directories[@]}"; do
      sum=0
      if [[ "$opts" == *"-d "* ]]; then
        # Usa a data convertida com find -not -newermt para filtrar ficheiros mais antigos
        mapfile -t filtered_list < <(find "$d" -type f ${name_opt:+$name_opt} -not -newermt "$converted_date" ${size_opt:+$size_opt} 2>/dev/null | sort -u)
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
          sum=$((sum + space)) # soma o tamanho dos ficheiros que passam no filtro
        done
      fi
      echo "$sum $d"
      
    done | sort -u
  )

  # Ordena e armazena o output num array
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

  print_array array # imprime o array
fi