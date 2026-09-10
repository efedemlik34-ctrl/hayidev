// ═══ KRITIK + SOSYAL + PARA SISTEMLERI ═══
const crypto = require('crypto');

module.exports = function(ctx) {
  const { app, db, io, auth, adminOnly, changeBal, addXp, grantBadge } = ctx;

  db.exec(`
    CREATE TABLE IF NOT EXISTS password_resets (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, code TEXT, expires_at TEXT, used INTEGER DEFAULT 0);
    CREATE TABLE IF NOT EXISTS stories (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, media_url TEXT, caption TEXT, views INTEGER DEFAULT 0, expires_at TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS story_views (story_id INTEGER, user_id INTEGER, viewed_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(story_id, user_id));
    CREATE TABLE IF NOT EXISTS groups_chat (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, owner_id INTEGER, avatar_url TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS group_members (group_id INTEGER, user_id INTEGER, role TEXT DEFAULT 'member', PRIMARY KEY(group_id, user_id));
    CREATE TABLE IF NOT EXISTS group_messages (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER, user_id INTEGER, text TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS profile_visitors (id INTEGER PRIMARY KEY AUTOINCREMENT, visitor_id INTEGER, visited_id INTEGER, visited_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS message_reactions (message_id INTEGER, user_id INTEGER, emoji TEXT, PRIMARY KEY(message_id, user_id));
    CREATE TABLE IF NOT EXISTS flash_sales (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, discount INTEGER, product_key TEXT, ends_at TEXT, active INTEGER DEFAULT 1);
    CREATE TABLE IF NOT EXISTS gift_boxes (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, reward INTEGER, opened_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS svip_tiers (id INTEGER PRIMARY KEY AUTOINCREMENT, level INTEGER, name TEXT, price INTEGER, perks TEXT);
    CREATE TABLE IF NOT EXISTS user_svip (user_id INTEGER PRIMARY KEY, level INTEGER DEFAULT 0, expires_at TEXT);
  `);

  // ═══ 1. SIFREMI UNUTTUM ═══
  app.post('/api/auth/forgot-password', (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'EMAIL_REQUIRED' });
    const u = db.prepare('SELECT id FROM users WHERE email = ?').get(email.toLowerCase());
    if (!u) return res.json({ ok: true, message: 'Eger hesap varsa kod gonderildi' });
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const exp = new Date(Date.now() + 10 * 60000).toISOString();
    db.prepare('INSERT INTO password_resets (email, code, expires_at) VALUES (?, ?, ?)').run(email.toLowerCase(), code, exp);
    console.log('[forgot-password] ' + email + ' -> Kod: ' + code);
    res.json({ ok: true, message: 'Kod gonderildi', code_hint: code });
  });

  app.post('/api/auth/reset-password', async (req, res) => {
    const { email, code, newPassword } = req.body;
    if (!email || !code || !newPassword) return res.status(400).json({ error: 'MISSING' });
    if (newPassword.length < 6) return res.status(400).json({ error: 'WEAK' });
    const r = db.prepare("SELECT * FROM password_resets WHERE email = ? AND code = ? AND used = 0 AND expires_at > datetime('now') ORDER BY id DESC LIMIT 1").get(email.toLowerCase(), code);
    if (!r) return res.status(400).json({ error: 'INVALID_CODE' });
    const bcrypt = require('bcryptjs');
    const hash = await bcrypt.hash(newPassword, 10);
    db.prepare('UPDATE users SET password = ? WHERE email = ?').run(hash, email.toLowerCase());
    db.prepare('UPDATE password_resets SET used = 1 WHERE id = ?').run(r.id);
    res.json({ ok: true });
  });

  // ═══ 2. KULLANICI ARAMA ═══
  app.get('/api/search/users', auth, (req, res) => {
    const { q = '', vip, min_level, limit = 50 } = req.query;
    let sql = 'SELECT id, username, vip, level, frame FROM users WHERE 1=1';
    const params = [];
    if (q) { sql += ' AND username LIKE ?'; params.push('%' + q + '%'); }
    if (vip) { sql += ' AND vip >= ?'; params.push(parseInt(vip)); }
    if (min_level) { sql += ' AND level >= ?'; params.push(parseInt(min_level)); }
    sql += ' ORDER BY vip DESC, level DESC LIMIT ' + Math.min(100, parseInt(limit));
    res.json(db.prepare(sql).all(...params));
  });

  app.get('/api/search/rooms', auth, (req, res) => {
    const { q = '', type } = req.query;
    let sql = 'SELECT r.*, u.username AS owner FROM rooms r JOIN users u ON u.id = r.owner_id WHERE 1=1';
    const params = [];
    if (q) { sql += ' AND r.name LIKE ?'; params.push('%' + q + '%'); }
    if (type) { sql += ' AND r.type = ?'; params.push(type); }
    sql += ' ORDER BY r.id DESC LIMIT 50';
    res.json(db.prepare(sql).all(...params));
  });

  // ═══ 3. KUPON GIRME ═══
  app.post('/api/coupons/redeem', auth, (req, res) => {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: 'NO_CODE' });
    const c = db.prepare('SELECT * FROM coupons WHERE code = ? AND active = 1').get(code.toUpperCase());
    if (!c) return res.status(404).json({ error: 'INVALID_CODE' });
    if (c.max_uses > 0 && c.used >= c.max_uses) return res.status(400).json({ error: 'MAX_USES' });
    const already = db.prepare('SELECT 1 FROM coupon_uses WHERE coupon_id = ? AND user_id = ?').get(c.id, req.uid);
    if (already) return res.status(400).json({ error: 'ALREADY_USED' });
    db.prepare('INSERT INTO coupon_uses (coupon_id, user_id) VALUES (?, ?)').run(c.id, req.uid);
    db.prepare('UPDATE coupons SET used = used + 1 WHERE id = ?').run(c.id);
    if (c.reward_type === 'coin') changeBal(req.uid, c.reward_value, 'coupon', c.code);
    res.json({ ok: true, reward: c.reward_value, type: c.reward_type });
  });

  // ═══ 4. 7 GUNLUK SARJ ═══
  const DAILY_REWARDS = [
    { day: 1, reward: 1000, icon: '🎁' },
    { day: 2, reward: 2000, icon: '💰' },
    { day: 3, reward: 5000, icon: '💎' },
    { day: 4, reward: 10000, icon: '🏆' },
    { day: 5, reward: 25000, icon: '👑' },
    { day: 6, reward: 50000, icon: '🌟' },
    { day: 7, reward: 150000, icon: '🔥' },
  ];
  app.get('/api/daily/7day', auth, (req, res) => {
    const d = db.prepare('SELECT * FROM daily WHERE user_id = ?').get(req.uid) || { streak: 0 };
    res.json({ rewards: DAILY_REWARDS, currentDay: (d.streak % 7) + 1, streak: d.streak });
  });

  // ═══ 5. FLASH INDIRIM ═══
  app.get('/api/flash-sale/active', auth, (req, res) => {
    const rows = db.prepare("SELECT * FROM flash_sales WHERE active = 1 AND (ends_at IS NULL OR ends_at > datetime('now')) ORDER BY id DESC LIMIT 5").all();
    res.json(rows);
  });

  // ═══ 6. HEDIYE KUTUSU ═══
  app.post('/api/gift-box/open', auth, (req, res) => {
    const today = new Date().toISOString().slice(0, 10);
    const opened = db.prepare("SELECT 1 FROM gift_boxes WHERE user_id = ? AND DATE(opened_at) = ?").get(req.uid, today);
    if (opened) return res.status(400).json({ error: 'ALREADY_OPENED' });
    const rewards = [500, 1000, 2000, 5000, 10000, 25000, 100000];
    const weights = [30, 25, 20, 12, 8, 4, 1];
    let total = weights.reduce((a, b) => a + b);
    let r = Math.random() * total;
    let pick = rewards[0];
    for (let i = 0; i < rewards.length; i++) {
      r -= weights[i];
      if (r <= 0) { pick = rewards[i]; break; }
    }
    db.prepare('INSERT INTO gift_boxes (user_id, reward) VALUES (?, ?)').run(req.uid, pick);
    changeBal(req.uid, pick, 'gift_box', 'daily');
    res.json({ reward: pick });
  });

  app.get('/api/gift-box/status', auth, (req, res) => {
    const today = new Date().toISOString().slice(0, 10);
    const opened = db.prepare("SELECT reward FROM gift_boxes WHERE user_id = ? AND DATE(opened_at) = ?").get(req.uid, today);
    res.json({ canOpen: !opened, lastReward: opened ? opened.reward : null });
  });

  // ═══ 7. SVIP 3 SEVIYE ═══
  const SVIP_TIERS = [
    { level: 1, name: 'SVIP 1', price: 500000, perks: 'Aylik 500K coin + sari isim' },
    { level: 2, name: 'SVIP 2', price: 1500000, perks: 'Aylik 2M coin + turuncu isim + ozel cerceve' },
    { level: 3, name: 'SVIP 3', price: 5000000, perks: 'Aylik 10M coin + kirmizi isim + tum odalar' },
  ];
  app.get('/api/svip/tiers', (req, res) => res.json(SVIP_TIERS));
  app.get('/api/svip/my', auth, (req, res) => {
    const r = db.prepare('SELECT * FROM user_svip WHERE user_id = ?').get(req.uid);
    res.json(r || { level: 0 });
  });
  app.post('/api/svip/buy', auth, (req, res) => {
    const { level } = req.body;
    const t = SVIP_TIERS.find(x => x.level === level);
    if (!t) return res.status(400).json({ error: 'INVALID' });
    try {
      changeBal(req.uid, -t.price, 'svip_buy', 'svip_' + level);
      const exp = new Date(Date.now() + 30 * 86400000).toISOString();
      db.prepare('INSERT OR REPLACE INTO user_svip (user_id, level, expires_at) VALUES (?, ?, ?)').run(req.uid, level, exp);
      res.json({ ok: true, level, expires_at: exp });
    } catch (e) { res.status(400).json({ error: e.message }); }
  });

  // ═══ 8. STORY / HIKAYE ═══
  app.post('/api/story/create', auth, (req, res) => {
    const { media_url, caption } = req.body;
    if (!media_url) return res.status(400).json({ error: 'NO_MEDIA' });
    const exp = new Date(Date.now() + 24 * 3600000).toISOString();
    const r = db.prepare('INSERT INTO stories (user_id, media_url, caption, expires_at) VALUES (?, ?, ?, ?)').run(req.uid, media_url, caption || '', exp);
    res.json({ ok: true, id: r.lastInsertRowid });
  });

  app.get('/api/story/feed', auth, (req, res) => {
    const rows = db.prepare(`
      SELECT s.*, u.username, u.avatar_url, u.frame,
        (SELECT COUNT(*) FROM story_views WHERE story_id = s.id) AS view_count,
        (SELECT COUNT(*) FROM story_views WHERE story_id = s.id AND user_id = ?) AS seen
      FROM stories s JOIN users u ON u.id = s.user_id
      WHERE s.expires_at > datetime('now')
      ORDER BY s.created_at DESC LIMIT 50
    `).all(req.uid);
    res.json(rows);
  });

  app.post('/api/story/:id/view', auth, (req, res) => {
    try {
      db.prepare('INSERT OR IGNORE INTO story_views (story_id, user_id) VALUES (?, ?)').run(req.params.id, req.uid);
      db.prepare('UPDATE stories SET views = views + 1 WHERE id = ?').run(req.params.id);
      res.json({ ok: true });
    } catch (e) { res.status(400).json({ error: e.message }); }
  });

  app.get('/api/story/my', auth, (req, res) => {
    const rows = db.prepare('SELECT * FROM stories WHERE user_id = ? AND expires_at > datetime(\'now\') ORDER BY id DESC').all(req.uid);
    res.json(rows);
  });

  // ═══ 9. GRUP SOHBET ═══
  app.post('/api/groups/create', auth, (req, res) => {
    const { name, member_ids = [] } = req.body;
    if (!name) return res.status(400).json({ error: 'NO_NAME' });
    const r = db.prepare('INSERT INTO groups_chat (name, owner_id) VALUES (?, ?)').run(name, req.uid);
    const gid = r.lastInsertRowid;
    db.prepare('INSERT INTO group_members (group_id, user_id, role) VALUES (?, ?, ?)').run(gid, req.uid, 'owner');
    for (const mid of member_ids) {
      try { db.prepare('INSERT INTO group_members (group_id, user_id) VALUES (?, ?)').run(gid, mid); } catch (_) {}
    }
    res.json({ ok: true, groupId: gid });
  });

  app.get('/api/groups/my', auth, (req, res) => {
    const rows = db.prepare(`
      SELECT g.*, (SELECT COUNT(*) FROM group_members WHERE group_id = g.id) AS member_count,
        (SELECT text FROM group_messages WHERE group_id = g.id ORDER BY id DESC LIMIT 1) AS last_msg
      FROM groups_chat g
      JOIN group_members gm ON gm.group_id = g.id
      WHERE gm.user_id = ?
      ORDER BY g.id DESC
    `).all(req.uid);
    res.json(rows);
  });

  app.get('/api/groups/:id/messages', auth, (req, res) => {
    const isMember = db.prepare('SELECT 1 FROM group_members WHERE group_id = ? AND user_id = ?').get(req.params.id, req.uid);
    if (!isMember) return res.status(403).json({ error: 'NOT_MEMBER' });
    const rows = db.prepare('SELECT m.*, u.username, u.avatar_url FROM group_messages m JOIN users u ON u.id = m.user_id WHERE m.group_id = ? ORDER BY m.id DESC LIMIT 100').all(req.params.id);
    res.json(rows.reverse());
  });

  app.post('/api/groups/:id/send', auth, (req, res) => {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'NO_TEXT' });
    const isMember = db.prepare('SELECT 1 FROM group_members WHERE group_id = ? AND user_id = ?').get(req.params.id, req.uid);
    if (!isMember) return res.status(403).json({ error: 'NOT_MEMBER' });
    const r = db.prepare('INSERT INTO group_messages (group_id, user_id, text) VALUES (?, ?, ?)').run(req.params.id, req.uid, text);
    const u = db.prepare('SELECT username FROM users WHERE id = ?').get(req.uid);
    io.to('group_' + req.params.id).emit('group:new', {
      id: r.lastInsertRowid, groupId: req.params.id, userId: req.uid,
      username: u.username, text, ts: Date.now()
    });
    res.json({ ok: true });
  });

  // ═══ 10. PROFIL ZIYARET ═══
  app.post('/api/profile/visit/:userId', auth, (req, res) => {
    const target = parseInt(req.params.userId);
    if (target === req.uid) return res.json({ ok: true });
    db.prepare('INSERT INTO profile_visitors (visitor_id, visited_id) VALUES (?, ?)').run(req.uid, target);
    res.json({ ok: true });
  });

  app.get('/api/profile/visitors', auth, (req, res) => {
    const rows = db.prepare(`
      SELECT DISTINCT u.id, u.username, u.avatar_url, u.vip, u.level, u.frame,
        (SELECT MAX(visited_at) FROM profile_visitors WHERE visitor_id = u.id AND visited_id = ?) AS last_visit
      FROM profile_visitors pv JOIN users u ON u.id = pv.visitor_id
      WHERE pv.visited_id = ?
      ORDER BY last_visit DESC LIMIT 50
    `).all(req.uid, req.uid);
    res.json(rows);
  });

  app.get('/api/profile/visit-count/:userId?', auth, (req, res) => {
    const uid = parseInt(req.params.userId) || req.uid;
    const c = db.prepare('SELECT COUNT(DISTINCT visitor_id) AS c FROM profile_visitors WHERE visited_id = ?').get(uid);
    res.json({ count: c.c });
  });

  // ═══ 11. MESAJ EMOJI TEPKI ═══
  app.post('/api/messages/reaction', auth, (req, res) => {
    const { messageId, emoji } = req.body;
    if (!messageId || !emoji) return res.status(400).json({ error: 'MISSING' });
    try {
      db.prepare('INSERT OR REPLACE INTO message_reactions (message_id, user_id, emoji) VALUES (?, ?, ?)').run(messageId, req.uid, emoji);
      res.json({ ok: true });
    } catch (e) { res.status(400).json({ error: e.message }); }
  });

  app.get('/api/messages/:id/reactions', auth, (req, res) => {
    const rows = db.prepare('SELECT emoji, COUNT(*) AS count FROM message_reactions WHERE message_id = ? GROUP BY emoji').all(req.params.id);
    res.json(rows);
  });

  console.log('[systems_extra] KRITIK + SOSYAL + PARA sistemleri yuklendi');
};
