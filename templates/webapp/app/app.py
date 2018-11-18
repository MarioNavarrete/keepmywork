# UI for Avantio information export

import os

from flask import Flask, redirect, url_for, session, request, render_template, make_response
from flask_oauthlib.client import OAuth
from oauth2client.client import GoogleCredentials, OAuth2WebServerFlow
from apiclient import discovery
import httplib2
import pandas as pd
import numpy as np

from apiclient import discovery, errors
from oauth2client import client
from keepmywork import Creds

app = Flask(__name__)
app.debug = True
app.secret_key = Creds.load('app').secret_key

@app.route('/', methods=['GET', 'POST'])
def index():
    try:
        if 'credentials' not in session:
            return redirect(url_for('login'))

        credentials = client.OAuth2Credentials.from_json(session['credentials'])
        if credentials.access_token_expired:
            return redirect(url_for('login'))

        return render_template('index.html')            
    except:
        raise

@app.route('/login')
def login():
    creds = Creds.load('o2a')
    flow = OAuth2WebServerFlow(
        client_id = creds.client_id,
        client_secret = creds.client_secret,
        scope=['https://www.googleapis.com/auth/drive','https://spreadsheets.google.com/feeds'],
        redirect_uri=url_for('login', _external=True)
    )
    if 'code' not in request.args:
        auth_uri = flow.step1_get_authorize_url()
        return redirect(auth_uri)
    else:
        auth_code = request.args.get('code')
        credentials = flow.step2_exchange(auth_code)
        session['credentials'] = credentials.to_json()
        return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.pop('session', None)
    return render_template('logout.html')

