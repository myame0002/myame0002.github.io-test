#!/usr/bin/env ruby
require 'cgi'

cgi = CGI.new

print cgi.header("text/html; charset=utf-8")
print <<EOF
<html>
<head>
  <title>楽曲コード分析web</title>
  <link rel="stylesheet" href="styles.css">
  <script type="text/javascript">
    // 入力フィールドのカウンタ
    let chordCount = 1;
    // コード進行の入力フィールドを追加する関数
    function addChordField() {
      chordCount++;
      const chordFieldsDiv = document.getElementById('chordFields');
      const newField = document.createElement('div');
      newField.setAttribute('id', 'chordField' + chordCount);
      newField.innerHTML = \`<label for="progression\${chordCount}">コード進行\${chordCount}:</label>
                            <input type="text" name="progression\${chordCount}" id="progression\${chordCount}"><br>\`;
      chordFieldsDiv.appendChild(newField);
    }

    // コード進行の入力フィールドを削除する関数
    function removeChordField() {
      if (chordCount > 1) {
        const chordFieldsDiv = document.getElementById('chordFields');
        const fieldToRemove = document.getElementById('chordField' + chordCount);
        chordFieldsDiv.removeChild(fieldToRemove);
        chordCount--;
      }
    }

    function validateForm() {
      var title = document.getElementById("title").value;
      var scale = document.getElementById("scale").value;

      if (title.trim() === "") {
        alert("曲名を入力してください。");
        return false;
      }

      if (scale.trim() === "" || !/^(?:[A-G][#b]?[m]?)$/.test(scale)) {
        alert("スケールにはA-GまたはAm-Gmを入力してください。");
        return false;
      }

      for (let i = 1; i <= chordCount; i++) {
        var progression = document.getElementById("progression" + i).value;
        if (progression.trim() === "" || !/^[A-G][#bmM7]*\s?([A-G][#bmM7]*\s?)*$/.test(progression)) {
          alert("コード進行にはA-GまたはAm-Gm、#、b、7などの正しいコードを空白で区切って入力してください。");
          return false;
        }
      }

      return true;
    }
  </script>
</head>
<body>
  <h1>楽曲コード分析web</h1>
  <form action="bunseki_result.rb" method="post" onsubmit="return validateForm()">
    <label for="title">曲名:</label>
    <input type="text" name="title" id="title"><br>
    <label for="scale">スケール:(メジャー、マイナー)</label>
    <input type="text" name="scale" id="scale"><br>
    <div id="chordFields">
      <label for="progression1">コード進行1:</label>
      <input type="text" name="progression1" id="progression1"><br>
    </div>
    <div class="button-container">
    <button type="button" onclick="addChordField()">コード進行を追加</button>
    <button class="delete-button" type="button" onclick="removeChordField()">コード進行を削除</button>
    </div>
    <br>
    <p></p>
    <input type="submit" value="送信">
  </form>
  <form action="bunseki_form.rb" method="get">
    <input type="submit" value="保存された分析結果を見る">
  </form>
</body>
</html>
EOF





