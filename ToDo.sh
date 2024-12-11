basePath="$HOME/Documentos/Task"

comprobacionAdd(){
    if [ -z "$2" ]; then
        echo "Error: Necesitas proporcionar un nombre para el nuevo espacio."
        echo "Uso: toDo add <nombre>"
        return 1
    fi
    return 0
}

comprobacion(){
    if [ ! -z "$2" ]; then
        echo "No hace falta añadir nada, se continura con el proceso por default."
    fi
}
arranque(){
    cat "$basePath/general_task.txt"
}
add(){
    if [ -z "$1" ]; then
        echo "Error: Necesitas proporcionar un nombre para la tarea."
        echo "Uso: toDo add <nombre>"
        return 1
    fi
    selected=$(ls "$basePath" | fzf)
    task="$@"
    if [ -z "$selected" ]; then
        echo "Error no se ha seleccionado nada"
        return 1
    fi
    if grep -q "$task" "$basePath/$selected"; then
        echo "Error"
        echo "La tarea '$@' ya existe en la lista."
        return 1
    fi

    echo "$@" >> "$basePath/$selected"
    echo "Se ha añadido '$@' a la lista $selected."
}
list(){
    selected=$(ls "$basePath" | fzf)
    cat "$basePath/$selected"
    
}
remove(){
    selected=$(ls "$basePath" | fzf)
    task=$(cat "$basePath/$selected" | fzf)
    if [ -z "$task" ]; then
        echo "No se ha seleccionado nada"
        return 1
    fi
    sed -i "/$task/d" "$basePath/$selected"
    echo "Tarea '$task' borrada."
}
check(){
    selected=$(find "$basePath" -type f -name "*_task*" | fzf)
    eleccion=$(cat "$selected" | fzf)
    if [ -z "$eleccion" ]; then
        echo "No se ha seleccionado nada"
        return 1
    fi
    direccion=$(find "$basePath" -type f -name "*_done*" | fzf)
    echo "$eleccion" >> "$direccion"
    sed -i "/$eleccion/d" "$selected"
    echo "Check '$eleccion' realizada."
}

clear(){
    selected=$(ls "$basePath" | fzf)
    if [ -z "$selected" ]; then
        echo "No se ha seleccionado nada"
        return 1
    fi
    > "$basePath/$selected"
    echo "Se ha vaciado $selected."
}

create(){
    files=$(ls $basePath)
    file1="${1}_task.txt"
    file2="${1}_done.txt"
    if echo "$files" | grep -q -w "$file1" || echo "$files" | grep -q -w "$file2"; then
        echo "Error"
        echo "El espacio ya existe en la lista."
        return 1
    fi
    echo "===========LISTA DE TAREAS===========" >> "$basePath/$file1"
    echo "===========LISTA DE DONE=============" >> "$basePath/$file2"
    echo "Se ha creado el espacio $file1 y el espacio $file2."
}
destroy(){
    selected=$(ls "$basePath" | fzf)
    if [ -z "$selected" ]; then
        echo "No se ha seleccionado nada"
        return 1
    fi
    rm "$basePath/$selected"
    if [[ "$selected" == *_done.txt ]]; then
        rm -f "$basePath/${selected/_done.txt/_task.txt}"
    elif [[ "$selected" == *_task.txt ]]; then
        rm -f "$basePath/${selected/_task.txt/_done.txt}"
    fi
    echo "Se ha borrado con éxito."
}
case $1 in
    arranque)
        arranque 
        ;;
    add)
        comprobacionAdd $@
        if [ $? -eq 0 ]; then  
            add "$2"
        fi
        ;;
    list)
        comprobacion $@
        list
        ;;
    remove)
        comprobacion $@
        remove
        ;;
    done)
        comprobacion $@
        check
        ;;
    clear)
        comprobacion $@
        clear
        ;;
    create)

        comprobacionAdd $@
        if [ $? -eq 0 ]; then  
            create "$2"
        fi
        ;;
    destroy)
        comprobacion $@
        destroy
        ;;
    help)
        echo -e "   Uso:      toDo [add|list|remove|done|clear]\n"
        echo -e "   add:      Añadir una tarea a la lista. Se debe especificar el nombre de la tarea y luego seleccionar donde añadir. Ejemplo: toDo add 'Comprar pan'"
        echo -e "   list:     Mostrar las listas de tareas. Se debe de seleccionar cual ver.\n"
        echo -e "   remove:   Borrar una tarea de la lista. Se debe elegir el nombre de la tarea que se quiere borrar y de donde. Ejemplo: toDo remove\n"
        echo -e "   done:     Marcar una tarea como realizada. Se debe elegir el nombre de la tarea. Ejemplo: toDo done\n"
        echo -e "   clear:    Limpiar la lista de tareas o de Done. Se debe elegir cual quieres limpiar. Ejemplo: toDo clear\n"
        echo -e "   create:   Crear un nuevo espacio. Se debe especificar el nombre del espacio. Ejemplo: toDo create 'Universidad\n'."
        echo -e "   destroy:  Eliminar un espacio. Se debe elegir el espacio a eliminar. Ejemplo: toDo destroy\n"
        echo -e "   help:     Mostrar ayuda."
        ;;
    *)
        echo "Comando no reconocido"
        echo "Uso: toDo [add|remove|done|list|clear|create|help] <argumentos>"
        ;;
esac
