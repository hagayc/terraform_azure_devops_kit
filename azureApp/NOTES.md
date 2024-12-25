## ToDo list
1. Move deployment to seperate git repo 
2. create helm charts
3. implement ArgoCD for pure GitOps approach
4. Secure the system (Dump self signed certs, Take out all passwords and implement vault)
5. add a pipeline stage for both SAST and SCA analysis
6. Add a stage for unit testing + E2E
7. Integrate prometheus and ELK Stack 
8. Work with shortCommit & version in docker tag
9. save terraform backend state in Azure S3 style bucket
10. replace hardCoded parameters (host names etc) with dynamic params
### Connect AKS to ACR (Enable k8s to pull images)
```
az aks update -n devcluster -g azuredevresourcegroup --attach-acr azurewarehouse
```
### Generate passy hash and recreate secret
```
echo -n 'YourStrong@Passw0rd' | base64
```
### output:
```
WW91clN0cm9uZ0BQYXNzdzByZA==
```
### Edit the *secret.yaml and apply new yaml

### Recreate DB connection string and followed secret
```
Server=$DB_SERVICE_SERVICE_HOST,1433;Database=RestaurantDB;User Id=sa;Password='YourStrong@Passw0rd';
```
###
# Rolling out fresh "latest"
kubectl rollout restart deployment db-deployment -n default && \
kubectl rollout restart deployment frontend-deployment -n default && \
kubectl rollout restart deployment api-deployment -n default

###
Examples for getting the json format directly from the API service:
# Get counter
```
curl -k https://api-service:8443/request-stats
```
# Get rest info 
```
curl -k -X POST https://api-service:8443/recommend \
-H "Content-Type: application/json" \
-d '{"style": "Chinese", "vegetarian": false}'
```
# Search for one..
```
curl -k -X POST https://api-service:8443/recommend \
-H "Content-Type: application/json" \
-d '{"style": "Indian", "vegetarian": false}'
```
