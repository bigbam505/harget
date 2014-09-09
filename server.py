#!/usr/bin/python

import sys
import json
from bottle import route, run, template, response, error

def make_json_response(obj):
  response.content_type = "application/json"
  return json.dumps(obj)

@route('/api/url', method="GET")
def get_url():
  # we should load and return the url here
  return make_json_response({ 'url': "http://google.com" })

@route('/api/url', method="POST")
def set_url():
  # We should save the url here
  response.status = 202

@error(404)
def mistake_404(code):
  return 'Sorry, this page does not exist!'

def main(argv):
  print 'Number of arguments:', len(argv), 'arguments.'
  print 'Argument List:', str(argv)
  run(host='localhost', port=8080)

if __name__ == "__main__":
  main(sys.argv[1:])
