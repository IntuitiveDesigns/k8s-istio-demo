apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: python:3.11-slim
          command: ["python", "-u", "/app/app.py"]
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: app
              mountPath: /app
      volumes:
        - name: app
          configMap:
            name: frontend-code
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-code
  namespace: demo
data:
  app.py: |
    from flask import Flask
    import urllib.request

    app = Flask(__name__)
    BACKEND_URL = "http://backend.demo.svc.cluster.local:5000/"

    @app.get("/")
    def index():
        with urllib.request.urlopen(BACKEND_URL) as r:
            body = r.read().decode("utf-8")
        return f"Frontend received -> {body}"

    app.run(host="0.0.0.0", port=8080)
