import os
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1 style='color:blue'>Hello There! It's {}</h1>".format(os.environ.get('HOSTED_WEBAPP'))

if __name__ == "__main__":
    app.run()
