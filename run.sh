#!/bin/bash

################################################################################
# Spanish learner helper (possible all-language-lerner-helper)                 #
# App shows random word from a file (specified or default one) and prompts     #
# user to input word in foreign language. User gets feedback if input was      #
# correct and in both cases he is suppoerted with original word (and possibly) #
# example sentences).                                                          #
# All inertions are logged into file (default: history.txt).                   #
# One suppoerted argument is a file containing words.                          #
# Script is dedicated to run with crontat in hourly schedule.                  #
#                                                                              #
# przemek@videveritatis.pl                                                     #
# 2015.06.22 vodnic                                                            #
################################################################################
# Input file's format:
# spa_word<tab>eng_word<tab>spanish_examp(optional)<tab>eng_examp(optional)<\n>
# Spaces should be replaced with underscore (_) character.
# In two or more translations, they should be seperated with slash (/) 
# character without spaces before and after.
# In case of articles, use only definded ones (la/el/las/los).
################################################################################

# Rewrite arguments from file to handy variables.
processArguments () {
    ENGLISH_WORD=$(echo $1 | sed -r 's/_/ /g')
    SPANISH_WORD=$(echo $2 | sed -r 's/_/ /g')
    ENGLISH_EXAMPLE=$(echo $3 | sed -r 's/_/ /g')
    SPANISH_EXAMPLE=$(echo $4 | sed -r 's/_/ /g')
}

# Treat sources with and without articles as with same format.
checkArticle () {
    ARTICLE=""
    if [[ $1 == la_* ]] || [[ $1 == el_* ]]; then
        ARTICLE="*"
        ARTICLE_LENGTH=3
    fi
    if [[ $1 == las_* ]] || [[ $1 == los_* ]]; then
        ARTICLE="*"
        ARTICLE_LENGTH=4
    fi
}

# Link to wider description on wiktionary.
# TODO: In case of multiword content, redirect to google translete instead 
#       of wiktionary.
preapreLink () {
    LINK="http://en.wiktionary.org/wiki/$SPANISH_WORD#Spanish"
    if [ "$ARTICLE" != "" ]; then
        LINK="http://en.wiktionary.org/wiki/${SPANISH_WORD:$ARTICLE_LENGTH}#Spanish"
    fi
}

# Prompt for word in spanish and verifies its correctness.
# TODO: In case of multiple correct answers, assume that they are seperated
#       with slash character (/) and accept any of them.
readAndVerifyWord () {
    DATE=$(date "+%Y-%m-%d %H:%M:%S")

    INPUT=$(zenity --entry \
        --text="$ENGLISH_WORD $ARTICLE" \
        --title="Learn a word!")

    if [ "$INPUT" = "$SPANISH_WORD" ]; then
        TYPE="info"
        STATUS="Correct!"
        LOG="[CORR-$DATE] $SPANISH_WORD"
    else
        TYPE="error"
        STATUS="Wrong!"
        LOG="[ERR!-$DATE] $SPANISH_WORD, $INPUT"
    fi

    echo $LOG >> history.txt
}

# Prepare text for a final message box.
prepareText () {
    MAIN_TEXT="<span size=\"xx-large\"><a href='$LINK'>$SPANISH_WORD</a></span>\n$ENGLISH_WORD"
    if [ "$ENGLISH_EXAMPLE" != "" ]; then
        EXAMPLES="\n\n<i>$ENGLISH_EXAMPLE\n$SPANISH_EXAMPLE</i>"
    fi
    TEXT=$MAIN_TEXT$EXAMPLES
}

# Final step.
showFinalBox () {
    zenity \
        --$TYPE \
        --text="$TEXT" \
        --title="$STATUS" \
        --ok-label="Got It!"
}

# Here happens whole magic.
main () {
    processArguments $1 $2 $3 $4
    checkArticle $2
    
    readAndVerifyWord
    preapreLink
    prepareText

    showFinalBox
}

################################################################################

# App start - read file with words and go to main() func.
# NOTE: all possible errors are ignored because of spam caused by zenity 
#       probelms with GTK config. In case of debugging necesity, remove
#       dev null destination at will. 

FILE=$1
if [ "$FILE" == "" ]; then
    FILE="maindb.csv"
fi

LINE="$(sort --random-sort $FILE | head -n 1)"

#main $LINE 2>/dev/null
main $LINE

################################################################################

