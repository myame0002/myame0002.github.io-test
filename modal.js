function fetchAnalysis(title) {
  console.log('fetchAnalysis called with title:', title);
  fetch('show_analysis.rb?title=' + encodeURIComponent(title))
    .then(response => response.text())
    .then(data => {
      document.getElementById('modal-content').innerHTML = data;
      document.getElementById('myModal').style.display = "block";
    })
    .catch(error => {
      console.error('Error fetching analysis:', error);
      alert('分析結果の取得中にエラーが発生しました。');
    });
}

function deleteAnalysis(title, formId) {
    console.log('deleteAnalysis called with title:', title);
    var modal = document.getElementById('myModal');
    var modalTitle = document.getElementById('modal-title');
    var modalContent = document.getElementById('modal-content');

    modalTitle.innerHTML = "削除確認";
    modalContent.innerHTML = "<p>本当に「" + title + "」を削除しますか？</p><button onclick=\"deleteConfirmed('" + formId + "')\">削除</button><button onclick=\"closeModal()\">キャンセル</button>";

    modal.style.display = "block";
}

function deleteConfirmed(formId) {
    document.getElementById(formId).submit();
    closeModal();
}

// モーダルを閉じる
function closeModal() {
    document.getElementById('myModal').style.display = "none";
}

window.onclick = function(event) {
    if (event.target == document.getElementById('myModal')) {
        document.getElementById('myModal').style.display = "none";
    }
}
