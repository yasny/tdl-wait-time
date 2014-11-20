#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os, os.path
import random
import sqlite3
import string
import json
import cherrypy

DB_STRING = "../data_collector/disney.sqlite"

# とりあえず全部ハードコードしちゃう！
# sqlite側でビューを作ったほうが綺麗かもしれない
WAITTIME_WEEK_SQL = ('select d.datetime, a.name as attraction_name, d.wait from data as d '
                       'join attractions as a on d.attraction_id=a.id '
                     'where d.datetime > date("now","-7 days") '
                       'and d.attraction_id IN (4,5,14,23,26,35,36,43,44,52,53) '
                     'order by d.attraction_id, d.datetime;')

WAITTIME_AVG_WEEK_SQL = ('select d.datetime, p.name as name, avg(wait) as average from data as d '
                           'inner join attractions as a on d.attraction_id = a.id, '
                             'lands as l on a.land_id = l.id, '
                             'parks as p on l.park_id = p.id '
                         'where d.wait <> 0 '
                           'and d.datetime > date("now","-7 days") '
                         'group by d.datetime, p.id '
                         'order by p.id, d.datetime;')

DEFAULT_ATTRACTIONS="4,5,14,23,26,35,36,43,44,52,53"


def dict_factory(cursor, row):
  """DB行をdictに変換する"""
  d = {}
  for idx, col in enumerate(cursor.description):
    d[col[0]] = row[idx]
  return d


class DisneyWaitTimeGraph(object):
  """index.htmlページ"""
  @cherrypy.expose
  def index(self, daysPrevious=7):
    return file('index.html')


class WaitTimeWebService(object):
  """1周間分の待ち時間を取得してJSONに変換するサービス"""
  exposed = True

  @cherrypy.tools.accept(media='text/plain')
  def GET(self):
    with sqlite3.connect(DB_STRING) as c:
      c.row_factory = dict_factory
      cur = c.cursor()
      cur.execute(WAITTIME_WEEK_SQL)
      data = json.dumps(cur.fetchall())
      return data


class WaitTimeWebServiceV2(object):
  exposed = True

  @cherrypy.tools.accept(media='text/plain')
  def GET(self, daysPrevious=7, attractions=DEFAULT_ATTRACTIONS, parkAverage=False):
    cherrypy.log("daysPrevious = "+str(daysPrevious))
    cherrypy.log("attractions = "+str(attractions))
    if (not str(daysPrevious).isdigit()):
      raise cherrypy.HTTPError(403)
    if (len(attractions) == 0):
      raise cherrypy.HTTPError(403)

    sql = ""

    if (not parkAverage):
      sql = ('select d.datetime, a.name as attraction_name, d.wait from data as d '
                         'join attractions as a on d.attraction_id=a.id '
                       'where d.attraction_id IN ('+str(attractions)+') '
                         'and d.datetime > date("now","-'+str(daysPrevious)+' days") '
                       'order by d.attraction_id, d.datetime;')

      if (daysPrevious==0):
        sql = ('select d.datetime, a.name as attraction_name, d.wait from data as d '
                           'join attractions as a on d.attraction_id=a.id '
                         'where d.attraction_id IN ('+str(attractions)+') '
                           'and date(d.datetime)=date("now") '
                         'order by d.attraction_id, d.datetime;')

    else:
      sql = ('select d.datetime, p.name as name, avg(wait) as average from data as d '
                                 'inner join attractions as a on d.attraction_id = a.id, '
                                   'lands as l on a.land_id = l.id, '
                                   'parks as p on l.park_id = p.id '
                               'where d.wait <> 0 '
                                 'and d.datetime > date("now","-'+str(daysPrevious)+' days") '
                               'group by d.datetime, p.id '
                               'order by p.id, d.datetime;')
      if (daysPrevious==0):
        sql = ('select d.datetime, p.name as name, avg(wait) as average from data as d '
                                   'inner join attractions as a on d.attraction_id = a.id, '
                                     'lands as l on a.land_id = l.id, '
                                     'parks as p on l.park_id = p.id '
                                 'where d.wait <> 0 '
                                   'and date(d.datetime) = date("now") '
                                 'group by d.datetime, p.id '
                                 'order by p.id, d.datetime;')


    with sqlite3.connect(DB_STRING) as c:
      c.row_factory = dict_factory
      cur = c.cursor()
      cur.execute(sql)
      return json.dumps(cur.fetchall())



class AverageWaitTimeForWeekService(object):
  """1周間分の平均待ち時間を取得してJSONに変換するサービス"""
  exposed = True

  @cherrypy.tools.accept(media='text/plain')
  def GET(self):
    with sqlite3.connect(DB_STRING) as c:
      c.row_factory = dict_factory
      cur = c.cursor()
      cur.execute(WAITTIME_AVG_WEEK_SQL)
      data = json.dumps(cur.fetchall())
      return data


if __name__ == "__main__":
  # フォークしてバックグラウンドで動かす
  #cherrypy.process.plugins.Daemonizer(cherrypy.engine).subscribe()

  # CherryPy設定
  conf = {
    '/' : {
      'tools.sessions.on': False,
      'tools.staticdir.root': os.path.abspath(os.getcwd()),
      'log.access_file' : os.path.join(os.getcwd(),"access.log"),
      'log.error_file' : os.path.join(os.getcwd(),"error.log"),
      'log.screen': False,
    },
    '/waittime_week' : {
      'request.dispatch':cherrypy.dispatch.MethodDispatcher(),
      'tools.response_headers.on': True,
      'tools.response_headers.headers': [('Content-Type', 'text/plain')],
    },
    '/waittime' : {
      'request.dispatch':cherrypy.dispatch.MethodDispatcher(),
      'tools.response_headers.on': True,
      'tools.response_headers.headers': [('Content-Type', 'text/plain')],
    },
    '/waittime_avg_week' : {
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
  webapp.waittime_week = WaitTimeWebService()
  webapp.waittime_avg_week = AverageWaitTimeForWeekService()
  webapp.waittime = WaitTimeWebServiceV2()
  cherrypy.quickstart(webapp, '/', conf)

