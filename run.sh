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
# eng_word<tab>spa_word<tab>eng_examp(optional)<tab>spa_examp(optional)<\n>
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

# Link to wider description on wiktionary or google translate.
# TODO: Case with mixed two definitions, one singleword, and second mulitword
#       and/or one with article and second not.
preapreLink () {
    LINK="http://en.wiktionary.org/wiki/$SPANISH_WORD#Spanish"
    if [ "$ARTICLE" != "" ]; then
        LINK="http://en.wiktionary.org/wiki/${SPANISH_WORD:$ARTICLE_LENGTH}#Spanish"
    fi

    WORD_COUNT=$(echo $SPANISH_WORD | wc -w)
    if [ "$ARTICLE" != "" ] && [ $WORD_COUNT -gt 2 ]; then
        LINK="https://translate.google.pl/?hl=pl#es/en/$SPANISH_WORD"
    fi
    if [ "$ARTICLE" == "" ] && [ $WORD_COUNT -gt 1 ]; then
        LINK="https://translate.google.pl/?hl=pl#es/en/$SPANISH_WORD"
    fi
    if [ "$SPANISH_SECOND" != "" ]; then
        LINK="http://en.wiktionary.org/wiki/$SPANISH_SECOND#Spanish"
    fi
}

# Prompt for word in spanish and verifies its correctness.
# TODO: Case with mixed two definitions, one singleword, and second mulitword
#       and/or one with article and second not.
readAndVerifyWord () {
    DATE=$(date "+%Y-%m-%d %H:%M:%S")

    if [[ "$SPANISH_WORD" == *"/"* ]]; then
        SPANISH_FIRST=$(echo "$SPANISH_WORD" | cut -d"/" -f 1)
        SPANISH_SECOND=$(echo "$SPANISH_WORD" | cut -d'/' -f 2)
    fi

    INPUT=$(zenity --entry \
        --text="$ENGLISH_WORD $ARTICLE" \
        --title="Learn a word!")

    if [ "$SPANISH_SECOND" != "" ]; then
        if [ "$INPUT" == "$SPANISH_FIRST" ] || [ $INPUT == "$SPANISH_SECOND" ]; then
            TYPE="info"
            STATUS="Correct!"
            LOG="[CORR-$DATE] $SPANISH_WORD, $ENGLISH_WORD,"
        fi
    fi
    
    if [ "$INPUT" == "$SPANISH_WORD" ]; then
        TYPE="info"
        STATUS="Correct!"
        LOG="[CORR-$DATE] $SPANISH_WORD, $ENGLISH_WORD,"
    fi
    
    if [ "$TYPE" == "" ]; then
        TYPE="error"
        STATUS="Wrong!"
        LOG="[ERR!-$DATE] $SPANISH_WORD, $ENGLISH_WORD, $INPUT"

        ERROR_ENTRY="$ENGLISH_WORD\t$SPANISH_WORD\t$ENGLISH_EXAMPLE\t$SPANISH_EXAMPLE" 
        ERROR_DB=$(echo "$ERROR_ENTRY" | sed -r 's/ /_/g')
        echo -e "$ERROR_DB" >> db_errors.csv
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

