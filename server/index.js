const express = require('express');
const http = require('http');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Server } = require('socket.io');
const db = require('./database');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

const JWT_SECRET = 'hayidev-secret-2024';
const PORT = 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// ─── Auth middleware ───
function auth(req, res, next) {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'no_token' });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (e) {
    res.status(401).json({ error: 'bad_token' });
  }
}

function fmtUser(u) {
  if (!u) return null;
  return {
    id: u.id, username: u.username,
    balance: u.balance, diamonds: u.diamonds,
    level: u.level, xp: u.xp, vip: u.vip,
    bio: u.bio, gender: u.gender, age: u.age,
    country: u.country, avatarFrame: u.avatar_frame,
  };
}

// ═══ AUTH ═══
app.post('/api/auth/register', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ error: 'Eksik bilgi' });
  if (username.length < 3)
    return res.status(400).json({ error: 'Kullanici adi cok kisa' });
  if (db.prepare('SELECT id FROM users WHERE username=?').get(username))
    return res.status(400).json({ error: 'Bu isim alinmis' });

  const hash = bcrypt.hashSync(password, 10);
  const info = db.prepare(`INSERT INTO users
    (username, password, balance, diamonds) VALUES (?,?,10000,100)`)
    .run(username, hash);
  const u = db.prepare('SELECT * FROM users WHERE id=?')
    .get(info.lastInsertRowid);
  const token = jwt.sign({ id: u.id, username: u.username },
    JWT_SECRET, { expiresIn: '30d' });
  res.json({ token, user: fmtUser(u) });
});

app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  const u = db.prepare('SELECT * FROM users WHERE username=?').get(username);
  if (!u) return res.status(401).json({ error: 'Kullanici yok' });
  if (!bcrypt.compareSync(password, u.password))
    return res.status(401).json({ error: 'Sifre yanlis' });
  db.prepare('UPDATE users SET last_seen=? WHERE id=?')
    .run(Math.floor(Date.now()/1000), u.id);
  const token = jwt.sign({ id: u.id, username: u.username },
    JWT_SECRET, { expiresIn: '30d' });
  res.json({ token, user: fmtUser(u) });
});

// ═══ USER ═══
app.get('/api/user/me', auth, (req, res) => {
  const u = db.prepare('SELECT * FROM users WHERE id=?').get(req.user.id);
  res.json(fmtUser(u));
});

app.put('/api/user/me', auth, (req, res) => {
  const { username, bio, gender, age, country, avatarFrame } = req.body;
  db.prepare(`UPDATE users SET
    username=COALESCE(?,username),
    bio=COALESCE(?,bio),
    gender=COALESCE(?,gender),
    age=COALESCE(?,age),
    country=COALESCE(?,country),
    avatar_frame=COALESCE(?,avatar_frame)
    WHERE id=?`)
    .run(username, bio, gender, age, country, avatarFrame, req.user.id);
  const u = db.prepare('SELECT * FROM users WHERE id=?').get(req.user.id);
  res.json(fmtUser(u));
});

app.get('/api/users/search', auth, (req, res) => {
  const q = '%' + (req.query.q || '') + '%';
  const list = db.prepare(`SELECT id, username, balance, level, vip
    FROM users WHERE username LIKE ? AND id != ? LIMIT 20`)
    .all(q, req.user.id);
  res.json(list);
});

app.get('/api/leaderboard', (req, res) => {
  const list = db.prepare(`SELECT username, balance, level, vip
    FROM users ORDER BY balance DESC LIMIT 50`).all();
  res.json(list);
});

// ═══ ROOMS ═══
app.get('/api/rooms', (req, res) => {
  res.json(db.prepare('SELECT * FROM rooms ORDER BY id DESC').all());
});

app.get('/api/rooms/:id', (req, res) => {
  const r = db.prepare('SELECT * FROM rooms WHERE id=?').get(req.params.id);
  if (!r) return res.status(404).json({ error: 'Oda yok' });
  res.json(r);
});

app.post('/api/rooms/create', auth, (req, res) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: 'Isim gerekli' });
  const info = db.prepare(`INSERT INTO rooms (name, owner)
    VALUES (?, ?)`).run(name, req.user.username);
  const room = db.prepare('SELECT * FROM rooms WHERE id=?')
    .get(info.lastInsertRowid);
  res.json(room);
});

app.put('/api/rooms/:id', auth, (req, res) => {
  const { name, locked, background, maxUsers } = req.body;
  db.prepare(`UPDATE rooms SET
    name=COALESCE(?,name),
    locked=COALESCE(?,locked),
    background=COALESCE(?,background),
    max_users=COALESCE(?,max_users)
    WHERE id=?`)
    .run(name, locked, background, maxUsers, req.params.id);
  res.json({ ok: true });
});

app.get('/api/rooms/:id/messages', (req, res) => {
  const list = db.prepare(`SELECT * FROM room_messages
    WHERE room_id=? ORDER BY id DESC LIMIT 100`).all(req.params.id);
  res.json(list.reverse());
});

app.post('/api/rooms/:id/messages', auth, (req, res) => {
  const { text } = req.body;
  if (!text) return res.status(400).json({ error: 'Bos mesaj' });
  const info = db.prepare(`INSERT INTO room_messages
    (room_id, username, text) VALUES (?,?,?)`)
    .run(req.params.id, req.user.username, text);
  const msg = db.prepare('SELECT * FROM room_messages WHERE id=?')
    .get(info.lastInsertRowid);
  io.to('room_' + req.params.id).emit('new_message', msg);
  res.json(msg);
});

// ═══ DM ═══
app.get('/api/dm/:userId', auth, (req, res) => {
  const other = parseInt(req.params.userId);
  const me = req.user.id;
  const list = db.prepare(`SELECT m.*, u.username as sender
    FROM direct_messages m
    LEFT JOIN users u ON u.id=m.sender_id
    WHERE (m.sender_id=? AND m.receiver_id=?)
       OR (m.sender_id=? AND m.receiver_id=?)
    ORDER BY m.id ASC LIMIT 200`).all(me, other, other, me);
  res.json(list);
});

app.post('/api/dm/:userId', auth, (req, res) => {
  const receiver = parseInt(req.params.userId);
  const { text } = req.body;
  const info = db.prepare(`INSERT INTO direct_messages
    (sender_id, receiver_id, text) VALUES (?,?,?)`)
    .run(req.user.id, receiver, text);
  const msg = db.prepare(`SELECT m.*, u.username as sender
    FROM direct_messages m LEFT JOIN users u ON u.id=m.sender_id
    WHERE m.id=?`).get(info.lastInsertRowid);
  io.to('user_' + receiver).emit('new_dm', msg);
  res.json(msg);
});

// ═══ FRIENDS ═══
app.get('/api/friends', auth, (req, res) => {
  const list = db.prepare(`SELECT u.id, u.username, u.level, u.balance, u.vip
    FROM friends f JOIN users u ON u.id=f.friend_id
    WHERE f.user_id=? AND f.status='accepted'`).all(req.user.id);
  res.json(list);
});

app.get('/api/friends/requests', auth, (req, res) => {
  const list = db.prepare(`SELECT u.id, u.username, u.level
    FROM friends f JOIN users u ON u.id=f.user_id
    WHERE f.friend_id=? AND f.status='pending'`).all(req.user.id);
  res.json(list);
});

app.post('/api/friends/add', auth, (req, res) => {
  const { userId } = req.body;
  if (userId == req.user.id)
    return res.status(400).json({ error: 'Kendine ekleyemezsin' });
  const ex = db.prepare(`SELECT id FROM friends
    WHERE user_id=? AND friend_id=?`).get(req.user.id, userId);
  if (ex) return res.json({ ok: true });
  db.prepare(`INSERT INTO friends (user_id, friend_id) VALUES (?,?)`)
    .run(req.user.id, userId);
  io.to('user_' + userId).emit('friend_request', {
    from: req.user.username, fromId: req.user.id
  });
  res.json({ ok: true });
});

app.post('/api/friends/accept', auth, (req, res) => {
  const { userId } = req.body;
  db.prepare(`UPDATE friends SET status='accepted'
    WHERE user_id=? AND friend_id=?`).run(userId, req.user.id);
  db.prepare(`INSERT OR IGNORE INTO friends
    (user_id, friend_id, status) VALUES (?,?,'accepted')`)
    .run(req.user.id, userId);
  res.json({ ok: true });
});

// ═══ GIFTS ═══
const GIFT_PRICES = {
  kutlama_pasta: 300, sansli_yildiz: 200, sansli_can: 1000,
  sansli_sandik: 100000, sansli: 200000, araba_krali: 400000,
  lucky_hayi: 2000, balloon: 0, phoenix_gift: 500000,
  dragon_gift: 750000, lion_gift: 300000, galaxy_gift: 1000000,
  lucky_clover: 500, lucky_777: 70000, lucky_rainbow: 15000,
  rose: 100, heart: 500, teddy: 2000, ring_gold: 100000,
  love_letter: 10000, turk_bayragi: 5000, bozkurt: 50000,
  hilal_yildiz: 25000, crown_gold: 250000, castle: 500000,
  throne: 800000, king_crown: 2000000, fire_heart: 120000,
  ice_heart: 120000, universe: 5000000,
};

app.post('/api/gifts/send', auth, (req, res) => {
  const { receiverId, giftKey, quantity, roomId } = req.body;
  const qty = quantity || 1;
  const price = (GIFT_PRICES[giftKey] || 100) * qty;
  const u = db.prepare('SELECT balance FROM users WHERE id=?').get(req.user.id);
  if (u.balance < price)
    return res.status(400).json({ error: 'Yetersiz bakiye' });
  db.prepare('UPDATE users SET balance = balance - ? WHERE id=?')
    .run(price, req.user.id);
  db.prepare('UPDATE users SET balance = balance + ? WHERE id=?')
    .run(Math.floor(price * 0.7), receiverId);
  io.emit('gift_sent', {
    sender: req.user.username, receiverId, giftKey,
    quantity: qty, price, roomId: roomId || 0,
  });
  const nb = db.prepare('SELECT balance FROM users WHERE id=?')
    .get(req.user.id).balance;
  res.json({ ok: true, newBalance: nb, spent: price });
});

app.get('/api/gifts', (req, res) => res.json({ ok: true }));

// ═══ GAMES ═══
function playGame(req, res, name, winChance, multiplier) {
  const { bet } = req.body;
  if (!bet || bet < 100)
    return res.status(400).json({ error: 'Min 100' });
  const u = db.prepare('SELECT balance FROM users WHERE id=?').get(req.user.id);
  if (u.balance < bet)
    return res.status(400).json({ error: 'Yetersiz bakiye' });
  db.prepare('UPDATE users SET balance = balance - ? WHERE id=?')
    .run(bet, req.user.id);
  const won = Math.random() < winChance;
  const win = won ? Math.floor(bet * multiplier) : 0;
  if (win > 0) {
    db.prepare('UPDATE users SET balance = balance + ?, xp = xp + ? WHERE id=?')
      .run(win, Math.floor(bet/100), req.user.id);
  }
  db.prepare(`INSERT INTO game_history
    (user_id, game, bet, win) VALUES (?,?,?,?)`)
    .run(req.user.id, name, bet, win);
  const nb = db.prepare('SELECT balance FROM users WHERE id=?')
    .get(req.user.id).balance;
  res.json({ won, win, newBalance: nb, bet });
}

app.post('/api/dragon-tiger/bet', auth, (rq,rs) => playGame(rq,rs,'dragon',0.45,2));
app.post('/api/roulette/spin', auth, (rq,rs) => playGame(rq,rs,'roulette',0.48,2));
app.post('/api/slot/spin', auth, (rq,rs) => playGame(rq,rs,'slot',0.40,3));
app.post('/api/slot-food/spin', auth, (rq,rs) => playGame(rq,rs,'slot_food',0.42,3));
app.post('/api/jackpot-eagle/spin', auth, (rq,rs) => playGame(rq,rs,'jackpot_eagle',0.38,4));
app.post('/api/golden-fortune/spin', auth, (rq,rs) => playGame(rq,rs,'golden',0.35,5));
app.post('/api/lucky-fruit/spin', auth, (rq,rs) => playGame(rq,rs,'lucky_fruit',0.40,3));
app.post('/api/lucky-pro/spin', auth, (rq,rs) => playGame(rq,rs,'lucky_pro',0.38,4));
app.post('/api/greedy-pro/spin', auth, (rq,rs) => playGame(rq,rs,'greedy',0.40,3));
app.post('/api/teen-patti/bet', auth, (rq,rs) => playGame(rq,rs,'teen_patti',0.42,3));
app.post('/api/football/bet', auth, (rq,rs) => playGame(rq,rs,'football',0.45,2));
app.post('/api/bull-cowboy/bet', auth, (rq,rs) => playGame(rq,rs,'bull_cowboy',0.45,2));
app.post('/api/rocket/bet', auth, (rq,rs) => playGame(rq,rs,'rocket',0.5,2));
app.post('/api/rocket/cashout', auth, (rq,rs) => res.json({ ok: true }));
app.post('/api/jackpot/chest', auth, (rq,rs) => playGame(rq,rs,'jackpot',0.40,3));

// ═══ TOURNAMENTS ═══
app.get('/api/tournaments', (req, res) => {
  res.json(db.prepare('SELECT * FROM tournaments ORDER BY id DESC').all());
});

app.post('/api/tournaments/:id/join', auth, (req, res) => {
  db.prepare('UPDATE tournaments SET players = players + 1 WHERE id=?')
    .run(req.params.id);
  res.json({ ok: true });
});

app.get('/api/tournaments/:id/leaderboard', (req, res) => {
  res.json(db.prepare(`SELECT username, balance as score
    FROM users ORDER BY balance DESC LIMIT 10`).all());
});

// ═══ MISC ═══
app.post('/api/daily/claim', auth, (req, res) => {
  const reward = 500;
  db.prepare('UPDATE users SET balance = balance + ? WHERE id=?')
    .run(reward, req.user.id);
  res.json({ ok: true, reward });
});

app.post('/api/wheel/spin', auth, (req, res) => {
  const rewards = [100, 200, 500, 1000, 2000, 5000];
  const reward = rewards[Math.floor(Math.random() * rewards.length)];
  db.prepare('UPDATE users SET balance = balance + ? WHERE id=?')
    .run(reward, req.user.id);
  res.json({ ok: true, reward });
});

app.post('/api/shop/purchase', auth, (req, res) => res.json({ ok: true }));

app.get('/', (req, res) => {
  res.json({ status: 'ok', name: 'HayiDev', version: '1.0.0' });
});

// ═══ SOCKET.IO ═══
io.on('connection', (socket) => {
  console.log('bagli:', socket.id);

  socket.on('auth', (data) => {
    if (data && data.userId) socket.join('user_' + data.userId);
  });

  socket.on('join_room', (rid) => socket.join('room_' + rid));
  socket.on('leave_room', (rid) => socket.leave('room_' + rid));

  socket.on('send_message', (data) => {
    io.to('room_' + data.roomId).emit('new_message', data);
  });

  socket.on('disconnect', () => console.log('cikti:', socket.id));
});

// ═══ START ═══
server.listen(PORT, '0.0.0.0', () => {
  const os = require('os');
  const nets = os.networkInterfaces();
  let ip = 'localhost';
  for (const k of Object.keys(nets)) {
    for (const n of nets[k]) {
      if (n.family === 'IPv4' && !n.internal) { ip = n.address; break; }
    }
  }
  console.log('');
  console.log('==========================================');
  console.log('  HAYIDEV SERVER CALISIYOR');
  console.log('==========================================');
  console.log('  Local:   http://localhost:' + PORT);
  console.log('  Network: http://' + ip + ':' + PORT);
  console.log('==========================================');
  console.log('  Kullanicilar (sifre: 123456):');
  console.log('    admin   -> 1.000.000 coin');
  console.log('    test    -> 50.000 coin');
  console.log('    player1 -> 25.000 coin');
  console.log('==========================================');
  console.log('');
});
