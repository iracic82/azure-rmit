#!/bin/bash
set -euxo pipefail

# --- Install Docker ---
apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# --- Create welcome page ---
mkdir -p /opt/web

cat > /opt/web/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RMIT POC Lab - Infoblox</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0078d4 0%, #00356b 50%, #001a33 100%);
            color: #ffffff;
        }
        .container {
            text-align: center;
            padding: 40px;
            max-width: 800px;
        }
        .card {
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        h1 {
            font-size: 2.8em;
            margin-bottom: 10px;
            background: linear-gradient(90deg, #50e6ff, #0078d4, #b4a0ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .subtitle {
            font-size: 1.2em;
            color: rgba(255, 255, 255, 0.7);
            margin-bottom: 40px;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-top: 30px;
        }
        .info-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 20px;
            transition: transform 0.3s, border-color 0.3s;
        }
        .info-card:hover {
            transform: translateY(-3px);
            border-color: rgba(80, 230, 255, 0.4);
        }
        .info-card .icon { font-size: 2em; margin-bottom: 10px; }
        .info-card .label {
            font-size: 0.85em;
            color: rgba(255, 255, 255, 0.5);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        .info-card .value {
            font-size: 1.1em;
            color: #50e6ff;
        }
        .badge {
            margin-top: 40px;
            display: inline-block;
            padding: 8px 24px;
            background: rgba(80, 230, 255, 0.15);
            border: 1px solid rgba(80, 230, 255, 0.3);
            border-radius: 30px;
            font-size: 0.9em;
            color: #50e6ff;
            letter-spacing: 1px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>Welcome to RMIT POC Lab</h1>
            <p class="subtitle">Infoblox &mdash; Universal Asset Insights</p>
            <div class="info-grid">
                <div class="info-card">
                    <div class="icon">&#9729;</div>
                    <div class="label">Platform</div>
                    <div class="value">Microsoft Azure</div>
                </div>
                <div class="info-card">
                    <div class="icon">&#128230;</div>
                    <div class="label">Container</div>
                    <div class="value">Docker + Nginx</div>
                </div>
                <div class="info-card">
                    <div class="icon">&#127760;</div>
                    <div class="label">DNS</div>
                    <div class="value">Azure Private DNS</div>
                </div>
                <div class="info-card">
                    <div class="icon">&#9881;</div>
                    <div class="label">Automation</div>
                    <div class="value">Terraform IaC</div>
                </div>
            </div>
            <div class="badge">Powered by Infoblox</div>
        </div>
    </div>
</body>
</html>
HTMLEOF

# --- Run nginx container serving the welcome page ---
docker run -d \
  --name web \
  --restart always \
  -p 80:80 \
  -v /opt/web:/usr/share/nginx/html:ro \
  nginx:alpine
