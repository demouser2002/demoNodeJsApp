#!/bin/bash

since=$1
until=$2

after=null
commitsPushed=0
commitBatchSize=100
hasNextPage="true"

echo '************* Pushing Commits ***************************************'
while [ $hasNextPage = "true" ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -F since=$since  -F until=$until -F  after="$after" -f query='
  query($name: String!, $owner: String!,$since: GitTimestamp!, $until: GitTimestamp!, $after: String){
    repository(owner:$owner, name:$name) {
            defaultBranchRef {
                target {
                    ... on Commit {
                        history(since: $since, until: $until, first: 100, after: $after) {
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
 after=`jq -r '.data.repository.defaultBranchRef.target.history.pageInfo.endCursor' commits.json`
 commitsCount=`jq -r '.data.repository.defaultBranchRef.target.history.totalCount' commits.json`

# Push commits in batches of 100
 if [ $commitsPushed -lt $commitsCount ]; then
    # Calculate the remaining commits
    remainingCommits=$((commitsCount - commitsPushed))
    
    # Determine the number of commits to push in this iteration
    if [ $remainingCommits -lt $commitBatchSize ]; then
        commitBatchSize=$remainingCommits
    fi

    # Simulate pushing commits (replace this with actual push logic if needed)
    echo "Pushing $commitBatchSize commits..."

    # Update the number of commits pushed
    commitsPushed=$((commitsPushed + commitBatchSize))

    # Print progress
    echo "Pushed $commitsPushed out of $commitsCount issues to DevOps Intelligence."
 fi    
 
done

