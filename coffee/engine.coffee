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
      $('#nowStmInputTime').val(getTime())
      update()
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
  reqStr = if reqStr is '' then ' スタミナ消化しろ' else reqStr
  $('#reqStr').html(reqStr)
  
  inputDate = new Date(inputTime*1000)
  maxDate = new Date((inputTime + reqSec)*1000)
  atStr = ''
  if reqSec <= 0
    atStr += '既'
  else
    atStr += if maxDate.getDate() isnt inputDate.getDate() then '明日 ' else '今日 '
    atStr += ('0'+maxDate.getHours()).slice(-2)+':'+('0'+maxDate.getMinutes()).slice(-2)
  $('#atStr').html(atStr)

getTime = ->
  Math.floor(+new Date()/1000)