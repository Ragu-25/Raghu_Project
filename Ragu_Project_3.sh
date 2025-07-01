#!/bin/bash

# === CONFIGURATION ===
APP_NAME="simple-docker-webapp"
DOCKERFILE_NAME="Dockerfile"
PORT=5000

# === STEP 1: Check if Docker is installed ===
if ! command -v docker &> /dev/null; then
  echo "🐳 Installing Docker..."
  sudo apt update
  sudo apt install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
  echo "✅ Docker installed. Please logout and log back in before running this script again."
  exit 0
fi

# === STEP 2: Set up Python web app ===
echo "📁 Setting up Python app..."
mkdir -p $APP_NAME && cd $APP_NAME

cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "🚀 Hello from inside a container!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=$PORT)
EOF

cat <<EOF > requirements.txt
flask
EOF

# === STEP 3: Create Dockerfile ===
echo "🐋 Writing Dockerfile..."
cat <<EOF > $DOCKERFILE_NAME
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
EOF

# === STEP 4: Build Docker Image ===
echo "🔨 Building Docker image..."
docker build -t $APP_NAME .

# === STEP 5: Run the Container ===
echo "🚀 Running the container..."
docker run -d -p $PORT:$PORT --name "$APP_NAME-instance" $APP_NAME

# === STEP 6: Test the App ===
echo "🌐 Testing app at http://localhost:$PORT"
sleep 2
curl http://localhost:$PORT
