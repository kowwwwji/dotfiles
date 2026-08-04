// tb-vimkeys — terminal-browser の Vim 風キー操作（dotfiles 原則5: Vim流操作の横断統一）
// .scripts/tb-vimkeys-poller が action -- eval で全ページに注入する。
// terminal-browser には init script を登録する経路が無い（実測済み）ため、
// ポーラーが2秒ごとに再評価する。__tbVimKeys ガードで再評価を冪等にする。
//
// リスナーを2本に分けている理由: terminal-browser は Shift+英字を keydown へ
// 渡すとき shift を落として小文字化する（e2e 実測）。直後に送る char イベント
// （= keypress）でも event.key は同様に小文字化されたままだが、event.charCode/
// event.which には実際に入力された文字コードが大小そのまま残ることを実測で確認
// 済み（例: 'G' → charCode 71, 'g' → charCode 103）。そのため大小文字の区別が
// 要る文字キーは keypress の charCode/which から文字を復元して判定し、char
// イベントが発生しない Ctrl 組み合わせは keydown の event.key で処理する。
(() => {
  "use strict";
  if (window.__tbVimKeys) return;
  window.__tbVimKeys = true;

  const LINE = 60; // j/k 1回のスクロール量(px)
  let lastG = 0;   // gg 連打判定用

  // 入力欄にフォーカスがある間は何もしない（普通に文字入力できるように）
  const inEditable = (el) =>
    !!el && (el.tagName === "INPUT" || el.tagName === "TEXTAREA" ||
             el.tagName === "SELECT" || el.isContentEditable);

  // Shadow DOM 内の実フォーカス要素まで辿る（Web Components のサイトでは
  // document.activeElement が shadow host を返し、入力欄を見逃すため）
  const activeEl = () => {
    let el = document.activeElement;
    while (el && el.shadowRoot && el.shadowRoot.activeElement) el = el.shadowRoot.activeElement;
    return el;
  };

  // 文字キーは keypress で処理し、文字種は charCode/which から復元する
  addEventListener("keypress", (e) => {
    if (inEditable(activeEl())) return;
    if (e.metaKey || e.altKey || e.ctrlKey) return;
    const half = Math.round(innerHeight / 2);
    // event.key ではなく charCode/which から文字を復元する（上のコメント参照）
    const k = String.fromCharCode(e.charCode || e.which);
    let handled = true;
    if (k === "j") scrollBy(0, LINE);
    else if (k === "k") scrollBy(0, -LINE);
    else if (k === "h") scrollBy(-LINE, 0);
    else if (k === "l") scrollBy(LINE, 0);
    else if (k === "d") scrollBy(0, half);
    else if (k === "u") scrollBy(0, -half);
    else if (k === "G") scrollTo(0, document.documentElement.scrollHeight);
    else if (k === "H") history.back();
    else if (k === "L") history.forward();
    else if (k === "r") location.reload();
    else if (k === "g") {
      if (Date.now() - lastG < 500) { scrollTo(0, 0); lastG = 0; }
      else { lastG = Date.now(); handled = false; }
    } else handled = false;
    if (handled) { e.preventDefault(); e.stopPropagation(); }
  }, true);

  // Ctrl+d / Ctrl+u は char イベントが出ないため keydown で処理
  addEventListener("keydown", (e) => {
    if (inEditable(activeEl())) return;
    if (e.metaKey || e.altKey || !e.ctrlKey) return;
    const half = Math.round(innerHeight / 2);
    if (e.key === "d") scrollBy(0, half);
    else if (e.key === "u") scrollBy(0, -half);
    else return;
    e.preventDefault(); e.stopPropagation();
  }, true);
})();
