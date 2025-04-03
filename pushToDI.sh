
#!/usr/bash

DAYS=${DAYS:-30}
echo $DAYS

if [ $# = 0 ]; then
    ISSUES="true"
    COMMITS="true"
    PULLREQUESTS="true"
elif [ $# > 0 ]; then
    for type in "$@"
    do
        case "$type" in
            issues) ISSUES="true";;
            commits) COMMITS="true";;
            pullrequests) PULLREQUESTS="true";;
        esac
    done
fi

if [ "$ISSUES" = "true" ]; then
    sh pushIssues.sh $DAYS
     echo "Issues pushed to DevOps Intelligence"
fi

if [ "$COMMITS" = "true" ]; then
    sh pushCommits.sh $DAYS
     echo "Commits pushed to DevOps Intelligence"
fi

if [ "$PULLREQUESTS" = "true" ]; then
    sh pushPRDetails.sh $DAYS
     echo "Issues pushed to DevOps Intelligence"
fi

