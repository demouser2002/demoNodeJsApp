
#!/bin/bash

#listing all prs

gh pr list

#listing all issues

gh issue list

start_date="2025-01-01T01:01:00Z"
end_date="2025-03-01T01:01:00Z"

gh api graphql -F owner='{owner}' -F name='{repo}' -F start_date="2025-01-01T01:01:00Z" -f query='
  query($name: String!, $owner: String!,$start_date: GitTimestamp!){
    repository(owner:$owner, name:$name) {
            defaultBranchRef {
                target {
                    ... on Commit {
                        history(since: $start_date, first: 100) {
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
 
