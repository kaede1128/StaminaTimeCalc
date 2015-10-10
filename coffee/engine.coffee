$().ready(
  ->
    # クッキー復帰
    $('#maxStm').val($.cookie('maxStm')) if $.cookie('maxStm')?
    $('#groupId').val($.cookie('groupId')) if $.cookie('groupId')?
    # 最大スタミナの保存
    $('#maxStm').on('change', ->
      $.cookie('maxStm', $(this).val(), { expires: 365*100 })
      update()
    )
    # グループIDの保存
    $('#groupId').on('change', ->
      $.cookie('groupId', $(this).val(), { expires: 365*100 })
      update()
    )

    # 現在スタミナを入力
    $('#nowStm').on('change', ->
      # 現在時刻を保存
      $('#nowStmInputTime').val getTime()
      update()
    )
    # Googleカレンダー
    $('#googleCalendar').on('click', ->
      return if Number($('#calendarDate').val()) < +new Date()
      date = new Date Number $('#calendarDate').val()
      window.open getLink4google date
    )
    $('#googleCalendarTore').on('click', ->
      return if Number($('#calendarDateTore').val()) < +new Date()
      date = new Date Number $('#calendarDateTore').val()
      window.open getLinkTore4google date
    )

    # 時刻の表記を変更
    setInterval(update, 1000)

    # QRコード
    show = 'QRコードを表示する'
    hide = 'QRコードを非表示にする'
    $('#qrbutton').on('click', =>
      if $('#qrbutton').text() is show
        $('#qrbutton').text(hide)
      else
        $('#qrbutton').text(show)
      $('#code').slideToggle()
    )
    $('#code').qrcode(
      render  : "table",
      text  : location.href
    )
    $('#qrbutton').text(show)
)

update = ->
  inputTime = Number $('#nowStmInputTime').val()
  return if inputTime is 0

  maxStm = Number $('#maxStm').val()
  nowStm = Number $('#nowStm').val()
  groupId = Number Number $('#groupId').val()
  reqSec = (maxStm - nowStm) * 60 * 5

  # スタミナMAXになる時刻
  reqStr = sec2HourMin(reqSec*1000)
  reqStr = if reqStr is '' then ' はやく消化しなきゃ' else reqStr
  $('#reqStr').html(reqStr)
  
  nowDate = new Date()
  inputDate = new Date(inputTime*1000)
  maxDate = new Date((inputTime + reqSec)*1000)

  # スタミナMAXになるまでの時間量
  atStr = ''
  if reqSec <= 0
    atStr += 'もう時間だ'
  else
    atStr += if maxDate.getDate() isnt inputDate.getDate() then '明日 ' else '今日 '
    atStr += zerofill(maxDate.getHours())+':'+zerofill(maxDate.getMinutes())
  $('#atStr').html(atStr)

  # グループIDからトレチケタイム
  toreReqStr = ''
  toreAtStr = ''
  toreGoogleTime = 0
  if groupId >= 0
    $('.tore').css('display', 'table-row')

    dates = getToretikeDate(nowDate, groupId)
    for d in dates
      toreTime = +d - +new Date()
      if -1000*60*60 < toreTime <= 0
        toreAtStr = 'いまトレチケタイム'
        toreReqStr = 'あと'+sec2HourMin(toreTime + 1000*60*60)
        break
      else if 0 < toreTime
        toreAtStr += if d.getDate() isnt inputDate.getDate() then '明日 ' else '今日 '
        toreAtStr += zerofill(d.getHours())+':'+zerofill(d.getMinutes())
        toreReqStr = sec2HourMin(toreTime)
        toreGoogleTime = +d
        break
  else
    $('.tore').css('display', 'none')
  $('#toreReqStr').html(toreReqStr)
  $('#toreAtStr').html(toreAtStr)

  # Googleカレンダー
  $('#calendarDate').val +maxDate
  $('#calendarDateTore').val toreGoogleTime

getLink4google = (date)->
  'http://www.google.com/calendar/event?' +
  'action='   + 'TEMPLATE' +
  '&text='    + encodeURIComponent('デレステスタミナMAX') +
  '&details=' + encodeURIComponent('デレステのスタミナがMAXになった') +
  '&location='+ encodeURIComponent('アプリ') +
  '&dates='   + date4google(date) + '/' + date4google(date) +
  '&trp='     + 'false' +
  '&sprop='   + encodeURIComponent(location.href) +
  '&sprop='   + 'name:' + encodeURIComponent('デレステスタミナ計算機')

getLinkTore4google = (date)->
  'http://www.google.com/calendar/event?' +
  'action='   + 'TEMPLATE' +
  '&text='    + encodeURIComponent('デレステトレチケタイム') +
  '&details=' + encodeURIComponent('デレステのトレチケタイム') +
  '&location='+ encodeURIComponent('アプリ') +
  '&dates='   + date4google(date) + '/' + date4google(new Date(+date+1000*60*60)) +
  '&trp='     + 'false' +
  '&sprop='   + encodeURIComponent(location.href) +
  '&sprop='   + 'name:' + encodeURIComponent('デレステスタミナ計算機')


sec2HourMin = (time)->
  res = ''
  sec = time/1000
  res += if sec >= 60*60 then ''+Math.floor(sec/60/60)+' 時間' else ''
  res += if sec >= 60 and Math.floor(sec/60%60) isnt 0 then ''+Math.floor(sec/60%60)+' 分' else ''
  res

getTime = ->
  Math.floor(+new Date()/1000)

getDateStr = (date = null)->
  date = new Date() if date is null
  ''+date.getFullYear()+'-'+zerofill(date.getMonth()+1)+'-'+zerofill(date.getDate())

date4google = (date)->
  date.getUTCFullYear() +
  zerofill(date.getUTCMonth()+1) +
  zerofill(date.getUTCDate()) +
  'T' +
  zerofill(date.getUTCHours()) +
  zerofill(date.getUTCMinutes()) +
  zerofill(date.getUTCSeconds()) +
  'Z'

zerofill = (num)->
  ('0'+num).slice(-2)

getPatternId = (nowDate)->
  # 基準
  baseDate = new Date('2015-10-01 00:00:00')
  patternId = 3

  nowDate = new Date(getDateStr(nowDate)+' 00:00:00')
  dayCount = (+nowDate - +baseDate) / (1000*60*60*24)
  (patternId - dayCount) %% 4

getToretikeDate = (nowDate, groupId)->
  timeTable = [[8, 12, 19], [9, 13, 20], [10, 14, 21], [11, 15, 22]]
  patternId = getPatternId nowDate

  res = []
  index = (groupId - patternId) %% 4
  for hour in timeTable[index]
    res.push(new Date(getDateStr(nowDate)+' '+zerofill(hour)+':00:00'))

  tomorrowDate = new Date(+nowDate + 1000*60*60*24)
  index = (groupId - getPatternId(tomorrowDate)) %% 4
  for hour in timeTable[index]
    res.push(new Date(getDateStr(tomorrowDate)+' '+zerofill(hour)+':00:00'))
  res
