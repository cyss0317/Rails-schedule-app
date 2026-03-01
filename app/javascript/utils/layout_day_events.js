/**
 * layoutDayEvents
 *
 * Assigns horizontal position (leftPercent, widthPercent) to each event using
 * a Microsoft Teams/Outlook-style greedy interval-column layout.
 *
 * Overlap rule: A overlaps B iff (A.startMin < B.endMin) && (B.startMin < A.endMin)
 * Events touching exactly at an endpoint (end == start) do NOT overlap and
 * may reuse the same column.
 *
 * Right gutter: a fixed percentage on the right side of each day column is
 * always left empty so admins can click there to create a new shift.
 *
 * ─────────────────────────── ACCEPTANCE TESTS ────────────────────────────
 *
 * 1) Only A (300–1320):  [rightGutterPercent=15, gutterPercent=1]
 *      A → columnCount=1, leftPercent=0, widthPercent=85
 *
 * 2) A (300–1320), B (300–960):  [rightGutterPercent=15, gutterPercent=1]
 *      widthPercent = (85 - 1) / 2 = 42
 *      A → col 0 → leftPercent=0,  widthPercent=42
 *      B → col 1 → leftPercent=43, widthPercent=42
 *
 * 3) A (300–1320), B (300–960), C (960–1320):
 *      B.endMin == C.startMin → touching, not overlap.
 *      A overlaps both → cluster {A,B,C}, 2 columns.
 *      B → col 1; C reuses col 1 (960 <= 960).
 *
 * ─────────────────────────────────────────────────────────────────────────
 *
 * @param {Array<{ id: string|number, startMin: number, endMin: number }>} events
 * @param {{ gutterPercent?: number, rightGutterPercent?: number }} options
 * @returns {{ results: Array<{ id, startMin, endMin, columnIndex, columnCount, leftPercent, widthPercent }> }}
 */
export function layoutDayEvents(events, options = {}) {
  const gutterPercent      = options.gutterPercent      ?? 1.0;
  const rightGutterPercent = options.rightGutterPercent ?? 15;

  if (events.length === 0) return { results: [] };

  // ── A) Connected conflict clusters via union-find ──────────────────────────

  const parent = new Map(events.map(e => [e.id, e.id]));

  function find(id) {
    if (parent.get(id) !== id) parent.set(id, find(parent.get(id)));
    return parent.get(id);
  }

  function union(a, b) {
    parent.set(find(a), find(b));
  }

  function overlaps(a, b) {
    return a.startMin < b.endMin && b.startMin < a.endMin;
  }

  for (let i = 0; i < events.length; i++) {
    for (let j = i + 1; j < events.length; j++) {
      if (overlaps(events[i], events[j])) {
        union(events[i].id, events[j].id);
      }
    }
  }

  const clusters = new Map();
  for (const event of events) {
    const root = find(event.id);
    if (!clusters.has(root)) clusters.set(root, []);
    clusters.get(root).push(event);
  }

  // ── B) Greedy column assignment per cluster ────────────────────────────────

  const colIndexMap     = new Map();
  const clusterColCount = new Map();

  for (const [root, cluster] of clusters) {
    const sorted = [...cluster].sort((a, b) => {
      if (a.startMin !== b.startMin) return a.startMin - b.startMin;
      if (a.endMin   !== b.endMin)   return b.endMin   - a.endMin;
      return String(a.id) < String(b.id) ? -1 : 1;
    });

    const colEnds = [];

    for (const event of sorted) {
      let col = colEnds.findIndex(end => end <= event.startMin);
      if (col === -1) {
        col = colEnds.length;
        colEnds.push(event.endMin);
      } else {
        colEnds[col] = event.endMin;
      }
      colIndexMap.set(event.id, col);
    }

    clusterColCount.set(root, colEnds.length);
  }

  // ── C) Percentage geometry ─────────────────────────────────────────────────
  // Shifts occupy (100 - rightGutterPercent)% of the column width.
  // The rightmost rightGutterPercent% is left empty so clicking there opens
  // the new-shift form without being blocked by a shift element.

  const availableWidth = 100 - rightGutterPercent;

  const results = events.map(event => {
    const root        = find(event.id);
    const columnCount = clusterColCount.get(root);
    const columnIndex = colIndexMap.get(event.id);

    const widthPercent = (availableWidth - gutterPercent * (columnCount - 1)) / columnCount;
    const leftPercent  = columnIndex * (widthPercent + gutterPercent);

    return { ...event, columnIndex, columnCount, leftPercent, widthPercent };
  });

  return { results };
}
