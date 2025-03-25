#!/usr/bin/env bash


#gh auth login -h github.com -p https --with-token < /Users/kavithasureshkumar/Documents/GitHub_Demo/token.txt

#listing all prs

gh pr list

#listing all issues

gh issue list


gh api graphql -F owner='{owner}' -F name='{repo}' -f query='
  query($name: String!, $owner: String!){
    repository(owner:$owner, name:$name) {
            defaultBranchRef {
                target {
                    ... on Commit {
                        history(since: "2025-01-01T01:01:00", first: 100) {
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
 
