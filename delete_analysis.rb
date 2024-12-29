#!/usr/bin/env ruby
require 'cgi'
require 'sqlite3'

begin
  cgi = CGI.new
  title = cgi['title']

  # データベースに接続
  db = SQLite3::Database.new('music_analysis.db')

  # analysesテーブルから該当する分析のIDを取得
  analysis_id = db.get_first_value("SELECT id FROM analyses WHERE title = ?", [title])

  if analysis_id.nil?
    raise "指定されたタイトルの分析結果が見つかりません。"
  end

  # analysesテーブルから該当する分析を削除
  db.execute("DELETE FROM analyses WHERE id = ?", [analysis_id])

  # code_progressionsテーブルから該当するコード進行を削除
  db.execute("DELETE FROM code_progressions WHERE analysis_id = ?", [analysis_id])

  cgi.out("text/html; charset=utf-8") {
    <<EOF
<html>
<head>
<title>削除結果</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>削除結果</h2>
<p>タイトル「#{title}」に関する分析結果が削除されました。</p>
<form action="bunseki_form.rb" method="get" style="display: flex; justify-content: flex-end;">
  <input type="submit" value="戻る">
</form>
</body>
</html>
EOF
  }
rescue SQLite3::Exception => e
  cgi.out("text/html; charset=utf-8") {
    <<EOF
<html>
<head>
<title>エラー</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>データベースエラー</h2>
<p>削除中にエラーが発生しました: #{e.message}</p>
<form action="bunseki_form.rb" method="get" style="display: flex; justify-content: flex-end;">
  <input type="submit" value="戻る">
</form>
</body>
</html>
EOF
  }
rescue StandardError => e
  cgi.out("text/html; charset=utf-8") {
    <<EOF
<html>
<head>
<title>エラー</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>スクリプトの実行中にエラーが発生しました:</h2> 
<p>#{e.message}</p>
<form action="bunseki_form.rb" method="get" style="display: flex; justify-content: flex-end;">
  <input type="submit" value="戻る">
</form>
</body>
</html>
EOF
  }
end

