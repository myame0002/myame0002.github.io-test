#!/usr/bin/env ruby
require 'cgi'
require 'sqlite3'
require_relative 'conversion_methods'

begin
  cgi = CGI.new

  if cgi.request_method == "POST"
    # フォーム送信後の処理
    title = cgi['title']
    progressions_params = cgi.params.select { |key, _| key.match(/progression_roman\d+/) }
    adjacent_analysis_params = cgi.params.select { |key, _| key.match(/adjacent_analysis\d+/) }

    # データベースに接続して分析結果を更新
    db = SQLite3::Database.new('music_analysis.db')
    analysis_id = db.get_first_value("SELECT id FROM analyses WHERE title = ?", [title])

    if analysis_id.nil?
      raise "指定されたタイトルの分析結果が見つかりません。"
    end

    progressions_params.each do |key, progression_roman|
      progression_id = key.match(/progression_roman(\d+)/)[1].to_i
      adjacent_analysis = adjacent_analysis_params["adjacent_analysis#{progression_id}"].first
      db.execute("UPDATE code_progressions SET chords_roman = ?, adjacent_analysis = ? WHERE id = ?", [progression_roman.first, adjacent_analysis, progression_id])
    end

    cgi.out("text/html; charset=utf-8") {
      <<EOF
<html>
<head>
<title>更新完了: #{title}</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>更新完了</h2>
<p>タイトル「#{title}」に関する分析結果が更新されました。</p>
<form action="show_analysis.rb" method="get">
  <input type="hidden" name="title" value="#{title}">
  <input type="submit" value="戻る">
</form>
</body>
</html>
EOF
    }
  else
    # フォーム表示の処理
    title = cgi['title']

    # データベースに接続して分析結果を取得
    db = SQLite3::Database.new('music_analysis.db')
    analysis = db.get_first_row("SELECT id, scale FROM analyses WHERE title = ?", [title])

    if analysis.nil?
      raise "指定されたタイトルの分析結果が見つかりません。"
    end

    analysis_id = analysis[0]
    scale = analysis[1]
    progressions = db.execute("SELECT id, chords_roman, adjacent_analysis FROM code_progressions WHERE analysis_id = ?", [analysis_id])

    if progressions.empty?
      raise "指定されたタイトルのコード進行が見つかりません。"
    end

    html_output = <<EOF
<html>
<head>
<title>編集: #{title}</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>編集: #{title}</h2>
<form action="edit_analysis.rb" method="post">
EOF

    progressions.each_with_index do |row, index|
      progression_id, chords_roman, adjacent_analysis = row
      html_output += <<-HTML
      <label for="progression_roman#{progression_id}">和 声 表 記#{index + 1}:</label>
      <input type="text" id="progression_roman#{progression_id}" name="progression_roman#{progression_id}" value="#{chords_roman}"><br>
      <label for="adjacent_analysis#{progression_id}">隣 接 分 析#{index + 1}:</label>
      <input type="text" id="adjacent_analysis#{progression_id}" name="adjacent_analysis#{progression_id}" value="#{adjacent_analysis}"><br>
      HTML
    end

    html_output += <<EOF
  <p></p>
  <input type="hidden" name="title" value="#{title}">
  <input type="submit" value="更新">
</form>
<form action="show_analysis.rb" method="get">
  <input type="hidden" name="title" value="#{title}">
  <input type="submit" value="戻る">
</form>
</body>
</html>
EOF

    cgi.out("text/html; charset=utf-8") { html_output }
  end

rescue SQLite3::Exception => e
  cgi.out("text/html; charset=utf-8") {
    <<EOF
<html>
<head>
<title>データベースエラー</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>データベースエラー</h2>
<p>更新中にエラーが発生しました: #{e.message}</p>
<form action="show_analysis.rb" method="get">
  <input type="hidden" name="title" value="#{title}">
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
<h2>エラー</h2>
<p>スクリプトの実行中にエラーが発生しました: #{e.message}</p>
<form action="show_analysis.rb" method="get">
  <input type="hidden" name="title" value="#{title}">
  <input type="submit" value="戻る">
</form>
</body>
</html>
EOF
  }
end
