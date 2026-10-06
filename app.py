import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def info():
    return jsonify({
        "status": "healthy",
        "service": "Payment API",
        "metadata": {
            "build_number": os.getenv("BUILD_NUMBER", "local"),
            "git_commit": os.getenv("GIT_COMMIT", "head"),
            "branch": os.getenv("BRANCH_NAME", "main")
        }
    }), 200

if __name__ == '__main__':
    host = os.getenv('HOST', '0.0.0.0')
    port = int(os.getenv('PORT', 8080))
    app.run(host=host, port=port)