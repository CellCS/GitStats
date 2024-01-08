#!/bin/sh


# default sincedate is 1st commit date, default untildate is Today
# sh gitstats.sh

# "sh gitstats.sh sincedate untildate"
# sh gitstats.sh 2023-08-21 2023-09-21

# default untildate is Today
# "sh gitstats.sh sincedate"
# sh gitstats.sh 2023-09-21

function days_between {
    local start_timestamp="$1"
    local end_timestamp="$2"
    
    local seconds_diff=$((end_timestamp - start_timestamp))
    local days_diff=$((seconds_diff / 86400))  # 86400 seconds in a day
    
    echo "$days_diff"
}
#
first_commit_hash=$(git rev-list --max-parents=0 HEAD)
last_commit_hash=$(git rev-parse HEAD)
start_timestamp=$(git log -n 1 --pretty=format:%ct "$first_commit_hash")
end_timestamp=$(git log -n 1 --pretty=format:%ct "$last_commit_hash")
days_diff=$(days_between "$start_timestamp" "$end_timestamp")
first_commit_date=$(git log -n 1 --pretty=format:%ci --date=format-local:"%Y-%m-%d" "$first_commit_hash")
last_commit_date=$(git log -n 1 --pretty=format:%ci --date=format-local:"%Y-%m-%d" "$last_commit_hash")

# Parse command line arguments
start_date="$1"
end_date="$2"

if [ -n "$start_date" ]; then
  stats_start_timestamp=$(date -jf "%Y-%m-%d" "$start_date" "+%s")
  stats_start_date=$(date -jf "%s" "$stats_start_timestamp" "+%Y-%m-%d")
  stats_start_date_str=$stats_start_date
else
  stats_start_timestamp=$start_timestamp  # If no start date provided, set start as first commit time
  stats_start_date=$(date -jf "%s" "$stats_start_timestamp" "+%Y-%m-%d")
  stats_start_date_str=$stats_start_date
fi

if [ -n "$end_date" ]; then
  stats_end_timestamp=$(date -jf "%Y-%m-%d" "$end_date" "+%s")
  stats_end_date=$(date -jf "%s" "$stats_end_timestamp" "+%Y-%m-%d")
  stats_end_date_str=$stats_end_date
else
  stats_end_timestamp=$(date +%s)  # If no end date provided, set to today's date
  stats_end_date=$(date -jf "%s" "$stats_end_timestamp" "+%Y-%m-%d")
  stats_end_date_str=$stats_end_date
fi

# Rest of your existing script

# Display the date range information
echo "Setting: Start Date: $stats_start_date_str"
echo "Setting: End Date: $stats_end_date_str"


echo "======Total Code Lines Tracked By Git: ============"
git ls-files | xargs git log --since=$stats_start_date_str --until=$stats_end_date_str --format=format: --name-only | sort -u | xargs cat | wc -l
echo "======Total Code Stats By Git: ============"
git log --shortstat --no-merges --since=$stats_start_date_str --until=$stats_end_date_str | grep -E "fil(e|es) changed" | awk '{files+=$1; inserted+=$4; deleted+=$6; delta+=$4-$6; ratio=deleted/inserted} END {printf "- Files changed (total)..  %s\n- Lines added (total)....  %s\n- Lines deleted (total)..  %s\n- Total lines (delta)....  %s\n- Add./Del. ratio (1:n)..  1 : %s\n", files, inserted, deleted, delta, ratio }' -

echo "======Contributors============"
git shortlog -sn --no-merges --since=$stats_start_date_str --until=$stats_end_date_str

IFS=$'\n' read -r -d '' -a commitauthors <<< "$(git log --since=$stats_start_date_str --until=$stats_end_date_str --format='%aN' | sort -u)"
echo "======Git Stats============"
for commitauthor in "${commitauthors[@]}"; do
	echo $commitauthor
	#git log --author="$commitauthor" --pretty=tformat: --numstat | awk '{inserted+=$1; deleted+=$2; delta+=$1-$2; ratio=deleted/inserted} END {printf " Commit stats:\n- Lines added (total)....  %s\n- Lines deleted (total)..  %s\n- Total lines (delta)....  %s\n- Add./Del. ratio (1:n)..  1 : %s\n", inserted, deleted, delta, ratio }' -
    git log --shortstat --no-merges --since=$stats_start_date_str --until=$stats_end_date_str --author="$commitauthor" | grep -E "fil(e|es) changed" | awk '{files+=$1; inserted+=$4; deleted+=$6; delta+=$4-$6; ratio=deleted/inserted} END {printf "- Files changed (total)..  %s\n- Lines added (total)....  %s\n- Lines deleted (total)..  %s\n- Total lines (delta)....  %s\n- Add./Del. ratio (1:n)..  1 : %s\n", files, inserted, deleted, delta, ratio }' -
    echo ""
done

echo "======Project First commit and recent commit date, and total cost days till now============"
first_commit_hash=$(git rev-list --max-parents=0 HEAD)
last_commit_hash=$(git rev-parse HEAD)
start_timestamp=$(git log -n 1 --pretty=format:%ct "$first_commit_hash")
end_timestamp=$(git log -n 1 --pretty=format:%ct "$last_commit_hash")
days_diff=$(days_between "$start_timestamp" "$end_timestamp")
first_commit_date=$(git log -n 1 --pretty=format:%ci --date=format-local:"%Y-%m-%d" "$first_commit_hash")
last_commit_date=$(git log -n 1 --pretty=format:%ci --date=format-local:"%Y-%m-%d" "$last_commit_hash")
echo "Create project date: $first_commit_date"
echo "Last commit date: $last_commit_date"
echo "Total Days: $days_diff days"
