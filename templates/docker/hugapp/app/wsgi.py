import hug, os

HUG_API = hug.API(__name__)

@hug.get("/", output=hug.output_format.html)
def hello():
    return "<h1 style='color:blue'>Hello There! It's {}</h1>".format(os.environ.get('HOSTED_WEBAPP'))

