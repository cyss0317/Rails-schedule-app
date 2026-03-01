/**
 * layoutDayEvents
 *
 * Assigns columnIndex, columnCount, leftPx, and widthPx to each event using
 * a Microsoft Teams/Outlook-style greedy interval-column layout.
 *
 * Overlap rule: A overlaps B iff (A.startMin < B.endMin) && (B.startMin < A.endMin)
 * Events touching exactly at an endpoint (end == start) do NOT overlap.
 *
 * ─────────────────────────── ACCEPTANCE TESTS ───────────────────────────────
 *
 * 1) Only A (300–1320):
 *      A → columnIndex=0, columnCount=1, leftPx=0, widthPx=containerWidth
 *
 * 2) A (300–1320), B (300–960):
 *      Both overlap → cluster {A,B}, 2 columns.
 *      Sort: A first (longer duration at same start).
 *      A → col 0, B → col 1.
 *
 * 3) A (300–1320), B (300–960), C (960–1320):
 *      B.endMin == C.startMin → B and C do NOT directly overlap.
 *      But A overlaps both → cluster {A, B, C}, 2 columns.
 *      Sort: [A, B, C].
 *      A → col 0  (colEnds=[1320])
 *      B → col 1  (colEnds=[1320, 960])
 *      C → reuses col 1 (960 <= 960)  (colEnds=[1320, 1320])
 *      => B.columnIndex == C.columnIndex == 1, A.columnIndex == 0.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * @param {Array<{ id: string, startMin: number, endMin: number }>} events
 * @param {{ containerWidth?: number, gutter?: number, minWidth?: number }} options
 * @returns {{ results: Array<{ id, startMin, endMin, columnIndex, columnCount, leftPx, widthPx }>, needsHorizontalScroll: boolean }}
 */
export function layoutDayEvents(events, options = {}) {
  const containerWidth = options.containerWidth ?? 320;
  const gutter         = options.gutter        ?? 0;
  const minWidth       = options.minWidth       ?? 0;

  if (events.length === 0) {
    return { results: [], needsHorizontalScroll: false };
  }

  // ── A) Connected conflict components via union-find ────────────────────────
  // Two events belong to the same cluster if they overlap directly OR through
  // a chain of overlaps.  Union-find handles transitivity automatically.

  const parent = new Map(events.map(e => [e.id, e.id]));

  function find(id) {
    if (parent.get(id) !== id) parent.set(id, find(parent.get(id))); // path compression
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

  // Group events by cluster root.
  const clusters = new Map();
  for (const event of events) {
    const root = find(event.id);
    if (!clusters.has(root)) clusters.set(root, []);
    clusters.get(root).push(event);
  }

  // ── B & C) Greedy column assignment per cluster ────────────────────────────

  const colIndexMap     = new Map(); // event.id → column index
  const clusterColCount = new Map(); // cluster root → total columns used

  for (const [root, cluster] of clusters) {
    // Sort: startMin asc, then longer duration first (endMin desc), then id.
    const sorted = [...cluster].sort((a, b) => {
      if (a.startMin !== b.startMin) return a.startMin - b.startMin;
      if (a.endMin   !== b.endMin)   return b.endMin   - a.endMin;   // longer first
      return a.id < b.id ? -1 : 1;
    });

    // colEnds[c] = endMin of the last event placed in column c.
    const colEnds = [];

    for (const event of sorted) {
      // Place in the lowest column already available (colEnds[c] <= startMin).
      let col = colEnds.findIndex(end => end <= event.startMin);
      if (col === -1) {
        col = colEnds.length; // open a new column
        colEnds.push(event.endMin);
      } else {
        colEnds[col] = event.endMin;
      }
      colIndexMap.set(event.id, col);
    }

    clusterColCount.set(root, colEnds.length);
  }

  // ── D) Pixel geometry ─────────────────────────────────────────────────────

  let needsHorizontalScroll = false;

  const results = events.map(event => {
    const root        = find(event.id);
    const columnCount = clusterColCount.get(root);
    const columnIndex = colIndexMap.get(event.id);

    // Distribute containerWidth evenly across columns with gutters in between.
    const widthPx = Math.floor(
      (containerWidth - gutter * (columnCount - 1)) / columnCount
    );
    const leftPx = columnIndex * (widthPx + gutter);

    if (widthPx < minWidth) needsHorizontalScroll = true;

    return { ...event, columnIndex, columnCount, leftPx, widthPx };
  });

  return { results, needsHorizontalScroll };
}
