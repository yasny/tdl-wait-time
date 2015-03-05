#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os, os.path
import random
import sqlite3
import string
import json
import cherrypy

DB_STRING = os.path.join(os.path.abspath(os.getcwd()),"../data_collector/disney.sqlite")

DEFAULT_ATTRACTIONS="4,5,12,14,23,26,35,36,43,44,49,52,53"

__all__ = ["DisneyWaitTimGraph"]


def dict_factory(cursor, row):
  """DB行をdictに変換する"""
  d = {}
  for idx, col in enumerate(cursor.description):
    d[col[0]] = row[idx]
  return d


class DisneyWaitTimeGraph(object):
  @cherrypy.expose
  def index(self, daysPrevious=7):
    """index.htmlページ"""
    cherrypy.log(str(cherrypy.request.app.config))
    return file(os.path.join(cherrypy.request.app.config['/']['tools.staticdir.root'],'public/html/index.html'))


  @cherrypy.expose
  @cherrypy.tools.accept(media='text/plain')
  @cherrypy.tools.json_out()
  def waittime(self, daysPrevious=7, attractions=DEFAULT_ATTRACTIONS, parkAverage=False):
    """waittime web service"""

    #cherrypy.log("daysPrevious = "+str(daysPrevious))
    #cherrypy.log("attractions = "+str(attractions))
    if (not str(daysPrevious).isdigit()):
      raise cherrypy.HTTPError(403)
    if (not parkAverage and len(attractions) == 0):
      raise cherrypy.HTTPError(403)

    sql = ""

    if not parkAverage:
        sql = " ".join(('select datetime, attraction_name, wait from v_wait_time',
                'where attraction_id IN ('+str(attractions)+') ',
                'and datetime > date("now"'+(',"-'+daysPrevious+' days")' if not daysPrevious=='0' else ')'),
                'order by attraction_id, datetime;'))
    else:
        sql = " ".join(('select datetime, park_name as name, avg(wait) as average from v_wait_time',
                'where wait <> 0 ',
                'and datetime > date("now"'+(', "-'+daysPrevious+' days")' if not daysPrevious=='0' else ')'),
                'group by datetime, park_id',
                'order by park_id, datetime;'))

    with sqlite3.connect(DB_STRING) as c:
      c.row_factory = dict_factory
      cur = c.cursor()
      cur.execute(sql)
      return cur.fetchall()

