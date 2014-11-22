# -*- coding: utf-8 -*-
import sys
import logging
from logging import handlers
import os, os.path

import cherrypy
from cherrypy import _cplogging
from cherrypy.lib import httputil

class Server(object):
  def __init__(self, options):
    self.base_dir = os.path.normpath(os.path.abspath(options.basedir))

    self.conf_path = os.path.join(self.base_dir, "conf")

    log_dir = os.path.join(self.base_dir, "logs")
    if not os.path.exists(log_dir):
      os.mkdir(log_dir)

    cherrypy.config.update(os.path.join(self.conf_path, "server.cfg"))

    engine = cherrypy.engine

    sys.path.insert(0, self.base_dir)

    from webapp.app import DisneyWaitTimeGraph
    webapp = DisneyWaitTimeGraph()
    app = cherrypy.tree.mount(webapp, '/', os.path.join(self.conf_path, "app.cfg"))


  def run(self):
    from cherrypy._cpnative_server import CPHTTPServer
    cherrypy.server.httpserver = CPHTTPServer(cherrypy.server)

    engine = cherrypy.engine

    if hasattr(engine, "signal_handler"):
      engine.signal_handler.subscribe()

    if hasattr(engine, "console_control_handler"):
      engine.console_control_handler.subscribe()

    engine.start()

    engine.block()


if __name__ == "__main__":
  from optparse import OptionParser

  def parse_commandline():
    curdir = os.path.normpath(os.path.abspath(os.path.curdir))
    parser=OptionParser()
    parser.add_option("-b", "--base-dir", dest="basedir", help="Base directory (default: %s)" %  curdir)
    parser.set_defaults(basedir=curdir)
    (options, args) = parser.parse_args()
    return options

  Server(parse_commandline()).run()

