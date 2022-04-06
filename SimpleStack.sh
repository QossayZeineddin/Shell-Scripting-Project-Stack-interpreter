#! /bin/bash

#declare the simplestack to be implemented as array
simpleStack=()

#the backup ofthe stack bfore last command
simpleStackBackup=()

#to push element to array stack, add it to the end of the array
stackPush() { simpleStack+=("$1"); }

#get the top element which is the last element in the array
stackTop() { 
    if [[ $(stackSize) -gt 0 ]];
    then
        printf %s\\n "${simpleStack[-1]}"; 
    fi
}

#get then remove the last element of the stack
stackPop() { 
    if [[ $(stackSize) -gt 0 ]];
    then
        unset 'simpleStack[-1]'; 
    fi
}

#get the current stack size
#from internet
stackSize() { echo ${#simpleStack[@]}; }

#print the stack
stackPrint() {
    if [[ $(stackSize) -gt 0 ]];
    then
        for (( size=${#simpleStack[@]}-1 ; size>=0 ; size-- )) ; do
            echo -n "${simpleStack[size]} "
        done
        echo ""
    fi
}
#colors the string form internet
RED='\033[0;31m' #Red color
GREEN='\033[1;36m' #Green color
NC='\033[0m' #No color

#user input variable
userInput=""

#check if user passed file
filename="$1"
currentLine=1
# '-f'check if the file found or not 
if [[ "$filename" != "" ]] && ! [[ -f "$filename" ]]; then
    echo "$filename does not exists."
    exit 1
fi
# do the program untel the user enter X or read it from file
while [ "$userInput" != "x" ];
do
    if [[ "$filename" == "" ]] ;
    then
        printf "${GREEN}Enter an intger or one of the following commands:${NC}\n"
        echo "+ push a '+' on the stack"
        echo "s push an 's' on the stack"
        echo "e evaluate the top of the stack"
        echo "p print the content of the stack"
        echo "d delete the top of the stack"
        echo "u undo last evaluate"
        echo "x stop and exit the program"
    fi
    echo -n "> "
    
    if [[ "$filename" == "" ]] ;
    then
        read userInput
    else
        #read line into userInput from file
        userInput=$(sed -n ${currentLine}p $filename)
        currentLine=$((currentLine+1))

        if [[ "$userInput" == "" ]] ;
        then
            #to exit the project if the user dont write x in end 
            userInput="x"
        fi
        echo $userInput
    fi
    
    #convert the input to lowercase
    userInput=${userInput,,}


    # check the input to be int or char  
    if [[ "$userInput" =~ ^[0-9]+$ || $userInput == "+" || $userInput == "s" || $userInput == "e" || $userInput == "p" || $userInput == "d" || $userInput == "u" ]] ; 
    then
        stackPush $userInput
    elif [ "$userInput" != "x" ]
    then
        printf "${RED}Invalid input '$userInput'!${NC}\n"
    fi

    if [[ "$(stackTop)" == "u" ]] ; 
    then
        stackPrint
        stackPop
        # check if the evaluate has been called
        if [[ ${#simpleStackBackup[@]} -eq 0 ]] ;
        then
            printf "${RED}Can undo only last eval command!${NC}\n"
        else
            # get last executed command
            lastCommand=${simpleStackBackup[-1]}
            if [[ "$lastCommand" == "e" ]] ;
            then
                unset 'simpleStackBackup[-1]'
                simpleStack=("${simpleStackBackup[@]}")
            else
            echo "$lastCommand"
                printf "${RED}Can undo only eval command!${NC}\n"
            fi
        fi
        stackPrint
    elif [[ "$(stackTop)" == "p" ]] ; 
    then
        stackPrint
        stackPop
        stackPrint
    elif [[ "$(stackTop)" == "e" ]] ; 
    then
        simpleStackBackup=("${simpleStack[@]}")
        stackPrint
        stackPop
        if [[ $(stackSize) -eq 0 ]];
        then
            printf "${RED}Empty stack!${NC}\n"
            continue
        fi
        
        if [[ "$(stackTop)" == "+" ]] ; 
        then
            if [[ $(stackSize) -lt 3 ]];
            then
                printf "${RED}No enough elements to sum!${NC}\n"
                continue
            fi
            stackPop
            
            n1=$(stackTop)
            stackPop
            
            n2=$(stackTop)
            stackPop
            
            if [[ "$n1" =~ ^[0-9]+$ && "$n2" =~ ^[0-9]+$ ]];
            then
                result=$((n1 + n2))
                stackPush $result
            else
                printf "${RED}Operands are not integers!${NC}\n"
                stackPush $n2
                stackPush $n1
                stackPush "+"
            fi
        elif [[ "$(stackTop)" == "s" ]] ; 
        then
            # must have three elemantes to be evaluated
            if [[ $(stackSize) -lt 3 ]];
            then
                printf "${RED}No enough elements to switch!${NC}\n"
                continue
            fi
            stackPop
            #get the elemants to be swappted
            e1=$(stackTop)
            stackPop
            
            e2=$(stackTop)
            stackPop
            
            stackPush $e1
            stackPush $e2
        elif [[ "$(stackTop)" == "d" ]] ; 
        then
            # must have two elemantes to be evaluated
            if [[ $(stackSize) -lt 2 ]];
            then
                printf "${RED}No elements to delete!${NC}\n"
                continue
            fi
            stackPop
            stackPop
        fi
        
        stackPrint
    fi
    
done

