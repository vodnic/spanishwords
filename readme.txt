Spanish learner helper (possible all-language-lerner-helper)                 
App shows random word from a file (specified or default one) and prompts     
user to input word in foreign language. User gets feedback if input was     
correct and in both cases he is suppoerted with original word (and possibly) 
example sentences).                                                          

All insertions are logged into file (default: history.txt), and a special
database file (db_errors.csv) that can be used as "retry-your-mistakes".                   
One suppoerted argument is a file containing words.                          
Script is dedicated to run with crontab in hourly schedule.                  

usage 
./run.sh <db_filename.csv> <dont_log>
