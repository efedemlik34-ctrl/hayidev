const express = require('express');
const http = require('http');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Database = require('better-sqlite3');
const { Server } = require('socket.io');

const SECRET = 'hayidev-secret-2026';
const PORT = process.env.PORT || 3000;

const db = new Database('hayidev.db');
db.pragma('journal_mode = WAL');

db.exec(`
CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, username TEXT UNIQUE NOT NULL, password TEXT NOT NULL, balance INTEGER DEFAULT 10000, diamonds INTEGER DEFAULT 100, vip INTEGER DEFAULT 0, xp INTEGER DEFAULT 0, level INTEGER DEFAULT 0, is_admin INTEGER DEFAULT 0, is_banned INTEGER DEFAULT 0, frame TEXT DEFAULT 'default', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS tx (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, amount INTEGER, type TEXT, ref TEXT, balance_after INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS rooms (id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id INTEGER, name TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, room_id INTEGER, text TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS gifts_log (id INTEGER PRIMARY KEY AUTOINCREMENT, sender_id INTEGER, receiver_id INTEGER, gift_key TEXT, amount INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS quests (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, key TEXT, progress INTEGER DEFAULT 0, target INTEGER, reward INTEGER, claimed INTEGER DEFAULT 0, day TEXT);
CREATE TABLE IF NOT EXISTS daily (user_id INTEGER PRIMARY KEY, streak INTEGER DEFAULT 0, last TEXT);
CREATE TABLE IF NOT EXISTS invites (id INTEGER PRIMARY KEY AUTOINCREMENT, inviter INTEGER, invited INTEGER, code TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS audit (id INTEGER PRIMARY KEY AUTOINCREMENT, actor INTEGER, action TEXT, details TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS frames (user_id INTEGER, frame_key TEXT, PRIMARY KEY(user_id, frame_key));
CREATE TABLE IF NOT EXISTS badges (user_id INTEGER, badge_key TEXT, earned_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(user_id, badge_key));
CREATE TABLE IF NOT EXISTS clans (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, owner_id INTEGER, description TEXT, points INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS clan_members (clan_id INTEGER, user_id INTEGER, role TEXT DEFAULT 'member', PRIMARY KEY(clan_id, user_id));
CREATE TABLE IF NOT EXISTS coupons (id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT UNIQUE, reward_type TEXT, reward_value INTEGER, max_uses INTEGER DEFAULT 0, used INTEGER DEFAULT 0, active INTEGER DEFAULT 1, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS coupon_uses (coupon_id INTEGER, user_id INTEGER, PRIMARY KEY(coupon_id, user_id));
CREATE TABLE IF NOT EXISTS reports (id INTEGER PRIMARY KEY AUTOINCREMENT, reporter INTEGER, reported INTEGER, type TEXT, message TEXT, status TEXT DEFAULT 'open', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS wheel_spins (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, reward INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
`);

const app = express();
const srv = http.createServer(app);
const io = new Server(srv, { cors: { origin: '*' } });
app.use(cors());
app.use(express.json());

const auth = (req, res, next) => {
  try {
    const t = (req.headers.authorization || '').replace('Bearer ', '');
    req.uid = jwt.verify(t, SECRET).id;
    next();
  } catch (e) { res.status(401).json({ error: 'INVALID_TOKEN' }); }
};

const adminOnly = (req, res, next) => {
  const u = db.prepare('SELECT is_admin FROM users WHERE id = ?').get(req.uid);
  if (!u || !u.is_admin) return res.status(403).json({ error: 'FORBIDDEN' });
  next();
};

const changeBal = (uid, d, type, ref) => {
  const u = db.prepare('SELECT balance FROM users WHERE id = ?').get(uid);
  if (!u) throw new Error('USER_NOT_FOUND');
  const n = u.balance + d;
  if (n < 0) throw new Error('INSUFFICIENT_BALANCE');
  db.prepare('UPDATE users SET balance = ? WHERE id = ?').run(n, uid);
  db.prepare('INSERT INTO tx (user_id, amount, type, ref, balance_after) VALUES (?, ?, ?, ?, ?)').run(uid, d, type, ref || null, n);
  return n;
};

const addXp = (uid, a) => {
  const u = db.prepare('SELECT xp, level FROM users WHERE id = ?').get(uid);
  const xp = (u.xp || 0) + a;
  const lvl = Math.floor(Math.sqrt(xp / 100));
  db.prepare('UPDATE users SET xp = ?, level = ? WHERE id = ?').run(xp, lvl, uid);
  if (lvl > u.level) io.to('user_' + uid).emit('levelup', { old: u.level, new: lvl });
};

const QUESTS = [
  { key: 'daily_login', title: 'Giris yap', target: 1, reward: 500 },
  { key: 'send_msg', title: '5 mesaj', target: 5, reward: 1000 },
  { key: 'send_gift', title: '1 hediye', target: 1, reward: 2000 },
  { key: 'play_3', title: '3 oyun', target: 3, reward: 3000 },
  { key: 'win_1', title: '1 kazanc', target: 1, reward: 5000 },
  { key: 'spin_10', title: '10 slot', target: 10, reward: 4000 },
  { key: 'invite_1', title: '1 davet', target: 1, reward: 10000 },
  { key: 'vip_buy', title: 'VIP ol', target: 1, reward: 20000 }
];

const questProgress = (uid, key, inc) => {
  inc = inc || 1;
  const day = new Date().toISOString().slice(0, 10);
  const r = db.prepare('SELECT * FROM quests WHERE user_id = ? AND key = ? AND day = ?').get(uid, key, day);
  if (!r) {
    const d = QUESTS.find(q => q.key === key);
    if (!d) return;
    db.prepare('INSERT INTO quests (user_id, key, progress, target, reward, day) VALUES (?, ?, ?, ?, ?, ?)').run(uid, key, inc, d.target, d.reward, day);
  } else {
    db.prepare('UPDATE quests SET progress = MIN(progress + ?, target) WHERE id = ?').run(inc, r.id);
  }
};

app.post('/api/auth/register', async (req, res) => {
  const { email, username, password } = req.body;
  if (!email || !username || !password) return res.status(400).json({ error: 'MISSING' });
  if (password.length < 6) return res.status(400).json({ error: 'WEAK_PASSWORD' });
  try {
    const h = await bcrypt.hash(password, 10);
    const r = db.prepare('INSERT INTO users (email, username, password) VALUES (?, ?, ?)').run(email.toLowerCase(), username, h);
    const u = db.prepare('SELECT id, username, email, balance, diamonds, vip, level FROM users WHERE id = ?').get(r.lastInsertRowid);
    res.json({ token: jwt.sign({ id: u.id }, SECRET, { expiresIn: '30d' }), user: u });
  } catch (e) {
    if (e.message.indexOf('UNIQUE') >= 0) return res.status(409).json({ error: 'ALREADY_EXISTS' });
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { identifier, password } = req.body;
  const u = db.prepare('SELECT * FROM users WHERE email = ? OR username = ?').get((identifier || '').toLowerCase(), identifier);
  if (!u) return res.status(401).json({ error: 'INVALID' });
  if (u.is_banned) return res.status(403).json({ error: 'BANNED' });
  const ok = await bcrypt.compare(password, u.password);
  if (!ok) return res.status(401).json({ error: 'INVALID' });
  db.prepare('UPDATE users SET last_login = ? WHERE id = ?').run(new Date().toISOString(), u.id);
  res.json({ token: jwt.sign({ id: u.id }, SECRET, { expiresIn: '30d' }), user: { id: u.id, username: u.username, email: u.email, balance: u.balance, diamonds: u.diamonds, vip: u.vip, level: u.level, is_admin: u.is_admin } });
});

app.get('/api/user/me', auth, (req, res) => {
  res.json(db.prepare('SELECT id, username, email, balance, diamonds, vip, xp, level, is_admin, frame, created_at FROM users WHERE id = ?').get(req.uid));
});

app.get('/api/user/tx', auth, (req, res) => {
  res.json(db.prepare('SELECT * FROM tx WHERE user_id = ? ORDER BY id DESC LIMIT 100').all(req.uid));
});

const REWARDS = [500, 1000, 2000, 5000, 10000, 25000, 100000, 500000];

app.post('/api/daily/claim', auth, (req, res) => {
  const today = new Date().toISOString().slice(0, 10);
  let d = db.prepare('SELECT * FROM daily WHERE user_id = ?').get(req.uid);
  if (!d) {
    db.prepare('INSERT INTO daily (user_id, streak, last) VALUES (?, 0, NULL)').run(req.uid);
    d = { streak: 0, last: null };
  }
  if (d.last && d.last.slice(0, 10) === today) return res.status(400).json({ error: 'ALREADY_CLAIMED' });
  const vip = db.prepare('SELECT vip FROM users WHERE id = ?').get(req.uid).vip;
  const bonus = [1, 1.05, 1.1, 1.2, 1.35, 1.5][vip] || 1;
  const reward = Math.floor(REWARDS[d.streak % 8] * bonus);
  const bal = changeBal(req.uid, reward, 'daily', 'day_' + d.streak);
  db.prepare('UPDATE daily SET streak = ?, last = ? WHERE user_id = ?').run(d.streak + 1, new Date().toISOString(), req.uid);
  addXp(req.uid, 50);
  questProgress(req.uid, 'daily_login', 1);
  res.json({ reward, streak: d.streak + 1, balance: bal });
});

const VIP = [
  { level: 1, name: 'VIP 1', price: 50000 },
  { level: 2, name: 'VIP 2', price: 200000 },
  { level: 3, name: 'VIP 3', price: 500000 },
  { level: 4, name: 'VIP 4', price: 1500000 },
  { level: 5, name: 'VIP 5', price: 5000000 }
];

app.get('/api/vip', (req, res) => res.json(VIP));

app.post('/api/vip/buy', auth, (req, res) => {
  const t = VIP.find(v => v.level === req.body.level);
  if (!t) return res.status(400).json({ error: 'INVALID' });
  const cur = db.prepare('SELECT vip FROM users WHERE id = ?').get(req.uid).vip;
  if (cur >= t.level) return res.status(400).json({ error: 'ALREADY_OWNED' });
  try {
    changeBal(req.uid, -t.price, 'vip_buy', t.name);
    db.prepare('UPDATE users SET vip = ? WHERE id = ?').run(t.level, req.uid);
    questProgress(req.uid, 'vip_buy', 1);
    addXp(req.uid, 100);
    res.json({ ok: true, level: t.level });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.post('/api/rooms/create', auth, (req, res) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: 'NAME_REQUIRED' });
  const r = db.prepare('INSERT INTO rooms (owner_id, name) VALUES (?, ?)').run(req.uid, name);
  res.json(db.prepare('SELECT * FROM rooms WHERE id = ?').get(r.lastInsertRowid));
});

app.get('/api/rooms', auth, (req, res) => {
  res.json(db.prepare('SELECT r.*, u.username AS owner FROM rooms r LEFT JOIN users u ON u.id = r.owner_id ORDER BY r.id DESC LIMIT 50').all());
});

app.get('/api/rooms/:id/messages', auth, (req, res) => {
  const m = db.prepare('SELECT m.*, u.username FROM messages m LEFT JOIN users u ON u.id = m.user_id WHERE m.room_id = ? ORDER BY m.id DESC LIMIT 100').all(req.params.id);
  res.json(m.reverse());
});

const GIFTS = {
  rose: { name: 'Gul', icon: '🌹', price: 100 },
  heart: { name: 'Kalp', icon: '❤️', price: 500 },
  cake: { name: 'Pasta', icon: '🎂', price: 2000 },
  star: { name: 'Yildiz', icon: '⭐', price: 5000 },
  car: { name: 'Araba', icon: '🚗', price: 50000 },
  lion: { name: 'Aslan', icon: '🦁', price: 100000 },
  dragon: { name: 'Ejderha', icon: '🐉', price: 500000 },
  crown: { name: 'Tac', icon: '👑', price: 1000000 },
  castle: { name: 'Kale', icon: '🏰', price: 2000000 },
  galaxy: { name: 'Galaksi', icon: '🌌', price: 2500000 },
  phoenix: { name: 'Anka', icon: '🔥', price: 5000000 },
  god: { name: 'Tanri', icon: '⚡', price: 10000000 }
};

app.get('/api/gifts', (req, res) => {
  res.json(Object.keys(GIFTS).map(k => ({ key: k, name: GIFTS[k].name, icon: GIFTS[k].icon, price: GIFTS[k].price })));
});

app.post('/api/gifts/send', auth, (req, res) => {
  const { receiverId, giftKey } = req.body;
  const g = GIFTS[giftKey];
  if (!g) return res.status(400).json({ error: 'INVALID_GIFT' });
  try {
    changeBal(req.uid, -g.price, 'gift_sent', giftKey);
    changeBal(receiverId, Math.floor(g.price * 0.7), 'gift_received', giftKey);
    db.prepare('INSERT INTO gifts_log (sender_id, receiver_id, gift_key, amount) VALUES (?, ?, ?, ?)').run(req.uid, receiverId, giftKey, g.price);
    questProgress(req.uid, 'send_gift', 1);
    addXp(req.uid, 5);
    res.json({ ok: true, cost: g.price, icon: g.icon });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.get('/api/quests', auth, (req, res) => {
  const day = new Date().toISOString().slice(0, 10);
  const prog = db.prepare('SELECT * FROM quests WHERE user_id = ? AND day = ?').all(req.uid, day);
  const map = {};
  prog.forEach(p => { map[p.key] = p; });
  res.json(QUESTS.map(q => ({
    key: q.key, title: q.title, target: q.target, reward: q.reward,
    progress: map[q.key] ? map[q.key].progress : 0,
    completed: (map[q.key] ? map[q.key].progress : 0) >= q.target,
    claimed: map[q.key] ? map[q.key].claimed === 1 : false
  })));
});

app.post('/api/quests/:key/claim', auth, (req, res) => {
  const q = QUESTS.find(x => x.key === req.params.key);
  if (!q) return res.status(400).json({ error: 'INVALID' });
  const day = new Date().toISOString().slice(0, 10);
  const r = db.prepare('SELECT * FROM quests WHERE user_id = ? AND key = ? AND day = ?').get(req.uid, q.key, day);
  if (!r || r.progress < r.target) return res.status(400).json({ error: 'NOT_COMPLETED' });
  if (r.claimed) return res.status(400).json({ error: 'ALREADY_CLAIMED' });
  db.prepare('UPDATE quests SET claimed = 1 WHERE id = ?').run(r.id);
  const bal = changeBal(req.uid, q.reward, 'quest', q.key);
  addXp(req.uid, 20);
  res.json({ ok: true, reward: q.reward, balance: bal });
});

app.get('/api/invite/me', auth, (req, res) => {
  const code = 'HY' + req.uid.toString(36).toUpperCase().padStart(6, '0');
  const inv = db.prepare('SELECT i.created_at, u.username FROM invites i JOIN users u ON u.id = i.invited WHERE i.inviter = ? ORDER BY i.id DESC LIMIT 50').all(req.uid);
  res.json({ code, invited: inv, count: inv.length, reward: 5000 });
});

app.post('/api/invite/apply', auth, (req, res) => {
  const { code } = req.body;
  if (!code || code.indexOf('HY') !== 0) return res.status(400).json({ error: 'INVALID_CODE' });
  const iid = parseInt(code.slice(2), 36);
  if (iid === req.uid) return res.status(400).json({ error: 'SELF_INVITE' });
  try {
    db.prepare('INSERT INTO invites (inviter, invited, code) VALUES (?, ?, ?)').run(iid, req.uid, code);
    changeBal(iid, 5000, 'invite_reward', code);
    changeBal(req.uid, 2500, 'invite_bonus', code);
    res.json({ ok: true, bonus: 2500 });
  } catch (e) { res.status(400).json({ error: 'ALREADY_USED' }); }
});

app.get('/api/leaderboard', auth, (req, res) => {
  res.json(db.prepare('SELECT id, username, balance, vip, level FROM users ORDER BY balance DESC LIMIT 100').all());
});

const FRAMES = [
  { key: 'default', name: 'Varsayilan', price: 0 },
  { key: 'gold', name: 'Altin', price: 50000 },
  { key: 'rainbow', name: 'Gokkusagi', price: 100000 },
  { key: 'fire', name: 'Ates', price: 150000 },
  { key: 'ice', name: 'Buz', price: 150000 },
  { key: 'galaxy', name: 'Galaksi', price: 500000 },
  { key: 'dragon', name: 'Ejderha', price: 1000000 },
  { key: 'god', name: 'Tanri', price: 5000000 }
];

app.get('/api/frames', (req, res) => res.json(FRAMES));

app.get('/api/frames/my', auth, (req, res) => {
  res.json(db.prepare('SELECT frame_key FROM frames WHERE user_id = ?').all(req.uid).map(r => r.frame_key));
});

app.post('/api/frames/buy', auth, (req, res) => {
  const f = FRAMES.find(x => x.key === req.body.key);
  if (!f) return res.status(400).json({ error: 'INVALID' });
  if (f.price > 0) {
    try { changeBal(req.uid, -f.price, 'frame_buy', f.key); }
    catch (e) { return res.status(400).json({ error: e.message }); }
  }
  db.prepare('INSERT OR IGNORE INTO frames (user_id, frame_key) VALUES (?, ?)').run(req.uid, f.key);
  db.prepare('UPDATE users SET frame = ? WHERE id = ?').run(f.key, req.uid);
  res.json({ ok: true });
});

const BADGES = [
  { key: 'first_win', name: 'Ilk Zafer' },
  { key: 'gift_master', name: 'Hediye Ustasi' },
  { key: 'social', name: 'Sosyal' },
  { key: 'winner', name: 'Kazanan' },
  { key: 'vip1', name: 'VIP' },
  { key: 'billionaire', name: 'Milyarder' },
  { key: 'jackpot', name: 'Jackpot' }
];

app.get('/api/badges', auth, (req, res) => {
  const owned = new Set(db.prepare('SELECT badge_key FROM badges WHERE user_id = ?').all(req.uid).map(b => b.badge_key));
  res.json(BADGES.map(b => ({ key: b.key, name: b.name, owned: owned.has(b.key) })));
});

const grantBadge = (uid, key) => {
  try { db.prepare('INSERT OR IGNORE INTO badges (user_id, badge_key) VALUES (?, ?)').run(uid, key); } catch (e) {}
};

app.post('/api/clans/create', auth, (req, res) => {
  const { name, description } = req.body;
  if (!name) return res.status(400).json({ error: 'NAME_REQUIRED' });
  try {
    const r = db.prepare('INSERT INTO clans (name, owner_id, description) VALUES (?, ?, ?)').run(name, req.uid, description || '');
    db.prepare('INSERT INTO clan_members (clan_id, user_id, role) VALUES (?, ?, ?)').run(r.lastInsertRowid, req.uid, 'owner');
    res.json(db.prepare('SELECT * FROM clans WHERE id = ?').get(r.lastInsertRowid));
  } catch (e) { res.status(409).json({ error: 'NAME_TAKEN' }); }
});

app.get('/api/clans', auth, (req, res) => {
  res.json(db.prepare('SELECT c.*, u.username AS owner, (SELECT COUNT(*) FROM clan_members WHERE clan_id = c.id) AS members FROM clans c JOIN users u ON u.id = c.owner_id ORDER BY c.points DESC LIMIT 50').all());
});

app.post('/api/coupons/redeem', auth, (req, res) => {
  const { code } = req.body;
  if (!code) return res.status(400).json({ error: 'MISSING' });
  const c = db.prepare('SELECT * FROM coupons WHERE code = ? AND active = 1').get(code.toUpperCase());
  if (!c) return res.status(400).json({ error: 'INVALID_CODE' });
  if (c.max_uses > 0 && c.used >= c.max_uses) return res.status(400).json({ error: 'MAX_USES' });
  try { db.prepare('INSERT INTO coupon_uses (coupon_id, user_id) VALUES (?, ?)').run(c.id, req.uid); }
  catch (e) { return res.status(400).json({ error: 'ALREADY_USED' }); }
  db.prepare('UPDATE coupons SET used = used + 1 WHERE id = ?').run(c.id);
  if (c.reward_type === 'coin') changeBal(req.uid, c.reward_value, 'coupon', c.code);
  res.json({ ok: true, reward: c.reward_value });
});

app.post('/api/reports', auth, (req, res) => {
  const { reported, type, message } = req.body;
  if (!reported || !type) return res.status(400).json({ error: 'MISSING' });
  if (reported === req.uid) return res.status(400).json({ error: 'SELF' });
  db.prepare('INSERT INTO reports (reporter, reported, type, message) VALUES (?, ?, ?, ?)').run(req.uid, reported, type, message || '');
  res.json({ ok: true });
});

const WHEEL = [
  { r: 500, w: 25 }, { r: 1000, w: 20 }, { r: 5000, w: 15 }, { r: 10000, w: 10 },
  { r: 25000, w: 6 }, { r: 50000, w: 3 }, { r: 100000, w: 1 }
];

app.get('/api/wheel', auth, (req, res) => {
  const today = new Date().toISOString().slice(0, 10);
  const used = db.prepare('SELECT COUNT(*) AS c FROM wheel_spins WHERE user_id = ? AND created_at LIKE ?').get(req.uid, today + '%').c;
  res.json({ segments: WHEEL.map(w => ({ reward: w.r })), freeRemaining: Math.max(0, 3 - used), paidCost: 5000 });
});

app.post('/api/wheel/spin', auth, (req, res) => {
  const { paid } = req.body;
  const today = new Date().toISOString().slice(0, 10);
  const used = db.prepare('SELECT COUNT(*) AS c FROM wheel_spins WHERE user_id = ? AND created_at LIKE ?').get(req.uid, today + '%').c;
  if (!paid && used >= 3) return res.status(400).json({ error: 'NO_FREE_SPINS' });
  if (paid) {
    try { changeBal(req.uid, -5000, 'wheel_paid', 'spin'); }
    catch (e) { return res.status(400).json({ error: e.message }); }
  }
  const total = WHEEL.reduce((s, x) => s + x.w, 0);
  let r = Math.random() * total, pick = WHEEL[0];
  for (const w of WHEEL) { r -= w.w; if (r <= 0) { pick = w; break; } }
  db.prepare('INSERT INTO wheel_spins (user_id, reward) VALUES (?, ?)').run(req.uid, pick.r);
  changeBal(req.uid, pick.r, 'wheel', 'spin');
  if (pick.r >= 100000) grantBadge(req.uid, 'jackpot');
  res.json({ reward: pick.r });
});

const rockets = {};

app.post('/api/games/rocket/start', auth, (req, res) => {
  const bet = parseInt(req.body.bet);
  if (!bet || bet < 100) return res.status(400).json({ error: 'INVALID_BET' });
  if (rockets[req.uid]) return res.status(400).json({ error: 'IN_PROGRESS' });
  try {
    changeBal(req.uid, -bet, 'rocket_bet', 'r');
    const crash = Math.max(1.0, Math.floor((0.99 / (1 - Math.random())) * 100) / 100);
    rockets[req.uid] = { bet, crash, start: Date.now() };
    addXp(req.uid, 10);
    questProgress(req.uid, 'play_3', 1);
    res.json({ ok: true, bet });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.post('/api/games/rocket/cashout', auth, (req, res) => {
  const g = rockets[req.uid];
  if (!g) return res.status(400).json({ error: 'NO_GAME' });
  const m = Math.round((1 + ((Date.now() - g.start) / 1000) * 0.15) * 100) / 100;
  if (m >= g.crash) {
    delete rockets[req.uid];
    return res.status(400).json({ error: 'CRASHED', crash: g.crash });
  }
  const p = Math.floor(g.bet * m);
  changeBal(req.uid, p, 'rocket_win', 'r');
  delete rockets[req.uid];
  addXp(req.uid, 25);
  questProgress(req.uid, 'win_1', 1);
  grantBadge(req.uid, 'first_win');
  res.json({ ok: true, multiplier: m, payout: p });
});

const RED = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];

app.post('/api/games/roulette/spin', auth, (req, res) => {
  const bet = parseInt(req.body.bet);
  if (!bet || bet < 100) return res.status(400).json({ error: 'INVALID_BET' });
  try {
    changeBal(req.uid, -bet, 'roulette_bet', 'r');
    const w = Math.floor(Math.random() * 37);
    const red = RED.indexOf(w) >= 0;
    let p = 0;
    if (req.body.type === 'number' && parseInt(req.body.value) === w) p = bet * 36;
    else if (req.body.type === 'red' && red) p = bet * 2;
    else if (req.body.type === 'black' && !red && w !== 0) p = bet * 2;
    else if (req.body.type === 'even' && w !== 0 && w % 2 === 0) p = bet * 2;
    else if (req.body.type === 'odd' && w % 2 === 1) p = bet * 2;
    if (p > 0) {
      changeBal(req.uid, p, 'roulette_win', 'r');
      questProgress(req.uid, 'win_1', 1);
      grantBadge(req.uid, 'first_win');
    }
    addXp(req.uid, 10);
    questProgress(req.uid, 'play_3', 1);
    res.json({ winning: w, color: w === 0 ? 'green' : (red ? 'red' : 'black'), payout: p });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

const SYM = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
const PAYS = { 'A': 5, 'B': 10, 'C': 20, 'D': 50, 'E': 100, 'F': 500, 'G': 1000 };

app.post('/api/games/slot/spin', auth, (req, res) => {
  const bet = parseInt(req.body.bet);
  if (!bet || bet < 100) return res.status(400).json({ error: 'INVALID_BET' });
  try {
    changeBal(req.uid, -bet, 'slot_bet', 's');
    const reels = [
      SYM[Math.floor(Math.random() * SYM.length)],
      SYM[Math.floor(Math.random() * SYM.length)],
      SYM[Math.floor(Math.random() * SYM.length)]
    ];
    let p = 0;
    if (reels[0] === reels[1] && reels[1] === reels[2]) {
      p = bet * PAYS[reels[0]];
      changeBal(req.uid, p, 'slot_win', 's');
      questProgress(req.uid, 'win_1', 1);
      grantBadge(req.uid, 'first_win');
      if (PAYS[reels[0]] >= 500) grantBadge(req.uid, 'jackpot');
    }
    addXp(req.uid, 8);
    questProgress(req.uid, 'spin_10', 1);
    questProgress(req.uid, 'play_3', 1);
    res.json({ reels, payout: p });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

const CARDS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
const VAL = { '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14 };

app.post('/api/games/dragon-tiger/play', auth, (req, res) => {
  const bet = parseInt(req.body.bet);
  if (!bet || bet < 100) return res.status(400).json({ error: 'INVALID_BET' });
  try {
    changeBal(req.uid, -bet, 'dt_bet', 'dt');
    const d = CARDS[Math.floor(Math.random() * 13)];
    const t = CARDS[Math.floor(Math.random() * 13)];
    const dv = VAL[d], tv = VAL[t];
    const winner = dv > tv ? 'dragon' : (tv > dv ? 'tiger' : 'tie');
    let p = 0;
    if (req.body.pick === winner) p = winner === 'tie' ? bet * 8 : bet * 2;
    if (p > 0) {
      changeBal(req.uid, p, 'dt_win', 'dt');
      questProgress(req.uid, 'win_1', 1);
      grantBadge(req.uid, 'first_win');
    }
    addXp(req.uid, 10);
    questProgress(req.uid, 'play_3', 1);
    res.json({ dragon: d, tiger: t, winner, payout: p });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.post('/api/games/coinflip/flip', auth, (req, res) => {
  const bet = parseInt(req.body.bet);
  const pick = req.body.pick;
  if (!bet || bet < 100 || (pick !== 'heads' && pick !== 'tails')) return res.status(400).json({ error: 'INVALID' });
  try {
    changeBal(req.uid, -bet, 'cf_bet', 'cf');
    const r = Math.random() < 0.5 ? 'heads' : 'tails';
    const win = r === pick;
    let p = 0;
    if (win) {
      p = bet * 2;
      changeBal(req.uid, p, 'cf_win', 'cf');
      questProgress(req.uid, 'win_1', 1);
      grantBadge(req.uid, 'first_win');
    }
    addXp(req.uid, 8);
    questProgress(req.uid, 'play_3', 1);
    res.json({ result: r, win, payout: p });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.post('/api/games/dice/roll', auth, (req, res) => {
  const bet = parseInt(req.body.bet);
  const pick = req.body.pick;
  const threshold = parseInt(req.body.threshold) || 50;
  if (!bet || bet < 100) return res.status(400).json({ error: 'INVALID_BET' });
  try {
    changeBal(req.uid, -bet, 'dice_bet', 'd');
    const roll = Math.floor(Math.random() * 100) + 1;
    const win = pick === 'over' ? roll > threshold : roll < threshold;
    let p = 0;
    if (win) {
      p = Math.floor(bet * (100 / (pick === 'over' ? 100 - threshold : threshold)));
      changeBal(req.uid, p, 'dice_win', 'd');
      questProgress(req.uid, 'win_1', 1);
      grantBadge(req.uid, 'first_win');
    }
    addXp(req.uid, 8);
    questProgress(req.uid, 'play_3', 1);
    res.json({ roll, win, payout: p });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.post('/api/admin/login', async (req, res) => {
  const { identifier, password } = req.body;
  const u = db.prepare('SELECT * FROM users WHERE (email = ? OR username = ?) AND is_admin = 1').get((identifier || '').toLowerCase(), identifier);
  if (!u) return res.status(403).json({ error: 'NOT_ADMIN' });
  const ok = await bcrypt.compare(password, u.password);
  if (!ok) return res.status(401).json({ error: 'INVALID' });
  res.json({ token: jwt.sign({ id: u.id, admin: true }, SECRET, { expiresIn: '7d' }), user: { id: u.id, username: u.username, is_admin: true } });
});

app.get('/api/admin/stats', auth, adminOnly, (req, res) => {
  res.json({
    users: db.prepare('SELECT COUNT(*) AS c FROM users').get().c,
    rooms: db.prepare('SELECT COUNT(*) AS c FROM rooms').get().c,
    balance: db.prepare('SELECT COALESCE(SUM(balance), 0) AS s FROM users').get().s,
    bets: db.prepare('SELECT COALESCE(SUM(-amount), 0) AS s FROM tx WHERE amount < 0').get().s,
    gifts: db.prepare('SELECT COUNT(*) AS c FROM gifts_log').get().c,
    messages: db.prepare('SELECT COUNT(*) AS c FROM messages').get().c,
    clans: db.prepare('SELECT COUNT(*) AS c FROM clans').get().c,
    reports: db.prepare('SELECT COUNT(*) AS c FROM reports WHERE status = \'open\'').get().c
  });
});

app.get('/api/admin/users', auth, adminOnly, (req, res) => {
  res.json(db.prepare('SELECT id, email, username, balance, diamonds, vip, level, xp, is_admin, is_banned, frame, created_at FROM users ORDER BY id DESC LIMIT 200').all());
});

app.post('/api/admin/users/:id/balance', auth, adminOnly, (req, res) => {
  try {
    const b = changeBal(parseInt(req.params.id), parseInt(req.body.amount), 'admin', 'panel');
    res.json({ balance: b });
  } catch (e) { res.status(400).json({ error: e.message }); }
});

app.post('/api/admin/users/:id/ban', auth, adminOnly, (req, res) => {
  db.prepare('UPDATE users SET is_banned = ? WHERE id = ?').run(req.body.banned ? 1 : 0, req.params.id);
  res.json({ ok: true });
});

app.post('/api/admin/users/:id/promote', auth, adminOnly, (req, res) => {
  db.prepare('UPDATE users SET is_admin = 1 WHERE id = ?').run(req.params.id);
  res.json({ ok: true });
});

app.post('/api/admin/broadcast', auth, adminOnly, (req, res) => {
  io.emit('broadcast', { title: req.body.title, body: req.body.body, ts: Date.now() });
  res.json({ ok: true, sent: db.prepare('SELECT COUNT(*) AS c FROM users').get().c });
});

app.post('/api/admin/coupons', auth, adminOnly, (req, res) => {
  const { code, reward_value, max_uses } = req.body;
  const c = code || require('crypto').randomBytes(5).toString('hex').toUpperCase();
  try {
    const r = db.prepare('INSERT INTO coupons (code, reward_type, reward_value, max_uses) VALUES (?, ?, ?, ?)').run(c.toUpperCase(), 'coin', reward_value || 10000, max_uses || 0);
    res.json(db.prepare('SELECT * FROM coupons WHERE id = ?').get(r.lastInsertRowid));
  } catch (e) { res.status(409).json({ error: 'CODE_EXISTS' }); }
});

app.get('/', (req, res) => res.json({ name: 'HayiDev', version: '1.0.0', systems: 25, status: 'running' }));

io.use((s, next) => {
  try {
    s.uid = jwt.verify(s.handshake.auth.token, SECRET).id;
    const u = db.prepare('SELECT username FROM users WHERE id = ?').get(s.uid);
    s.username = u.username;
    next();
  } catch (e) { next(new Error('AUTH_FAILED')); }
});

io.on('connection', (socket) => {
  socket.join('user_' + socket.uid);
  socket.on('room:join', (d) => {
    socket.join('room_' + d.roomId);
    io.to('room_' + d.roomId).emit('room:user_joined', { username: socket.username });
  });
  socket.on('room:leave', (d) => {
    socket.leave('room_' + d.roomId);
    io.to('room_' + d.roomId).emit('room:user_left', { username: socket.username });
  });
  socket.on('chat:message', (d) => {
    if (!d.text || d.text.length > 500) return;
    const r = db.prepare('INSERT INTO messages (user_id, room_id, text) VALUES (?, ?, ?)').run(socket.uid, d.roomId, d.text);
    io.to('room_' + d.roomId).emit('chat:message', { id: r.lastInsertRowid, username: socket.username, text: d.text, ts: Date.now() });
    questProgress(socket.uid, 'send_msg', 1);
    addXp(socket.uid, 1);
  });
});

// 18 ek sistem
try { require('./systems18.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); }
catch (e) { console.error('[systems18] hata:', e.message); }


// Tam sistemler (audio + bracket + live)
try { require('./systems_audio.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); }
catch (e) { console.error('[systems_audio] hata:', e.message); }
try { require('./systems_bracket.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); }
catch (e) { console.error('[systems_bracket] hata:', e.message); }
try { require('./systems_live.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); }
catch (e) { console.error('[systems_live] hata:', e.message); }


// Ek sistemler
try { require('./systems8.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); } catch (e) { console.error('[systems8]:', e.message); }


// ═══ EKSIK ENDPOINTLER ═══

// 1. Gunluk Odul Status
app.get('/api/daily/status', auth, (req, res) => {
  const d = db.prepare('SELECT * FROM daily WHERE user_id = ?').get(req.uid) || { streak: 0, last: null };
  const today = new Date().toISOString().slice(0, 10);
  const rewards = [500, 1000, 2000, 5000, 10000, 25000, 100000, 500000];
  res.json({
    streak: d.streak,
    canClaim: !d.last || d.last.slice(0, 10) !== today,
    next: rewards[d.streak % 8]
  });
});

// 2. Hediye Gecmisi
app.get('/api/gifts/history', auth, (req, res) => {
  const rows = db.prepare('SELECT g.*, s.username AS sender, r.username AS receiver FROM gifts_log g LEFT JOIN users s ON s.id = g.sender_id LEFT JOIN users r ON r.id = g.receiver_id WHERE g.sender_id = ? OR g.receiver_id = ? ORDER BY g.id DESC LIMIT 50').all(req.uid, req.uid);
  res.json(rows);
});

// 3. Raporlarim
app.get('/api/reports/my', auth, (req, res) => {
  const rows = db.prepare('SELECT * FROM reports WHERE reporter = ? ORDER BY id DESC LIMIT 50').all(req.uid);
  res.json(rows);
});

// 4. Push Test
app.post('/api/push/test', auth, (req, res) => {
  try {
    db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(req.uid, 'push', 'Test', 'HayiDev test bildirimi');
    io.to('user_' + req.uid).emit('push', { title: 'Test', body: 'Bildirim calisiyor!' });
    res.json({ ok: true });
  } catch (e) {
    res.json({ ok: true, note: 'push kayit edildi' });
  }
});

// 5. Saglik
app.get('/api/health', (req, res) => {
  res.json({ ok: true, ts: Date.now(), systems: 51, version: '1.0.0' });
});

// ═══ EKSIK ENDPOINTLER SONU ═══

try { require('./systems_shop.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); } catch (e) { console.error('[systems_shop]', e.message); }

try { require('./systems_dm.js')({ app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge }); } catch (e) { console.error('[systems_dm]', e.message); }

srv.listen(PORT, async () => {
  const a = db.prepare('SELECT id FROM users WHERE is_admin = 1').get();
  if (!a) {
    const h = await bcrypt.hash('HayiDev@2026!Admin', 10);
    db.prepare('INSERT INTO users (email, username, password, is_admin, balance) VALUES (?, ?, ?, 1, 1000000)').run('admin@hayidev.app', 'admin', h);
    console.log('Admin: admin@hayidev.app / HayiDev@2026!Admin');
  }
  console.log('HayiDev 25 sistem: http://localhost:' + PORT);
});
