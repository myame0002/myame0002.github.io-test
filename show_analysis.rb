#!/usr/bin/env ruby
require 'cgi'
require 'sqlite3'

begin
  cgi = CGI.new
  title = cgi['title']

  # データベースに接続して分析結果を取得
  db = SQLite3::Database.new('music_analysis.db')
  analysis = db.get_first_row("SELECT id, scale FROM analyses WHERE title = ?", [title])

  if analysis.nil?
    raise "指定されたタイトルの分析結果が見つかりません。"
  end

  analysis_id = analysis[0]
  scale = analysis[1]
  progressions = db.execute("SELECT progression, chords_number, chords_roman, adjacent_analysis FROM code_progressions WHERE analysis_id = ?", [analysis_id])

  if progressions.empty?
    raise "指定されたタイトルのコード進行が見つかりません。"
  end

html_output = <<EOF
<html>
<head>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>タイトル: #{title}</h2>
<div class="content-wrapper" style="background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
<p>スケール: #{scale}</p>
EOF

  progressions.each_with_index do |row, index|
    progression, chords_number, chords_roman, adjacent_analysis = row
    html_output += <<-HTML
    <hr>
    <p>コード進行#{index + 1}: #{progression}</p>
    <!--<p>コード進行#{index + 1}（数字）: #{chords_number}</p>-->
    <p>和声表記#{index + 1}: <span class="spaced-text special-spacing" style="letter-spacing: 0.1em;">#{chords_roman}</span></p>
    <p>隣接分析#{index + 1}: #{adjacent_analysis}</p>
    HTML
  end

  html_output += <<EOF
<hr>
<p></p>
<p></p>
<div style="display: flex; justify-content: space-between; align-items: center;">
  <form action="bunseki_form.rb" method="get" style="background-color: transparent; box-shadow: none; border: none; padding: 0; margin: 0;">
    <input type="submit" value="戻る">
  </form>
  <form action="edit_analysis.rb" method="get" style="background-color: transparent; box-shadow: none; border: none; padding: 0; margin: 0;">
    <input type="hidden" name="title" value="#{title}">
    <input type="submit" value="変更">
  </form>
</div>
</div>
</body>
</html>
EOF

  cgi.out("text/html; charset=utf-8") { html_output }

rescue SQLite3::Exception => e
  cgi.out("text/html; charset=utf-8") {
    <<EOF
<html>
<head>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>データベースエラー</h2>
<p>データ取得中にエラーが発生しました: #{e.message}</p>
<div style="display: flex; justify-content: space-between; align-items: center;">
  <form action="bunseki_form.rb" method="get" style="background-color: transparent; box-shadow: none; border: none; padding: 0; margin: 0;">
    <input type="submit" value="戻る">
  </form>
</div>
</body>
</html>
EOF
  }
rescue StandardError => e
  cgi.out("text/html; charset=utf-8") {
    <<EOF
<html>
<head>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>エラー</h2>
<p>スクリプトの実行中にエラーが発生しました: #{e.message}</p>
<div style="display: flex; justify-content: space-between; align-items: center;">
  <form action="bunseki_form.rb" method="get" style="background-color: transparent; box-shadow: none; border: none; padding: 0; margin: 0;">
    <input type="submit" value="戻る">
  </form>
</div>
</body>
</html>
EOF
  }
end
