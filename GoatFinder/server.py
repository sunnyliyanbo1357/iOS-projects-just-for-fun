#!/usr/bin/env python

from flask import (Flask, jsonify, make_response, request, abort, send_file,
                   render_template, send_from_directory, redirect, json, url_for)
from random import random
import socket
import time
import calendar
import hashlib
from math import sin, cos, pi
# import json

app = Flask(__name__)

def get_machine_ip():
    return socket.gethostbyname(socket.gethostname())

def get_time():
    return calendar.timegm(time.gmtime())

def str2num(name, n_fields = 2):
    m = hashlib.md5()
    m.update(name)
    name_hash = m.hexdigest()
    
    field_width = len(name_hash) / n_fields
    
    fields = []
    for i in range(n_fields):
        field = name_hash[(i * field_width):((i+1) * field_width)]
        val = float(int(field, 16)) / int('f' * field_width, 16)
        fields.append(val)
        
    return tuple(fields)

def get_pos(name):
    r, theta, v = str2num(name, 3)

    v += 0.01
    v *= 0.3
    theta = theta * 2 * pi

    s = 1.0 / 1000.0
    latitude = 40.7127 + (r * sin(theta + v * get_time())) * s
    longitude = -74.0059 + (r * cos(theta + v * get_time())) * s

    return {'latitude': latitude, 'longitude': longitude}


@app.route('/position/', methods=['GET'])
def get_pos_for_goat():
    print '=' * 80
    goats = request.args.getlist('goats[]')

    goat_locs = {}
    for goat in goats:
        goat_locs[goat] = get_pos(goat)
        print '%-10s lat: %8.5f lon: %8.5f'%(goat.strip(), goat_locs[goat]['latitude'], goat_locs[goat]['longitude'])

    return json.jsonify(goat_locs)

if __name__ == '__main__':

    port = 9000

    print '=' * 80
    print 'http://%s:%d' %(get_machine_ip(), port)
    print '=' * 80

    app.run(port=port, host='0.0.0.0', debug=True)
