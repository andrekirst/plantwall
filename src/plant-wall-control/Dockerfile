FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y gcc zlib1g-dev libjpeg-dev && rm -rf /var/lib/apt/lists/*
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "src/web/app.py"]
