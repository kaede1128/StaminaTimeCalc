$().ready(
  ->
    # クッキー復帰
    $('#maxStm').val($.cookie('maxStm')) if $.cookie('maxStm')?
    # 最大スタミナの保存
    $('#maxStm').on('change', ->
      $.cookie('maxStm', $(this).val(), { expires: 365*100 })
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
      return if +new Date $('#calendarDate').val() < +new Date()
      date = new Date Number $('#calendarDate').val()
      window.open getLink4google date
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
  inputTime
  maxStm = Number $('#maxStm').val()
  nowStm = Number $('#nowStm').val()
  reqSec = (maxStm - nowStm) * 60 * 5

  reqStr = ''
  reqStr += if reqSec >= 60*60 then ''+Math.floor(reqSec/60/60)+' 時間' else ''
  reqStr += if reqSec >= 60 and Math.floor(reqSec/60%60) isnt 0 then ''+Math.floor(reqSec/60%60)+' 分' else ''
  reqStr = if reqStr is '' then ' はやく消化しなきゃ' else reqStr
  $('#reqStr').html(reqStr)
  
  inputDate = new Date(inputTime*1000)
  maxDate = new Date((inputTime + reqSec)*1000)
  atStr = ''
  if reqSec <= 0
    atStr += 'もう時間だ'
  else
    atStr += if maxDate.getDate() isnt inputDate.getDate() then '明日 ' else '今日 '
    atStr += zerofill(maxDate.getHours())+':'+zerofill(maxDate.getMinutes())
  $('#atStr').html(atStr)

  # Googleカレンダー
  $('#calendarDate').val +maxDate

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

getTime = ->
  Math.floor(+new Date()/1000)
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