#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_days>"
    exit 1
fi

days=$1
since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
after=""

query='repo:demouser2002/demoNodeJsApp is:pr sort:updated-desc'
echo $query

hasNextPage="true"
while [ $hasNextPage = "true" ]
do
gh api graphql -F after=$after -f query='
query prdetails($after: String) {
	    search(
			first: 100
			query: "repo:demouser2002/demoNodeJsApp is:pr sort:updated-desc"
			type: ISSUE
			after: $after
		) {
			issueCount
			nodes {
				... on PullRequest {
					number
					id
					title
					url
					createdAt
					updatedAt
					fullDatabaseId
					mergedAt
					body
					mergeCommit {
						oid
					}
					additions
					deletions
					changedFiles
					totalCommentsCount
					headRefName
					baseRefName
					state
					author {
						... on User {
							id
							email
							name
							login
						}
					}
					timelineItems(
						first: 50
						after: null
						itemTypes: [ISSUE_COMMENT, PULL_REQUEST_REVIEW, REVIEW_REQUESTED_EVENT]
					) {
						totalCount
						nodes {
							eventType: __typename
							... on ReviewRequestedEvent {
								createdAt
								id
								author: requestedReviewer {
									... on User {
										login
										email
										id
										name
									}
								}
							}
							... on PullRequestReview {
								createdAt
								id
								author {
									... on User {
										id
										login
										email
										name
									}
								}
								state
								body
								comments(
									first: 80
									after: null
								) {
									totalCount
									nodes {
										body
										createdAt
									}
									pageInfo {
										endCursor
										hasNextPage
									}
								}
							}
							... on IssueComment {
							    id
								author {
									... on User {
										id
										login
										email
										name
									}
								}
								body
								createdAt
							}
						}
						pageInfo {
							endCursor
							hasNextPage
						}
					}
					closedAt
					commits(first: 100, after: null) {
						totalCount
						nodes {
							commit {
								authoredDate
								changedFilesIfAvailable
								additions
								deletions
								id
								message
								oid
								pushedDate
								resourcePath
								commitUrl
								committedDate
								author {
									user {
										email
										id
										login
										name
									}
								}
							}
						}
						pageInfo {
							endCursor
							hasNextPage
						}
					}
				}
			}
			pageInfo {
				endCursor
				hasNextPage
			}
		}
	}'> prs.json

 hasNextPage=`jq -r '.data.search.pageInfo.hasNextPage' prs.json`
 echo $hasNextPage
 after=`jq -r '.data.search.pageInfo.endCursor' prs.json`
 echo $after 
done
