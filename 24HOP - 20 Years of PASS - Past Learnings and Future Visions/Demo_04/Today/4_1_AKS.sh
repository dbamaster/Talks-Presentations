# DEMO 4 - Azure Kubernetes services (AKS)
#   0- Pre-requisites
#   1- Connect to Kubernetes cluster in AKS
#   2- Get nodes, pods, services, namespaces
#   3- Check PVC - Matching AK disk with PVC
#   4- Describe deployment
#   5- Check pod events
#   6- Check pod logs
#   7- Show Kubernetes dashboard
#   8- Get public IP of SQL Server service
#   9 Connect to SQL Server
#   10- Upgrade SQL Server (pod image)
#   11- Check rolling upgrade status
#   12- Check rollout history
#
#   Kubernetes cheat sheet:
#   https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# -----------------------------------------------------------------------------

# 0- Pre-requisites
## Check AZ subscription and credentials
  # az account list --output table
  # az account set --subscription "Visual Studio Enterprise"
  # az aks get-credentials --resource-group sqlsaturday-912 --name Endurance
## Create namespace, PVC and deployment
  # kubectl create namespace endurance-sql
  # kubectl config set-context --current --namespace=endurance-sql
  # kubectl create secret generic mssql --from-literal=SA_PASSWORD="_EnDur@nc3_"
  # kubectl apply -f pvc.yaml
  # kubectl apply -f sql-plex.yaml --record

# 1- Connect to Kubernetes cluster in AKS
az aks get-credentials --resource-group sqlsaturday-912 --name Endurance
kubectl config set-context --current --namespace=endurance-sql
kubectl config get-contexts

# 2- Get nodes, pods, services, namespaces
kubectl get nodes
kubectl get namespaces
kubectl get all
kubectl get pods
kubectl get services

# 3- Check PVC - Matching AZ disk with AKS-PVC
kubectl describe pvc mssql-data

# Filter by Volume
kubectl describe pvc mssql-data | grep "Volume:" #  ➡️ Match it with AKS-PVC
# Go to the portal --> All resources --> Look for PVC disk

# 4- Describe deployment
kubectl describe deployment mssql-plex

# 5- Check pod events
MyPod=`kubectl get pods | grep mssql-plex | awk {'print $1'}`
kubectl describe pods $MyPod

# 6- Check pod logs
kubectl logs $MyPod -f

# 7- Show Kubernetes dashboard
az aks browse --resource-group sqlsaturday-912 --name Endurance

# 8- Get public IP of SQL Server service
kubectl get service mssql-plex 
MyService=`kubectl get service mssql-plex | grep mssql-plex | awk {'print $4'}`

# 9- Connect to SQL Server
clear & sqlcmd -S $MyService -U SA -P "_EnDur@nc3_" \
-q "SET NOCOUNT ON;SELECT name FROM sys.databases; \
PRINT''; \
SELECT CONVERT(CHAR,serverproperty('ProductUpdateLevel')) as "CU";"

# 10- Upgrade SQL Server (pod image)
kubectl --record deployment set image mssql-plex mssql=mcr.microsoft.com/mssql/server:2017-CU16-ubuntu

# 11- Check rolling upgrade status
# In terminal 1
kubectl rollout status -w deployment mssql-plex

# In terminal 2
kubectl get pods
NewPod=`kubectl get pods | grep mssql-plex | awk {'print $1'}`
kubectl describe pods $NewPod
kubectl logs $NewPod -f

# 12- Check rollout history
kubectl rollout history deployment mssql-deployment