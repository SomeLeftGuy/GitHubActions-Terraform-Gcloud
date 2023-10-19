from flask import Flask, render_template
from redis import Redis
import socket

app = Flask(__name__)
redis = Redis(host='localhost', port=6379)


@app.route("/")
def home():
    redis.incr('hits')
    gethits = redis.get('hits')
    hits = gethits.decode('utf-8')
    hostname = socket.gethostname()
    return render_template("index.html", hits=hits, hostname=hostname)


# if __name__ == "__main__":
#     app.run(host='0.0.0.0', debug=True, port=8080)

# docker
if __name__ == "__main__":
    app.run(debug=True)
