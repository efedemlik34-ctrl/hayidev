// ═══ Direkt Mesajlasma (DM) Sistemi ═══
module.exports = function setup(ctx) {
  const { app, db, io, auth, adminOnly } = ctx;

  db.exec(`
    CREATE TABLE IF NOT EXISTS dm_conversations (id INTEGER PRIMARY KEY AUTOINCREMENT, user1 INTEGER, user2 INTEGER, last_msg TEXT, last_at TEXT DEFAULT CURRENT_TIMESTAMP, UNIQUE(user1, user2));
    CREATE TABLE IF NOT EXISTS dm_messages (id INTEGER PRIMARY KEY AUTOINCREMENT, conversation_id INTEGER, from_id INTEGER, to_id INTEGER, text TEXT, is_read INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
  `);

  function findOrCreateConv(a, b) {
    const [u1, u2] = a < b ? [a, b] : [b, a];
    let conv = db.prepare('SELECT * FROM dm_conversations WHERE user1 = ? AND user2 = ?').get(u1, u2);
    if (!conv) {
      const r = db.prepare('INSERT INTO dm_conversations (user1, user2) VALUES (?, ?)').run(u1, u2);
      conv = db.prepare('SELECT * FROM dm_conversations WHERE id = ?').get(r.lastInsertRowid);
    }
    return conv;
  }

  // Konusma listesi
  app.get('/api/dm/conversations', auth, (req, res) => {
    const rows = db.prepare(`
      SELECT c.*, 
        CASE WHEN c.user1 = ? THEN c.user2 ELSE c.user1 END AS other_id,
        (SELECT username FROM users WHERE id = CASE WHEN c.user1 = ? THEN c.user2 ELSE c.user1 END) AS other_username,
        (SELECT avatar_url FROM users WHERE id = CASE WHEN c.user1 = ? THEN c.user2 ELSE c.user1 END) AS other_avatar,
        (SELECT COUNT(*) FROM dm_messages WHERE conversation_id = c.id AND to_id = ? AND is_read = 0) AS unread
      FROM dm_conversations c
      WHERE c.user1 = ? OR c.user2 = ?
      ORDER BY c.last_at DESC LIMIT 100
    `).all(req.uid, req.uid, req.uid, req.uid, req.uid, req.uid);
    res.json(rows);
  });

  // Mesajlari al
  app.get('/api/dm/messages/:otherId', auth, (req, res) => {
    const otherId = parseInt(req.params.otherId);
    const conv = findOrCreateConv(req.uid, otherId);
    const msgs = db.prepare(`
      SELECT m.*, u.username AS from_username FROM dm_messages m
      LEFT JOIN users u ON u.id = m.from_id
      WHERE m.conversation_id = ?
      ORDER BY m.id DESC LIMIT 100
    `).all(conv.id);
    db.prepare('UPDATE dm_messages SET is_read = 1 WHERE conversation_id = ? AND to_id = ?').run(conv.id, req.uid);
    res.json(msgs.reverse());
  });

  // Mesaj gonder
  app.post('/api/dm/send', auth, (req, res) => {
    const { toId, text } = req.body;
    if (!toId || !text || text.length > 1000) return res.status(400).json({ error: 'INVALID' });
    if (toId === req.uid) return res.status(400).json({ error: 'SELF' });
    const conv = findOrCreateConv(req.uid, toId);
    const r = db.prepare('INSERT INTO dm_messages (conversation_id, from_id, to_id, text) VALUES (?, ?, ?, ?)')
      .run(conv.id, req.uid, toId, text);
    db.prepare('UPDATE dm_conversations SET last_msg = ?, last_at = CURRENT_TIMESTAMP WHERE id = ?').run(text.slice(0, 50), conv.id);
    const u = db.prepare('SELECT username FROM users WHERE id = ?').get(req.uid);
    io.to('user_' + toId).emit('dm:new', {
      conversationId: conv.id, fromId: req.uid, fromUsername: u.username,
      text, ts: Date.now()
    });
    res.json({ ok: true, id: r.lastInsertRowid });
  });

  // Okunmamis toplam
  app.get('/api/dm/unread', auth, (req, res) => {
    const r = db.prepare('SELECT COUNT(*) AS c FROM dm_messages WHERE to_id = ? AND is_read = 0').get(req.uid);
    res.json({ count: r.c });
  });

  // Kullanici sil (mesaji sil)
  app.delete('/api/dm/message/:id', auth, (req, res) => {
    db.prepare('DELETE FROM dm_messages WHERE id = ? AND from_id = ?').run(req.params.id, req.uid);
    res.json({ ok: true });
  });

  console.log('[systems_dm] DM sistemi yuklendi');
};
