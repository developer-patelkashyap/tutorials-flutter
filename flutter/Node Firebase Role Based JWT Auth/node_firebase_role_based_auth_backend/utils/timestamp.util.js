function getCurrentTimestamp() {
  const now = new Date();
  const pad = (n) => n.toString().padStart(2, "0");
  const dd = pad(now.getDate());
  const mm = pad(now.getMonth() + 1);
  const yyyy = now.getFullYear();
  const hh = pad(now.getHours());
  const min = pad(now.getMinutes());
  const ss = pad(now.getSeconds());

  return `${dd}-${mm}-${yyyy}--${hh}-${min}-${ss}`;
}

module.exports = getCurrentTimestamp;
