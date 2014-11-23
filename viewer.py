import sh
import sys
import json
import yaml
import logging
import os.path
from time import sleep, time
from os import path, getenv
from signal import signal, SIGUSR1, SIGUSR2

BLANK_PAGE = "file:///var/harget/html/blank.html"
SLEEP_TIME = 2
current_browser_url = None
browser = None
config_file = 'service.yaml'
HOME = getenv("HOME","/home/pi")
config = None

def dummy_function(signum, frame):
  """this is stupid"""

def json_parse(obj):
  return json.loads(obj)

def set_logging_level():
  logging.getLogger().setLevel(logging.DEBUG)

def load_config():
  global config
  if(os.path.isfile(config_file)):
    f = open(config_file)
    config = yaml.safe_load(f)
    f.close()

def browser_send(command, cb=lambda _: True):
  if not (browser is None) and browser.process.alive:
    while not browser.process._pipe_queue.empty():  # flush stdout
      browser.next()

  browser.process.stdin.put(command + '\n')
  while True:  # loop until cb returns True
    if cb(browser.next()):
      break
    else:
      logging.info('browser found dead, restarting')
      load_browser()

def load_browser(url=None):
  global browser, current_browser_url
  logging.info('Loading browser...')

  if browser:
    logging.info('killing previous uzbl %s', browser.pid)
    browser.process.kill()

  if not url is None:
    current_browser_url = url

    # --config=-       read commands (and config) from stdin
    # --print-events   print events to stdout
    browser = sh.Command('uzbl-browser')(print_events=True, config='-', uri=current_browser_url, _bg=True)
    logging.info('Browser loading %s. Running as PID %s.', current_browser_url, browser.pid)

    uzbl_rc = 'set ssl_verify = {}\n'.format('1')
    with open(HOME + "/.uzbl.rc") as f:  # load uzbl.rc
      uzbl_rc = f.read() + uzbl_rc
    browser_send(uzbl_rc)

def update_browser_url(url, cb=lambda _: True):
  if not (browser is None) and browser.process.alive:
    browser_send('uri ' + url, cb=cb)
  else:
    logging.debug('Have to restart the browser')
    load_browser(url)

def change_url(url):
  global current_browser_url
  current_browser_url = url
  logging.debug('Changing to ' + url)

  return url

def get_next_url():
  url_object = None
  url_file_path = config['url_location']
  if(not os.path.isdir(os.path.dirname(url_file_path))):
    os.makedirs(os.path.dirname(url_file_path))

  if(os.path.isfile(url_file_path)):
    f = open(url_file_path, 'r')
    url_object = json_parse(f.read())

  if(url_object != None and url_object['url'] != ""):
    return url_object['url']

  return BLANK_PAGE

def screen_refresh_loop():
  global current_browser_url
  next_url = get_next_url()

  if(next_url !=  current_browser_url):
    update_browser_url(change_url(next_url))

  sleep(SLEEP_TIME)

def setup():
  logging.debug('Lets setup first')
  load_config()
  set_logging_level()

  # this handles the input from the autostart
  signal(SIGUSR1, dummy_function)

def main(argv):
  global config_file

  if(len(argv) > 0):
    config_file = argv[0]

  setup()

  if(not config or config == None):
    logging.error('Not config loaded, please add a config file')
    logging.error('Usage: python viewer.py service.yaml')
    return

  logging.debug('Everything appears to be correct, lets begin')

  load_browser(url=BLANK_PAGE)
  while True:
    screen_refresh_loop()

if __name__ == "__main__":
  main(sys.argv[1:])
