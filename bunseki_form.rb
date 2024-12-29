#!/usr/bin/env ruby
require 'cgi'
require 'sqlite3'

begin
  cgi = CGI.new

  begin
    # データベースに接続して保存されたタイトルを取得
    db = SQLite3::Database.new('music_analysis.db')
    results = db.execute("SELECT DISTINCT title FROM analyses")
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
<p>データベースに接続中にエラーが発生しました: #{e.message}</p>
</body>
</html>
EOF
    }
    exit
  end

  html_output = <<EOF
<html>
<head>
<title>保存された分析結果</title>
<link rel="stylesheet" href="styles.css">
</head>
<body>
<h2>保存された分析結果</h2>
<div class="titles-list">
<p><strong>タイトル:</strong></p>
EOF

  if results.empty?
    html_output += <<HTML
<p>保存されたデータがありません。</p>
HTML
  else
    results.each_with_index do |row, index|
      title = row[0]
      html_output += <<-HTML
<div class="title-container">
  <span class="title-number">#{index + 1}.</span>
  <a class="title-link" href="javascript:void(0)" onclick="fetchAnalysis('#{title}')">#{title}</a>
  <button class="delete-button" onclick="document.getElementById('delete-form-#{index}').submit()">削除</button>
  <form id="delete-form-#{index}" action="delete_analysis.rb" method="post" style="display:none;">
    <input type="hidden" name="title" value="#{title}">
  </form>
</div>
HTML
    end
  end

  html_output += <<EOF
</div> <!-- .titles-list -->
<div id="analysis-details"></div>
<form action="bunseki_import.rb" method="get">
  <input type="submit" value="新しい分析を開始">
</form>

<!-- モーダル構造 -->
<div id="myModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeModal()">&times;</span>
    <div id="modal-title"></div>
    <div id="modal-content"></div>
  </div>
</div>

<script src="modal.js"></script>

</body>
</html>
EOF

  cgi.out("text/html; charset=utf-8") { html_output }

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
</body>
</html>
EOF
  }
end



