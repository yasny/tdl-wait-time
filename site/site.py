#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os, os.path
import random
import sqlite3
import string
import json

import cherrypy

DB_STRING = "/home/ec2-user/tdl-wait-time/data_collector/disney.sqlite"

class DisneyWaitTimeGraph(object):
  @cherrypy.expose
  def index(self):
    return file('/home/ec2-user/tdl-wait-time/site/index.html')

class WaitTimeWebService(object):
  exposed = True

  def dict_factory(self, cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
      d[col[0]] = row[idx]
    return d

  @cherrypy.tools.accept(media='text/plain')
  def GET(self):
    with sqlite3.connect(DB_STRING) as c:
      c.row_factory = self.dict_factory
      cur = c.cursor()
      cur.execute('select d.datetime, a.name as attraction_name, d.wait from data as d join attractions as a on d.attraction_id=a.id where d.datetime > date("now","-7 days") and d.attraction_id IN (4,5,14,23,26,35,36,43,52,53) order by d.attraction_id, d.datetime;')
      data = json.dumps(list(cur.fetchall()))
      return data


if __name__ == "__main__":
  cherrypy.process.plugins.Daemonizer(cherrypy.engine).subscribe()

  conf = {
    '/' : {
      'tools.sessions.on': False,
      'tools.staticdir.root': os.path.abspath(os.getcwd()),
      'log.access_file' : os.path.join(os.getcwd(),"access.log"),
      'log.screen': False,
    },
    '/waittime' : {
      'request.dispatch':cherrypy.dispatch.MethodDispatcher(),
      'tools.response_headers.on': True,
      'tools.response_headers.headers': [('Content-Type', 'text/plain')],
    },
    '/static' : {
      'tools.staticdir.on': True,
      'tools.staticdir.dir': './public',
    }
  }

  webapp = DisneyWaitTimeGraph()
  webapp.waittime = WaitTimeWebService()
  cherrypy.quickstart(webapp, '/', conf)

