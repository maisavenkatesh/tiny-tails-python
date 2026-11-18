from pathlib import Path

from flask import Flask, jsonify, send_from_directory


APP_DIR = Path(__file__).resolve().parent
app = Flask(__name__, static_folder=str(APP_DIR / "assets"), static_url_path="/assets")


@app.get("/")
def home():
    return send_from_directory(APP_DIR, "index.html")


@app.get("/manifest.webmanifest")
def manifest():
    return send_from_directory(APP_DIR, "manifest.webmanifest")


@app.get("/service-worker.js")
def service_worker():
    response = send_from_directory(APP_DIR, "service-worker.js")
    response.headers["Cache-Control"] = "no-cache"
    return response


@app.get("/health")
def health():
    return jsonify(status="ok")
