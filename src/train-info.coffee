# Description
#   A hubot script that does the things
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   fuchiken5 <fuchiken5@gmail.com>

cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob

module.exports = (robot) ->
  new cronJob('0 * * * * 1-5', () ->
    jr_nb = 'https://transit.yahoo.co.jp/traininfo/detail/34/0/'
    jr_ss = 'https://transit.yahoo.co.jp/traininfo/detail/25/0/'
    jr_ys = 'https://transit.yahoo.co.jp/traininfo/detail/29/0/'
    jr_kt = 'https://transit.yahoo.co.jp/traininfo/detail/22/0/'
    searchTrainCron(jr_nb)
    searchTrainCron(jr_ss)
    searchTrainCron(jr_ys)
    searchTrainCron(jr_kt)
  ).start()

  searchTrainCron = (url) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        robot.send {room: "#mybot"}, "#{title}は正常運行中"
      else
        info = $('.trouble p').text()
        robot.send {room: "#mybot"}, "#{title}は事故や遅延情報あり。\n- #{info}"

module.exports = (robot) ->
  robot.respond /電車/i, (msg) ->
    baseUrl = 'http://transit.loco.yahoo.co.jp/traininfo/gc/13/'

    cheerio.fetch baseUrl, (err, $, res) ->
      if $('.elmTblLstLine.trouble').find('a').length == 0
        msg.send "事故や遅延情報はありません"
        return
      $('.elmTblLstLine.trouble a').each ->
        url = $(this).attr('href')
        cheerio.fetch url, (err, $, res) ->
          title = "◎ #{$('h1').text()} #{$('.subText').text()}"
          result = ""
          $('.trouble').each ->
            trouble = $(this).text().trim()
            result += "- " + trouble + "\r\n"
          msg.send "#{title}\r\n#{result}"
