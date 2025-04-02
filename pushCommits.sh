#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_days>"
    exit 1
fi

days=$1
since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
after=null

hasNextPage=true
while [ $hasNextPage ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -F since=$since -F after="$after" -f query='
  query($name: String!, $owner: String!,$since: GitTimestamp!, $after: String){
    repository(owner:$owner, name:$name) {
            defaultBranchRef {
                target {
                    ... on Commit {
                        history(since: $since, first: 2, after: $after) {
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
                                parents(first: 2) {
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

 echo `cat commits.json`
 hasNextPage=`jq -r '.data.repository.defaultBranchRef.target.history.pageInfo.hasNextPage' commits.json`
 after=`jq '.data.repository.defaultBranchRef.target.history.pageInfo.endCursor' commits.json`
 echo $after
done
