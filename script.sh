
#!/bin/bash
# Script to fetch GitHub issues using GitHub CLI and GraphQL API with date filtering

# Define the GraphQL query
read -r -d '' QUERY << EOF
query(\$startDate: DateTime, \$endDate: DateTime) {
  repository(owner: $owner, name: $repo) {
    issues(first: 10, states: OPEN, filterBy: {since: \$startDate}) {
      edges {
        node {
          title
          number
          url
          createdAt
        }
      }
    }
  }
}
EOF

# Replace OWNER_NAME and REPO_NAME with your repository details
#OWNER_NAME="kavithasureshkumar"
#REPO_NAME="dash_git"

# Define start and end dates
START_DATE="2023-01-01T00:00:00Z" # Replace with your desired start date
END_DATE="2023-12-31T23:59:59Z" # Replace with your desired end date

# Execute the GraphQL query using GitHub CLI
gh api graphql -F query="$QUERY" -F startDate="$START_DATE" -F endDate="$END_DATE" | jq


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
 
