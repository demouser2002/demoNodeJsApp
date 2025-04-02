#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_days>"
    exit 1
fi

days=$1
since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
after=""
states=[AUTO_DISMISSED, DISMISSED, OPEN, FIXED]
hasNextPage="true"
while [ $hasNextPage = "true"  ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -F states=$states -f query='
query {
		repository(owner:{owner}, name:{repo}) 
		{
			vulnerabilityAlerts(last:100, states:$states ) 
			{      
				pageInfo 
				{        
					endCursor        
					hasNextPage        
					startCursor
					hasPreviousPage      
				}      
				totalCount      
				nodes 
				{        
					id  
					autoDismissedAt
					createdAt
					dismissReason
					dismissedAt
					state
					fixedAt
					vulnerableManifestPath
					dismisser {
						email
						name
						login
					}
					securityAdvisory {
						id
						cvss {
							score
						}
						ghsaId
						severity
						summary
						notificationsPermalink
						permalink
						publishedAt
						origin
						identifiers
						{
							type: value
						}
						updatedAt
						description
					}
					securityVulnerability 
					{
						firstPatchedVersion {
							identifier
						}
						package
						{
							ecosystem
							name
						}
						vulnerableVersionRange
						updatedAt
					}
				}
			}
		}
	}'> alerts.json

 hasNextPage=`jq -r '.data.repository.vulnerabilityAlerts.pageInfo.hasNextPage' alerts.json`
 echo $hasNextPage
 after=`jq -r '.data.repository.vulnerabilityAlerts.pageInfo.endCursor' alerts.json`
 echo $after 
done
