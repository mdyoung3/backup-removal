#!/usr/bin/env bash
#Bash script to remove backups that were synced from production to QA.
#By Marc Young
#Aug 16, 2018

#Daily backup management
BACKUPS_PATH=/root/backups
THRESHOLD=$(date -d "0 days ago" +%Y-%m-%d)

find ${BACKUPS_PATH} -maxdepth 1 -type d -print0  | while IFS= read -d '' -r dir
do
BASE="$(basename "$dir")"
 if [[ "$BASE" =~ ^[0-9]{4}\-[0-9]{2}\-[0-9]{2} ]]; then
    if [[ "$BASE" < "$THRESHOLD" ]]; then
	rm -r "$dir"
    fi 
  fi 
done

#Weekly management
THRESHOLD=$(date -d "7 days ago" +%Y-%m-%d)
WEEKLY_BACKUPS_PATH=/root/backups/weekly

find ${WEEKLY_BACKUPS_PATH} -maxdepth 1 -type d -print0  | while IFS= read -d '' -r weekly
do
WEEKLY_BASE="$(basename "$weekly")"
 if [[ "$WEEKLY_BASE" =~ ^[0-9]{4}\-[0-9]{2}\-[0-9]{2} ]]; then
    if [[ "$WEEKLY_BASE" < "$THRESHOLD" ]]; then
	rsync -av -e "ssh -i /root/.ssh/id_rsa_backup" $weekly root@research-prod.rtd.asu.edu:/backup/production-backups/weekly
	rm -r "$weekly"
    fi
  fi
done

#monthly management
THRESHOLD=$(date -d "33 days ago" +%Y-%m-%d)
MONTLY_BACKUPS_PATH=/root/backups/monthly

find ${WEEKLY_BACKUPS_PATH} -maxdepth 1 -type d -print0  | while IFS= read -d '' -r monthly_dir
do
MONTHLY_BASE="$(basename "$monthly_dir")"
 if [[ "$MONTHLY_BASE" =~ ^[0-9]{4}\-[0-9]{2}\-[0-9]{2} ]]; then
    if [[ "$MONTHLY_BASE" < "$THRESHOLD" ]]; then
       # rsync -av -e "ssh -i /root/.ssh/id_rsa_backup" $weekly root@research-prod.rtd.asu.edu:/backup/production-backups/monthly
       # rm -r "$monthly_dir"
	echo $monthly_dir
    fi
  fi
done
