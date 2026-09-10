// ═══ 8 Sistem: AI + Push + OAuth + Analytics + Voice + Leaderboard ═══
module.exports = function(ctx) {
  const { app, db, io, auth, adminOnly, changeBal, addXp } = ctx;
  const jwt = require('jsonwebtoken');
  const bcrypt = require('bcryptjs');
  const SECRET = 'hayidev-secret-2026';

  db.exec(`
    CREATE TABLE IF NOT EXISTS ai_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, type TEXT, input TEXT, output TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS behavior (user_id INTEGER PRIMARY KEY, segment TEXT DEFAULT 'newbie', loyalty_score INTEGER DEFAULT 0, last_active TEXT);
    CREATE TABLE IF NOT EXISTS push_tokens (user_id INTEGER, token TEXT, platform TEXT DEFAULT 'android', PRIMARY KEY(user_id, token));
    CREATE TABLE IF NOT EXISTS oauth_accounts (user_id INTEGER, provider TEXT, external_id TEXT, email TEXT, PRIMARY KEY(provider, external_id));
    CREATE TABLE IF NOT EXISTS voice_effects (user_id INTEGER PRIMARY KEY, effect TEXT DEFAULT 'none');
    CREATE TABLE IF NOT EXISTS analytics_events (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, event TEXT, meta TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
  `);

  // 44: AI Chat Bot
  const TOXIC = ['aptal','salak','gerizekali','orospu','yavsak','amk','siktir','pic'];
  const FAQ = {
    'nasil oynanir': 'Oyunlar sekmesinden birini sec, bahsi belirle ve OYNA butonuna bas!',
    'hediye': 'Hediye katalogu 800+ hediye iceriyor.',
    'vip': 'VIP 5 seviye var. Gunluk odul bonusu kazandirir.',
    'bakiye': 'Gunluk odul, oyun kazanclari veya davet ile arttir.',
    'davet': 'Profil -> Davet Et menusunden kodunu paylas. Her davet 5000 coin!',
    'yardim': 'Oyunlar, hediye, vip, davet hakkinda sorabilirsin.'
  };

  app.post('/api/ai/moderate', auth, (req, res) => {
    const t = req.body.text || '';
    const lower = t.toLowerCase();
    const found = TOXIC.find(w => lower.indexOf(w) >= 0);
    if (found) {
      db.prepare('INSERT INTO ai_logs (user_id, type, input) VALUES (?, ?, ?)').run(req.uid, 'block', t);
      return res.json({ clean: false, reason: 'TOXIC' });
    }
    res.json({ clean: true });
  });

  app.post('/api/ai/welcome', auth, (req, res) => {
    const u = db.prepare('SELECT username FROM users WHERE id = ?').get(req.uid);
    const msgs = ['Hos geldin ' + u.username + '!', 'Merhaba ' + u.username + '!', 'Selam ' + u.username + '!'];
    res.json({ welcome: msgs[Math.floor(Math.random() * 3)] });
  });

  app.post('/api/ai/ask', auth, (req, res) => {
    const q = (req.body.question || '').toLowerCase();
    let answer = 'Bilgim yok. Oyunlar, hediye, vip, davet hakkinda sorabilirsin.';
    for (const k of Object.keys(FAQ)) {
      if (q.indexOf(k) >= 0) { answer = FAQ[k]; break; }
    }
    db.prepare('INSERT INTO ai_logs (user_id, type, input, output) VALUES (?, ?, ?, ?)').run(req.uid, 'ask', req.body.question, answer);
    addXp(req.uid, 2);
    res.json({ answer });
  });

  // 45: AI Gift Suggest
  app.get('/api/ai/gift-suggest/:targetId', auth, (req, res) => {
    const target = db.prepare('SELECT username, vip FROM users WHERE id = ?').get(req.params.targetId);
    if (!target) return res.status(404).json({ error: 'NOT_FOUND' });
    const gifts = [
      { key: 'rose', name: 'Gul', icon: '🌹', price: 100 },
      { key: 'cake', name: 'Pasta', icon: '🎂', price: 2000 },
      { key: 'car', name: 'Araba', icon: '🚗', price: 50000 },
      { key: 'dragon', name: 'Ejderha', icon: '🐉', price: 500000 },
      { key: 'crown', name: 'Tac', icon: '👑', price: 1000000 }
    ];
    const suggestions = gifts.slice(0, 3).map(g => ({ key: g.key, name: g.name, icon: g.icon, price: g.price }));
    res.json({ target: target.username, suggestions });
  });

  // 46: Behavior Analytics
  app.get('/api/analytics/behavior/:userId?', auth, (req, res) => {
    const uid = parseInt(req.params.userId) || req.uid;
    const g = db.prepare("SELECT COUNT(*) FILTER (WHERE type = \'bet\') AS bets, COUNT(*) FILTER (WHERE amount > 0) AS wins FROM tx WHERE user_id = ?").get(uid);
    const msgs = db.prepare('SELECT COUNT(*) AS c FROM messages WHERE user_id = ?').get(uid).c;
    const winRate = g.bets > 0 ? Math.round(g.wins / g.bets * 100) : 0;
    let seg = 'newbie';
    if (g.bets > 200) seg = 'high_roller';
    else if (g.bets > 100) seg = 'active';
    else if (msgs > 500) seg = 'social';
    const score = Math.min(100, g.bets / 10 + msgs / 50);
    db.prepare('INSERT INTO behavior (user_id, segment, loyalty_score, last_active) VALUES (?, ?, ?, ?) ON CONFLICT(user_id) DO UPDATE SET segment = excluded.segment, loyalty_score = excluded.loyalty_score').run(uid, seg, Math.round(score), new Date().toISOString());
    res.json({ userId: uid, segment: seg, winRate, bets: g.bets, wins: g.wins, messages: msgs, loyaltyScore: Math.round(score) });
  });

  app.get('/api/analytics/segments', auth, adminOnly, (req, res) => {
    res.json(db.prepare('SELECT segment, COUNT(*) AS count FROM behavior GROUP BY segment').all());
  });

  // 47: Push Notifications
  app.post('/api/push/register', auth, (req, res) => {
    const { token, platform } = req.body;
    if (!token) return res.status(400).json({ error: 'NO_TOKEN' });
    db.prepare('INSERT OR REPLACE INTO push_tokens (user_id, token, platform) VALUES (?, ?, ?)').run(req.uid, token, platform || 'android');
    res.json({ ok: true });
  });

  app.post('/api/push/send', auth, adminOnly, (req, res) => {
    const { userId, title, body } = req.body;
    if (!title || !body) return res.status(400).json({ error: 'MISSING' });
    if (userId) {
      db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(userId, 'push', title, body);
      io.to('user_' + userId).emit('push', { title, body });
    } else {
      const all = db.prepare('SELECT id FROM users LIMIT 10000').all();
      all.forEach(u => {
        db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(u.id, 'push', title, body);
        io.to('user_' + u.id).emit('push', { title, body });
      });
    }
    res.json({ ok: true });
  });

  app.post('/api/push/test', auth, (req, res) => {
    db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(req.uid, 'push', 'Test', 'HayiDev test bildirimi');
    io.to('user_' + req.uid).emit('push', { title: 'Test', body: 'Bildirim calisiyor!' });
    res.json({ ok: true });
  });

  // 48: OAuth
  app.post('/api/oauth/google', async (req, res) => {
    const { email, name, googleId } = req.body;
    if (!email || !googleId) return res.status(400).json({ error: 'MISSING' });
    let u = db.prepare('SELECT * FROM users WHERE email = ?').get(email.toLowerCase());
    let isNew = false;
    if (!u) {
      const h = await bcrypt.hash('oauth_' + googleId, 10);
      const un = (name || email.split('@')[0]).replace(/[^a-z0-9]/gi, '').slice(0, 15) + Math.floor(Math.random() * 9999);
      const r = db.prepare('INSERT INTO users (email, username, password) VALUES (?, ?, ?)').run(email.toLowerCase(), un, h);
      u = db.prepare('SELECT * FROM users WHERE id = ?').get(r.lastInsertRowid);
      isNew = true;
    }
    db.prepare('INSERT OR REPLACE INTO oauth_accounts (user_id, provider, external_id, email) VALUES (?, ?, ?, ?)').run(u.id, 'google', googleId, email);
    res.json({ token: jwt.sign({ id: u.id }, SECRET, { expiresIn: '30d' }), user: { id: u.id, username: u.username, email: u.email }, isNew });
  });

  app.post('/api/oauth/apple', async (req, res) => {
    const { email, appleId, name } = req.body;
    if (!appleId) return res.status(400).json({ error: 'MISSING' });
    const emailKey = (email || 'apple_' + appleId + '@hayidev.local').toLowerCase();
    let u = db.prepare('SELECT * FROM users WHERE email = ?').get(emailKey);
    let isNew = false;
    if (!u) {
      const h = await bcrypt.hash('oauth_' + appleId, 10);
      const un = (name || 'user').replace(/[^a-z0-9]/gi, '').slice(0, 15) + Math.floor(Math.random() * 9999);
      const r = db.prepare('INSERT INTO users (email, username, password) VALUES (?, ?, ?)').run(emailKey, un, h);
      u = db.prepare('SELECT * FROM users WHERE id = ?').get(r.lastInsertRowid);
      isNew = true;
    }
    db.prepare('INSERT OR REPLACE INTO oauth_accounts (user_id, provider, external_id, email) VALUES (?, ?, ?, ?)').run(u.id, 'apple', appleId, emailKey);
    res.json({ token: jwt.sign({ id: u.id }, SECRET, { expiresIn: '30d' }), user: { id: u.id, username: u.username, email: u.email }, isNew });
  });

  app.get('/api/oauth/accounts', auth, (req, res) => {
    res.json(db.prepare('SELECT provider, email FROM oauth_accounts WHERE user_id = ?').all(req.uid));
  });

  // 49: Voice Effects
  const EFFECTS = ['none', 'robot', 'chipmunk', 'deep', 'child', 'grandpa', 'alien', 'echo'];
  app.get('/api/voice/effects', (req, res) => {
    res.json([
      { key: 'none', name: 'Normal' },
      { key: 'robot', name: 'Robot' },
      { key: 'chipmunk', name: 'Sincap' },
      { key: 'deep', name: 'Koyu' },
      { key: 'child', name: 'Cocuk' },
      { key: 'grandpa', name: 'Dede' },
      { key: 'alien', name: 'Uzayli' },
      { key: 'echo', name: 'Eko' }
    ]);
  });

  app.post('/api/voice/effect', auth, (req, res) => {
    if (EFFECTS.indexOf(req.body.effect) < 0) return res.status(400).json({ error: 'INVALID' });
    db.prepare('INSERT OR REPLACE INTO voice_effects (user_id, effect) VALUES (?, ?)').run(req.uid, req.body.effect);
    res.json({ ok: true });
  });

  app.get('/api/voice/effect/me', auth, (req, res) => {
    const r = db.prepare('SELECT effect FROM voice_effects WHERE user_id = ?').get(req.uid);
    res.json({ effect: r ? r.effect : 'none' });
  });

  // 50: Analytics Dashboard
  app.post('/api/analytics/track', auth, (req, res) => {
    const { event, meta } = req.body;
    if (!event) return res.status(400).json({ error: 'NO_EVENT' });
    db.prepare('INSERT INTO analytics_events (user_id, event, meta) VALUES (?, ?, ?)').run(req.uid, event, JSON.stringify(meta || {}));
    res.json({ ok: true });
  });

  app.get('/api/analytics/dashboard', auth, adminOnly, (req, res) => {
    const days = parseInt(req.query.days) || 7;
    const events = db.prepare("SELECT event, COUNT(*) AS count FROM analytics_events WHERE created_at > datetime('now', '-' || ? || ' days') GROUP BY event ORDER BY count DESC LIMIT 20").all(days);
    const daily = db.prepare("SELECT DATE(created_at) AS day, COUNT(*) AS events, COUNT(DISTINCT user_id) AS users FROM analytics_events WHERE created_at > datetime('now', '-' || ? || ' days') GROUP BY DATE(created_at) ORDER BY day").all(days);
    const segments = db.prepare('SELECT segment, COUNT(*) AS count FROM behavior GROUP BY segment').all();
    const revenue = db.prepare("SELECT DATE(created_at) AS day, COALESCE(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 0) AS won, COALESCE(SUM(CASE WHEN amount < 0 THEN -amount ELSE 0 END), 0) AS bet FROM tx WHERE created_at > datetime('now', '-' || ? || ' days') GROUP BY DATE(created_at) ORDER BY day").all(days);
    res.json({ events, daily, segments, revenue });
  });

  app.get('/api/analytics/me', auth, (req, res) => {
    const daily = db.prepare("SELECT DATE(created_at) AS day, COALESCE(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 0) AS won, COALESCE(SUM(CASE WHEN amount < 0 THEN -amount ELSE 0 END), 0) AS bet FROM tx WHERE user_id = ? AND created_at > datetime('now', '-30 days') GROUP BY DATE(created_at) ORDER BY day").all(req.uid);
    res.json({ daily });
  });

  // 51: Weekly/Monthly Leaderboard
  app.get('/api/leaderboard/weekly', auth, (req, res) => {
    res.json(db.prepare("SELECT u.id, u.username, u.vip, u.level, COALESCE(SUM(tx.amount), 0) AS won FROM users u LEFT JOIN tx ON tx.user_id = u.id AND tx.amount > 0 AND tx.created_at > datetime('now', '-7 days') GROUP BY u.id ORDER BY won DESC LIMIT 50").all());
  });

  app.get('/api/leaderboard/monthly', auth, (req, res) => {
    res.json(db.prepare("SELECT u.id, u.username, u.vip, u.level, COALESCE(SUM(tx.amount), 0) AS won FROM users u LEFT JOIN tx ON tx.user_id = u.id AND tx.amount > 0 AND tx.created_at > datetime('now', '-30 days') GROUP BY u.id ORDER BY won DESC LIMIT 50").all());
  });

  app.get('/api/leaderboard/points', auth, (req, res) => {
    res.json(db.prepare('SELECT id, username, xp, level, vip FROM users ORDER BY xp DESC LIMIT 50').all());
  });

  app.get('/api/leaderboard/spenders', auth, (req, res) => {
    res.json(db.prepare("SELECT u.id, u.username, u.vip, COALESCE(SUM(-tx.amount), 0) AS spent FROM users u LEFT JOIN tx ON tx.user_id = u.id AND tx.amount < 0 AND tx.created_at > datetime('now', '-30 days') GROUP BY u.id ORDER BY spent DESC LIMIT 50").all());
  });

  console.log('[systems8] 8 sistem yuklendi');
};
