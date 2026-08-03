// tb-vimkeys — terminal-browser の Vim 風キー操作（dotfiles 原則5: Vim流操作の横断統一）
// .scripts/tb-vimkeys-poller が action -- eval で全ページに注入する。
// terminal-browser には init script を登録する経路が無い（実測済み）ため、
// ポーラーが2秒ごとに再評価する。__tbVimKeys ガードで再評価を冪等にする。
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

  addEventListener("keydown", (e) => {
    if (inEditable(document.activeElement)) return;
    if (e.metaKey || e.altKey) return; // 本体のネイティブキー(Alt+系)と衝突させない
    const half = Math.round(innerHeight / 2);
    const k = e.key;
    let handled = true;
    if (e.ctrlKey) {
      if (k === "d") scrollBy(0, half);
      else if (k === "u") scrollBy(0, -half);
      else handled = false; // Ctrl+Q/C(終了)等は本体が先に処理するのでここには来ない
    } else if (k === "j") scrollBy(0, LINE);
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
})();
