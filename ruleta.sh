#!/bin/bash

greenColour="\e[0;32m"
endColour="\e[0m"
redColour="\e[0;31m"
blueColour="\e[0;34m"
yellowColour="\e[0;33m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m"

function ctrl_c() {
    echo -e "\n\n${redColour}[!] Saliendo... ${endColour}\n"
    tput cnorm; exit $1
}

trap ctrl_c INT

function helpPanel() {
    echo -e "\n${purpleColour}[!]${endColour} ${turquoiseColour}Ayuda:${endColour} \n"
    echo -e "${blueColour}Uso:${endColour} $0 ${greenColour}-m ${redColour}<dinero>${endColour} ${greenColour}-t ${redColour}<técnica>${endColour}"
    echo -e "\nLas técnicas son: ${yellowColour}martingala${endColour} / ${yellowColour}inverseLabrouchere${endColour}\n"
    exit 1
}

tput civis

function martingala() {
    echo -e "\n${greenColour}[+]${endColour} Vamos a jugar con la técnica ${yellowColour}martingala${endColour}\n"
    echo -e "\nDinero actual: ${greenColour}$money€ ${endColour}\n"
    echo -ne "${yellowColour}[*]${endColour} Introduce la cantidad que quieres apostar -> " && read initial_bet
    echo -ne "${yellowColour}[*]${endColour} ¿A qué deseas apostar continuamente? (par / impar) -> " && read par_impar

    backup_bet=$initial_bet
    max_money=$money
    max_streak=0
    current_streak=0
    max_loss_streak=0
    current_loss_streak=0
    play_counter=0
    jugadas_malas="[ "

    while true; do
        if [ "$money" -le 0 ]; then
            echo -e "\n${redColour}[!] Has perdido todo tu dinero.${endColour}"
            break
        fi

        money=$(($money - $initial_bet))
        echo -e "${grayColour}[·]${endColour} Dinero restante: ${greenColour}$money€ ${endColour}"
        random_number=$((RANDOM % 37))  
        play_counter=$((play_counter + 1))

        echo -e "[*] Apostando ${greenColour}$initial_bet€${endColour} a ${par_impar} (Número: $random_number)"

        if [ "$random_number" -eq 0 ]; then
            
            initial_bet=$((initial_bet * 2))
            jugadas_malas="$random_number"
            echo -e "${redColour}[!] Has perdido esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
            current_loss_streak=$((current_loss_streak + 1))
            current_streak=0
        else
            if [ "$par_impar" == "par" ]; then
                if [ "$((random_number % 2))" -eq 0 ]; then
                    reward=$((initial_bet * 2)) 
                    money=$(($money + reward))
                    initial_bet=$backup_bet
                    jugadas_malas=""
                    echo -e "${greenColour}[+] Has ganado esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                    current_streak=$((current_streak + 1))
                    current_loss_streak=0
                else
                    initial_bet=$((initial_bet * 2))
                    jugadas_malas="$random_number"
                    echo -e "${redColour}[!] Has perdido esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                    current_loss_streak=$((current_loss_streak + 1))
                    current_streak=0
                fi
            else
                if [ "$((random_number % 2))" -eq 1 ]; then
                    reward=$((initial_bet * 2)) 
                    money=$(($money + reward))
                    initial_bet=$backup_bet
                    jugadas_malas=""
                    echo -e "${greenColour}[+] Has ganado esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                    current_streak=$((current_streak + 1))
                    current_loss_streak=0
                else
                    initial_bet=$((initial_bet * 2))
                    jugadas_malas="$random_number"
                    echo -e "${redColour}[!] Has perdido esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                    current_loss_streak=$((current_loss_streak + 1))
                    current_streak=0
                fi
            fi
        fi

        if [ "$money" -gt "$max_money" ]; then
            max_money=$money
        fi

        if [ "$current_streak" -gt "$max_streak" ]; then
            max_streak=$current_streak
        fi

        if [ "$current_loss_streak" -gt "$max_loss_streak" ]; then
            max_loss_streak=$current_loss_streak
        fi
    done

    echo -e "${greenColour}[+]${endColour} Dinero máximo alcanzado: ${greenColour}$max_money€ ${endColour}"
    echo -e "${greenColour}[+]${endColour} Mayor racha de ganancias: ${greenColour}$max_streak${endColour} jugadas"
    echo -e "${redColour}[!]${endColour} Mayor racha de pérdidas: ${redColour}$max_loss_streak${endColour} jugadas"
    echo -e "\n[+] Han habido un total de ${yellowColour}$play_counter${endColour} jugadas"
    tput cnorm
}

function inverseLabrouchere() {
    echo -e "\n${greenColour}[+]${endColour} Vamos a jugar con la técnica ${yellowColour}inverseLabrouchere${endColour}\n"
    echo -e "\nDinero actual: ${greenColour}$money€ ${endColour}\n"
    
    echo -ne "${yellowColour}[*]${endColour} Introduce la cantidad que quieres apostar -> " && read initial_bet
    echo -ne "${yellowColour}[*]${endColour} ¿A qué deseas apostar continuamente? (par / impar) -> " && read par_impar

    max_money=$money
    max_streak=0
    current_streak=0
    max_loss_streak=0
    current_loss_streak=0
    play_counter=0
    max_wins=0
    max_losses=0

    while true; do
        sequence=(1 2 3 4)  

        while true; do
            if [ ${#sequence[@]} -eq 0 ]; then
                echo -e "${greenColour}[+] Secuencia vacía. Reiniciando...${endColour}"
                break  
            fi

            
            bet=$(( ${sequence[0]} + ${sequence[-1]} ))
            if [ "$money" -lt "$bet" ]; then
                echo -e "${redColour}[!] No tienes suficiente dinero para continuar. Terminando juego.${endColour}"
                return  
            fi

            money=$(($money - $bet))
            echo -e "${grayColour}[·]${endColour} Dinero restante: ${greenColour}$money€ ${endColour}"
            random_number=$((RANDOM % 37))  
            play_counter=$((play_counter + 1))

            echo -e "[*] Apostando ${greenColour}$bet€${endColour} a ${par_impar} (Número: $random_number)"
            echo -e "Secuencia actual: [${sequence[*]}]"

            if [ "$random_number" -eq 0 ]; then
                
                echo -e "${redColour}[!] Has perdido esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                sequence=("${sequence[@]:1:${#sequence[@]}-2}")  
                current_loss_streak=$((current_loss_streak + 1))
                current_streak=0
                ((max_losses > current_loss_streak)) || max_losses=$current_loss_streak
            else
                if [ "$par_impar" == "par" ]; then
                    if [ "$((random_number % 2))" -eq 0 ]; then
                        
                        echo -e "${greenColour}[+] Has ganado esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                        money=$(($money + bet * 2))
                        sequence+=($(( ${sequence[-1]} + 1 )))  
                        current_streak=$((current_streak + 1))
                        current_loss_streak=0
                        ((max_wins > current_streak)) || max_wins=$current_streak
                    else
                        
                        echo -e "${redColour}[!] Has perdido esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                        sequence=("${sequence[@]:1:${#sequence[@]}-2}")  # Eliminar extremos
                        current_loss_streak=$((current_loss_streak + 1))
                        current_streak=0
                        ((max_losses > current_loss_streak)) || max_losses=$current_loss_streak
                    fi
                else
                    
                    if [ "$((random_number % 2))" -eq 1 ]; then
                        
                        echo -e "${greenColour}[+] Has ganado esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                        money=$(($money + bet * 2))
                        sequence+=($(( ${sequence[-1]} + 1 )))  
                        current_streak=$((current_streak + 1))
                        current_loss_streak=0
                        ((max_wins > current_streak)) || max_wins=$current_streak
                    else
                       
                        echo -e "${redColour}[!] Has perdido esta jugada. Dinero restante: ${greenColour}$money€ ${endColour}"
                        sequence=("${sequence[@]:1:${#sequence[@]}-2}")  # Eliminar extremos
                        current_loss_streak=$((current_loss_streak + 1))
                        current_streak=0
                        ((max_losses > current_loss_streak)) || max_losses=$current_loss_streak
                    fi
                fi
            fi

            if [ "$money" -gt "$max_money" ]; then
                max_money=$money
            fi

            if [ "$current_streak" -gt "$max_streak" ]; then
                max_streak=$current_streak
            fi

            if [ "$current_loss_streak" -gt "$max_loss_streak" ]; then
                max_loss_streak=$current_loss_streak
            fi

            if [ "$money" -le 0 ]; then
                echo -e "${redColour}[!] Has perdido todo tu dinero.${endColour}"
                break 2  
            fi
        done
    done

    echo -e "${greenColour}[+]${endColour} Dinero máximo alcanzado: ${greenColour}$max_money€ ${endColour}"
    echo -e "${greenColour}[+]${endColour} Mayor racha de ganancias: ${greenColour}$max_streak${endColour} jugadas"
    echo -e "${redColour}[!]${endColour} Mayor racha de pérdidas: ${redColour}$max_loss_streak${endColour} jugadas"
    echo -e "${greenColour}[+]${endColour} Máximo número de victorias: ${greenColour}$max_wins${endColour} jugadas"
    echo -e "${redColour}[!]${endColour} Máximo número de derrotas: ${redColour}$max_losses${endColour} jugadas"
    echo -e "\n[+] Han habido un total de ${yellowColour}$play_counter${endColour} jugadas"
    tput cnorm
}

while getopts "m:t:h" arg; do
    case $arg in
    m) money=$OPTARG;; 
    t) technique=$OPTARG;;
    h) helpPanel;;
    *) helpPanel;; 
    esac
done

if [[ -z "$money" || -z "$technique" ]]; then
    echo -e "${redColour}[!] Error: No se ha especificado ningún parámetro.${endColour}"
    helpPanel
fi

if [[ "$technique" == "martingala" ]]; then
    martingala
elif [[ "$technique" == "inverseLabrouchere" ]]; then
    inverseLabrouchere
else
    echo -e "${redColour}[!] La técnica introducida no es válida. Por favor, introduce una técnica válida.${endColour}"
    helpPanel
fi
