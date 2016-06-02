# -*- coding: utf-8 -*-

# https://github.com/sleepiest/burgerking
# usage
# ruby burger.rb [n]
# n: times(defalult 0)

require 'date'
require 'pp'
require 'mechanize'

def form1(agent, check_num)
  cn = check_num.to_s
  form = agent.page.form_with(:id => "surveyForm")
  form.radiobutton_with(:value => cn).check
  button = form.button_with(:name => "NextButton")
  agent.submit(form, button)
end

def form2(agent, check_num)
  cn = check_num.to_s
  form = agent.page.form_with(:id => "surveyForm")
  form.radiobuttons_with(:value => cn).each{|rb| rb.check}
  button = form.button_with(:name => "NextButton")
  agent.submit(form, button)
end

def form3(agent)
  form = agent.page.form_with(:id => "surveyForm")
  button = form.button_with(:name => "NextButton")
  agent.submit(form, button)
end

n = ARGV.empty? ? 1 : ARGV[0].to_i

couponcodes = []
threads = []

n.times {
  threads << Thread.new {
    agent = Mechanize.new
    agent.user_agent = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)'
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

    ################################################################
    agent.get('https://jp.tellburgerking.com/')
    # puts agent.page.body

    # クッキーとその他のデータ収集技術の使用に同意
    # get the form
    form = agent.page.form_with(:id => "surveyEntryForm")
    # get the button you want from the form
    button = form.button_with(:name => "NextButton")
    # submit the form using that button
    agent.submit(form, button)

    # yesterday 13:00
    yesterday = DateTime.parse(Date.today.to_s) - Rational(11, 24)
    /(\d+)\D+(\d+)\D+(\d+)\D+(\d+)\D+(\d+)/ =~ (yesterday.to_s)

    # 店舗番号 日時を入力
    form = agent.page.form_with(:id => "surveyEntryForm")
    form["JavaScriptEnabled"] = "1"
    form["SurveyCode"] = %w(19192 21606 16568).sample	# form.field_with(:name => "SurveyCode").value = "21606"
    form["InputYear"] = $1		# form.field_with(:name => "InputYear"){|list| list.value="2016"}
    form["InputMonth"] = $2
    form["InputDay"] = $3
    form["InputHour"] = $4
    form["InputMinute"] = $5
    button = form.button_with(:name => "NextButton")
    agent.submit(form, button)

    # ご購入のタイプを選択してください。(eat-in or take out)
    form1(agent, 2)

    # 何名様でのご利用でしたか？
    form1(agent, 1)

    # 全体的な満足度をお答えください。
    form1(agent, 3)

    # 以下の各項目についての満足度をお聴かせください。
    form2(agent, 3)

    # 以下の各項目についての満足度をお聴かせください。
    form2(agent, 3)

    # 以下の各項目についての満足度をお聴かせください。
    form2(agent, 3)

    # 店内をより清潔にするには？
    form3(agent)

    # 外観をより清潔にするには？
    form3(agent)

    # スピードアップにどこを改善？
    form3(agent)

    # ハンバーガーの品質を上げるには？
    form3(agent)

    # BKフレンチフライの品質を上げるには？
    form3(agent)

    # ご利用の際に何か問題が？
    form1(agent, 2)

    # 今回の体験からお客様は、、、
    form2(agent, 3)

    # 満足頂けなかった理由
    form3(agent)

    # メインオーダー？
    form3(agent)

    # サイドオーダー？
    form3(agent)

    # もう少し、質問
    form2(agent, 1)

    # 何回ご利用？
    form1(agent, 1)

    # 利用になられる理由
    form1(agent, 9)

    # ファストフード店
    form1(agent, 9)

    # 性別 年齢
    form = agent.page.form_with(:id => "surveyForm")
    form["R069000"] = "2"
    form["R070000"] = "4"
    button = form.button_with(:name => "NextButton")
    agent.submit(form, button)

    # 認証コード
    valcode = agent.page.at('.ValCode').children[0] # CSSセレクタでマッチする最初の要素を取得

    /\w+/ =~ valcode.content
    couponcodes << $&
  }
}

threads.each{|t| t.join}
puts couponcodes.sort

__END__
