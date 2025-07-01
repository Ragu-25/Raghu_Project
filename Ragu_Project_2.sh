#!/bin/bash

# === CONFIGURATION ===
APP_NAME="ai-kube-app"
NAMESPACE="demo-space"
REPLICAS=3
IMAGE="nginx:alpine"
PORT=8080

# === STEP 1: Install Minikube if needed ===
if ! command -v minikube &>/dev/null; then
  echo "📦 Installing Minikube..."
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm minikube-linux-amd64
fi

# === STEP 2: Start Minikube Cluster ===
echo "🚀 Starting Kubernetes cluster..."
minikube start

# === STEP 3: Define Kubernetes Resources ===
mkdir -p kube_specs
cat <<EOF > kube_specs/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: $IMAGE
        ports:
        - containerPort: 80
EOF

cat <<EOF > kube_specs/service.yml
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME-service
  namespace: $NAMESPACE
spec:
  type: NodePort
  selector:
    app: $APP_NAME
  ports:
    - port: $PORT
      targetPort: 80
      nodePort: 30036
EOF

# === STEP 4: Apply Configuration to Cluster ===
echo "⚙️  Creating namespace and deploying app..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f kube_specs/ -n $NAMESPACE

# === STEP 5: Scale and Monitor ===
echo "📈 Scaling to $REPLICAS replicas..."
kubectl scale deployment/$APP_NAME --replicas=$REPLICAS -n $NAMESPACE

echo "🔍 Monitoring pod status..."
kubectl get pods -n $NAMESPACE -w &
sleep 10
kill $!

# === STEP 6: Access the App ===
echo "🌐 Accessing your application locally..."
minikube service $APP_NAME-service -n $NAMESPACE

echo "✅ Deployment complete. Use kubectl for advanced monitoring or scaling!"
