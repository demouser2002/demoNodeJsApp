#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_days>"
    exit 1
fi

days=$1
since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
after=null
commits_pushed=0
hasNextPage="true"
while [ $hasNextPage = "true" ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -F since=$since -F  after="$after" -f query='
  query($name: String!, $owner: String!,$since: GitTimestamp!, $after: String){
    repository(owner:$owner, name:$name) {
            defaultBranchRef {
                target {
                    ... on Commit {
                        history(since: $since, first: 100, after: $after) {
                            totalCount
                            nodes {
                                additions
                                deletions
                                author {
                                    email
                                    user {
                                        login
                                        id
                                        name
                                    }
                                }
                                id
                                message
                                oid
                                parents(first: 100) {
                                    nodes {
                                        oid
                                    }
                                }
                                authoredDate
                                changedFilesIfAvailable
                                commitUrl
                            }
                            pageInfo {
                                endCursor
                                hasNextPage
                            }
                        }
                    }
                }
            }
        }
    }' > commits.json
 
 hasNextPage=`jq -r '.data.repository.defaultBranchRef.target.history.pageInfo.hasNextPage' commits.json`
 echo 'Has NextPage:' $hasNextPage
 after=`jq -r '.data.repository.defaultBranchRef.target.history.pageInfo.endCursor' commits.json`
 echo 'End Cursor:' $after

 commitCount=`jq -r '.data.repository.defaultBranchRef.target.history.totalCount' commits.json`

batch_size=100

# Push commits in batches of 100
if [ $commits_pushed -lt $commitCount ]; then
    # Calculate the remaining commits
    remaining_commits=$((commitCount - commits_pushed))
    
    # Determine the number of commits to push in this iteration
    if [ $remaining_commits -lt $batch_size ]; then
        batch_size=$remaining_commits
    fi

    # Simulate pushing commits (replace this with actual push logic if needed)
    echo "Pushing $batch_size commits..."

    # Update the number of commits pushed
    commits_pushed=$((commits_pushed + batch_size))

    # Print progress
    echo "Pushed $commits_pushed out of $commitCount commits."
 fi    
done
