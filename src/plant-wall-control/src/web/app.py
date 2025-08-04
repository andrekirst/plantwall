from flask import Flask
from web.routes import setup_routes

app = Flask(__name__)

def create_app():
    setup_routes(app)
    return app

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)