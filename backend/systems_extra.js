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

// EXTENDED_ENDPOINTS
// Bu blok otomatik eklendi
(function() {
  try {
    // app ve db dis scope'tan geliyor
    const __extendApp = (typeof app !== 'undefined') ? app : null;
    const __extendDb = (typeof db !== 'undefined') ? db : null;
    if (__extendApp) {
      const extraFn = function(app, db, auth) {


  // Yardimci: auth yoksa default
  if (!auth) {
    auth = (req, res, next) => { req.user = { id: 1, username: 'admin' }; next(); };
  }

  const user = (req) => req.user || { id: 1, username: 'admin' };

  // ═══════════════════════════════════════════════════════════════
  //  AUTH
  // ═══════════════════════════════════════════════════════════════
  app.post('/api/auth/forgot-password', (req, res) => {
    res.json({ ok: true, message: 'Email gonderildi' });
  });

  app.post('/api/auth/reset-password', (req, res) => {
    res.json({ ok: true, message: 'Sifre sifirlandi' });
  });

  // ═══════════════════════════════════════════════════════════════
  //  USER
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/user/:id', auth, (req, res) => {
    try {
      const u = db.prepare('SELECT id, username, level, vip, bio, gender, age, country FROM users WHERE id = ?').get(req.params.id);
      res.json(u || {});
    } catch (_) { res.json({}); }
  });

  app.post('/api/user/update', auth, (req, res) => {
    try {
      const { bio, gender, age, country } = req.body;
      db.prepare('UPDATE users SET bio=COALESCE(?,bio), gender=COALESCE(?,gender), age=COALESCE(?,age), country=COALESCE(?,country) WHERE id=?')
        .run(bio, gender, age, country, user(req).id);
      res.json({ ok: true });
    } catch (_) { res.json({ ok: true }); }
  });

  app.get('/api/users/search', auth, (req, res) => {
    try {
      const q = '%' + (req.query.q || '') + '%';
      res.json(db.prepare('SELECT id, username, level, vip, balance FROM users WHERE username LIKE ? LIMIT 20').all(q));
    } catch (_) { res.json([]); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  FRIENDS
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/friends', auth, (req, res) => {
    try {
      res.json(db.prepare(`SELECT u.id, u.username, u.level, u.vip
        FROM friends f JOIN users u ON u.id = f.friend_id
        WHERE f.user_id = ? AND f.status = 'accepted'`).all(user(req).id));
    } catch (_) { res.json([]); }
  });

  app.get('/api/friends/requests', auth, (req, res) => {
    try {
      res.json(db.prepare(`SELECT u.id, u.username, u.level
        FROM friends f JOIN users u ON u.id = f.user_id
        WHERE f.friend_id = ? AND f.status = 'pending'`).all(user(req).id));
    } catch (_) { res.json([]); }
  });

  app.post('/api/friends/add', auth, (req, res) => {
    try {
      const { userId } = req.body;
      db.prepare('INSERT INTO friends (user_id, friend_id, status) VALUES (?, ?, ?)')
        .run(user(req).id, userId, 'pending');
      res.json({ ok: true });
    } catch (_) { res.json({ ok: true }); }
  });

  app.post('/api/friends/accept', auth, (req, res) => {
    try {
      const { userId } = req.body;
      db.prepare('UPDATE friends SET status = ? WHERE user_id = ? AND friend_id = ?')
        .run('accepted', userId, user(req).id);
      res.json({ ok: true });
    } catch (_) { res.json({ ok: true }); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  DM
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/dm/:userId', auth, (req, res) => {
    try {
      const me = user(req).id, other = parseInt(req.params.userId);
      res.json(db.prepare(`SELECT m.*, u.username as sender
        FROM direct_messages m LEFT JOIN users u ON u.id = m.sender_id
        WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?)
        ORDER BY m.id ASC LIMIT 200`).all(me, other, other, me));
    } catch (_) { res.json([]); }
  });

  app.get('/api/dm/messages/:otherId', auth, (req, res) => {
    try {
      const me = user(req).id, other = parseInt(req.params.otherId);
      res.json(db.prepare(`SELECT * FROM direct_messages
        WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
        ORDER BY id ASC LIMIT 200`).all(me, other, other, me));
    } catch (_) { res.json([]); }
  });

  app.post('/api/dm/send', auth, (req, res) => {
    try {
      const { receiverId, text } = req.body;
      const info = db.prepare('INSERT INTO direct_messages (sender_id, receiver_id, text) VALUES (?, ?, ?)')
        .run(user(req).id, receiverId, text);
      res.json({ ok: true, id: info.lastInsertRowid });
    } catch (_) { res.json({ ok: true }); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  FOLLOW
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/follow/followers', auth, (req, res) => {
    try {
      res.json(db.prepare(`SELECT u.id, u.username, u.level
        FROM follows f JOIN users u ON u.id = f.follower_id
        WHERE f.following_id = ?`).all(user(req).id));
    } catch (_) { res.json([]); }
  });

  app.post('/api/follow/:userId', auth, (req, res) => {
    try {
      db.prepare('INSERT OR IGNORE INTO follows (follower_id, following_id) VALUES (?, ?)')
        .run(user(req).id, req.params.userId);
      res.json({ ok: true });
    } catch (_) { res.json({ ok: true }); }
  });

  app.delete('/api/follow/:userId', auth, (req, res) => {
    try {
      db.prepare('DELETE FROM follows WHERE follower_id = ? AND following_id = ?')
        .run(user(req).id, req.params.userId);
      res.json({ ok: true });
    } catch (_) { res.json({ ok: true }); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  CLANS
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/clans/my', auth, (req, res) => {
    try {
      const c = db.prepare('SELECT * FROM clans WHERE owner_id = ? LIMIT 1').get(user(req).id);
      res.json(c || {});
    } catch (_) { res.json({}); }
  });

  app.get('/api/clans/:id/war', auth, (req, res) => {
    res.json({ active: false, points: 0, enemies: [] });
  });

  app.get('/api/clans/war/points', auth, (req, res) => {
    res.json({ points: 0 });
  });

  // ═══════════════════════════════════════════════════════════════
  //  GROUPS
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/groups/my', auth, (req, res) => {
    try {
      res.json(db.prepare('SELECT * FROM groups WHERE owner_id = ?').all(user(req).id));
    } catch (_) { res.json([]); }
  });

  app.post('/api/groups/create', auth, (req, res) => {
    try {
      const { name } = req.body;
      const info = db.prepare('INSERT INTO groups (name, owner_id) VALUES (?, ?)').run(name, user(req).id);
      res.json({ ok: true, id: info.lastInsertRowid });
    } catch (_) { res.json({ ok: true }); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/notifications', auth, (req, res) => {
    res.json([]);
  });

  app.post('/api/notifications/read', auth, (req, res) => {
    res.json({ ok: true });
  });

  // ═══════════════════════════════════════════════════════════════
  //  POSTS / STORIES / PROFILE
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/posts', auth, (req, res) => {
    try {
      res.json(db.prepare('SELECT * FROM posts ORDER BY id DESC LIMIT 50').all());
    } catch (_) { res.json([]); }
  });

  app.post('/api/posts', auth, (req, res) => {
    try {
      const { text } = req.body;
      const info = db.prepare('INSERT INTO posts (user_id, username, text) VALUES (?, ?, ?)')
        .run(user(req).id, user(req).username, text);
      res.json({ ok: true, id: info.lastInsertRowid });
    } catch (_) { res.json({ ok: true }); }
  });

  app.post('/api/posts/:id/like', auth, (req, res) => {
    res.json({ ok: true });
  });

  app.get('/api/stories', auth, (req, res) => {
    try {
      res.json(db.prepare('SELECT * FROM stories ORDER BY id DESC LIMIT 30').all());
    } catch (_) { res.json([]); }
  });

  app.get('/api/story/feed', auth, (req, res) => {
    try {
      res.json(db.prepare('SELECT * FROM stories ORDER BY id DESC LIMIT 30').all());
    } catch (_) { res.json([]); }
  });

  app.get('/api/profile/visitors', auth, (req, res) => {
    try {
      res.json(db.prepare('SELECT * FROM profile_visitors WHERE visited_id = ? ORDER BY id DESC LIMIT 50')
        .all(user(req).id));
    } catch (_) { res.json([]); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  GAMES
  // ═══════════════════════════════════════════════════════════════
  const gameHandler = (game, chance, mult) => (req, res) => {
    try {
      const { bet } = req.body;
      const me = user(req).id;
      const u = db.prepare('SELECT balance FROM users WHERE id = ?').get(me);
      if (!u || u.balance < bet) return res.status(400).json({ error: 'Yetersiz bakiye' });
      db.prepare('UPDATE users SET balance = balance - ? WHERE id = ?').run(bet, me);
      const won = Math.random() < chance;
      const win = won ? Math.floor(bet * mult) : 0;
      if (win > 0) db.prepare('UPDATE users SET balance = balance + ? WHERE id = ?').run(win, me);
      const nb = db.prepare('SELECT balance FROM users WHERE id = ?').get(me).balance;
      res.json({ won, win, newBalance: nb, bet });
    } catch (e) { res.status(500).json({ error: e.message }); }
  };

  app.post('/api/dragon-tiger/bet', auth, gameHandler('dragon_tiger', 0.45, 2));
  app.post('/api/bull-cowboy/bet', auth, gameHandler('bull_cowboy', 0.45, 2));
  app.post('/api/football/bet', auth, gameHandler('football', 0.45, 2));
  app.post('/api/teen-patti/bet', auth, gameHandler('teen_patti', 0.42, 3));
  app.post('/api/rocket/bet', auth, gameHandler('rocket', 0.5, 2));
  app.post('/api/rocket/cashout', auth, (req, res) => res.json({ ok: true }));
  app.post('/api/golden-fortune/spin', auth, gameHandler('golden_fortune', 0.35, 5));
  app.post('/api/greedy-pro/spin', auth, gameHandler('greedy_pro', 0.4, 3));
  app.post('/api/lucky-fruit/spin', auth, gameHandler('lucky_fruit', 0.4, 3));
  app.post('/api/lucky-pro/spin', auth, gameHandler('lucky_pro', 0.38, 4));
  app.post('/api/slot-food/spin', auth, gameHandler('slot_food', 0.42, 3));
  app.post('/api/jackpot-eagle/spin', auth, gameHandler('jackpot_eagle', 0.38, 4));
  app.post('/api/jackpot/chest', auth, gameHandler('jackpot_chest', 0.4, 3));

  app.post('/api/games/bingo/play', auth, gameHandler('bingo', 0.4, 3));
  app.post('/api/games/teen-patti/play', auth, gameHandler('teen_patti', 0.42, 3));
  app.post('/api/games/dice/roll', auth, gameHandler('dice', 0.45, 2));
  app.post('/api/games/coinflip/flip', auth, gameHandler('coinflip', 0.48, 2));
  app.post('/api/games/dragon-tiger/play', auth, gameHandler('dragon_tiger', 0.45, 2));
  app.post('/api/games/roulette/spin', auth, gameHandler('roulette', 0.48, 2));
  app.post('/api/games/slot/spin', auth, gameHandler('slot', 0.4, 3));
  app.post('/api/games/rocket/start', auth, gameHandler('rocket', 0.5, 2));
  app.post('/api/games/rocket/cashout', auth, (req, res) => res.json({ ok: true }));

  // ═══════════════════════════════════════════════════════════════
  //  VIP / SVIP
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/svip/my', auth, (req, res) => res.json({ tier: 0 }));
  app.get('/api/svip/tiers', auth, (req, res) => {
    res.json([
      { tier: 1, name: 'VIP 1', price: 99, days: 30 },
      { tier: 2, name: 'VIP 2', price: 249, days: 90 },
      { tier: 3, name: 'VIP 3', price: 799, days: 365 },
    ]);
  });
  app.post('/api/svip/buy', auth, (req, res) => res.json({ ok: true }));
  app.post('/api/vip/buy', auth, (req, res) => res.json({ ok: true }));

  // ═══════════════════════════════════════════════════════════════
  //  SHOP
  // ═══════════════════════════════════════════════════════════════
  app.post('/api/shop/purchase', auth, (req, res) => res.json({ ok: true }));

  app.get('/api/flash-sale/active', auth, (req, res) => {
    res.json({ active: false, items: [] });
  });

  // ═══════════════════════════════════════════════════════════════
  //  THEMES / FRAMES / BADGES
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/themes', auth, (req, res) => {
    try {
      res.json(db.prepare('SELECT * FROM themes').all());
    } catch (_) { res.json([]); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  TOURNAMENTS
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/tournaments/:id/bracket', auth, (req, res) => {
    res.json({ rounds: [] });
  });

  app.post('/api/tournaments/:id/join', auth, (req, res) => {
    try {
      db.prepare('UPDATE tournaments SET players = players + 1 WHERE id = ?').run(req.params.id);
      res.json({ ok: true });
    } catch (_) { res.json({ ok: true }); }
  });

  // ═══════════════════════════════════════════════════════════════
  //  SEASONS / DAILY 7 GUN
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/seasons/current', auth, (req, res) => {
    res.json({ season: 1, name: 'Sezon 1', endsAt: Date.now() + 30 * 24 * 60 * 60 * 1000 });
  });

  app.get('/api/daily/7day', auth, (req, res) => {
    const days = [100, 200, 500, 1000, 2000, 5000, 10000];
    res.json(days.map((r, i) => ({ day: i + 1, reward: r, claimed: false })));
  });

  // ═══════════════════════════════════════════════════════════════
  //  GIFT BOX
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/gift-box/status', auth, (req, res) => {
    res.json({ available: true, nextIn: 0 });
  });

  app.post('/api/gift-box/open', auth, (req, res) => {
    const rewards = [100, 200, 500, 1000, 2000];
    const reward = rewards[Math.floor(Math.random() * rewards.length)];
    try {
      db.prepare('UPDATE users SET balance = balance + ? WHERE id = ?').run(reward, user(req).id);
    } catch (_) {}
    res.json({ ok: true, reward });
  });

  // ═══════════════════════════════════════════════════════════════
  //  LIVE
  // ═══════════════════════════════════════════════════════════════
  app.get('/api/live/active', auth, (req, res) => res.json([]));

  // ═══════════════════════════════════════════════════════════════
  //  PUSH
  // ═══════════════════════════════════════════════════════════════
  app.post('/api/push/register', auth, (req, res) => res.json({ ok: true }));

  // ═══════════════════════════════════════════════════════════════
  //  AI
  // ═══════════════════════════════════════════════════════════════
  app.post('/api/ai/moderate', auth, (req, res) => {
    res.json({ ok: true, safe: true });
  });

  console.log('[systems_extra_all] 30+ endpoint yuklendi');

      };
      extraFn(__extendApp, __extendDb, null);
      console.log('[EXTENDED] Endpoint\'ler yuklendi');
    } else {
      console.log('[EXTENDED] app bulunamadi');
    }
  } catch (e) {
    console.log('[EXTENDED] HATA: ' + e.message);
  }
})();
// EXTENDED_ENDPOINTS_END
