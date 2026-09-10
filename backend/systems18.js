// ═══ HayiDev 18 Sistem Modulu ═══
module.exports = function setup(ctx) {
  const { app, db, io, auth, adminOnly, changeBal, addXp, questProgress, grantBadge } = ctx;

  // YENI TABLOLAR
  db.exec(`
    CREATE TABLE IF NOT EXISTS follows (follower INTEGER, following INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(follower, following));
    CREATE TABLE IF NOT EXISTS blocks (user_id INTEGER, blocked_id INTEGER, PRIMARY KEY(user_id, blocked_id));
    CREATE TABLE IF NOT EXISTS friend_requests (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id INTEGER, to_id INTEGER, status TEXT DEFAULT 'pending', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS notifications (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, type TEXT, title TEXT, body TEXT, is_read INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, text TEXT, media_url TEXT, likes INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS post_likes (post_id INTEGER, user_id INTEGER, PRIMARY KEY(post_id, user_id));
    CREATE TABLE IF NOT EXISTS comments (id INTEGER PRIMARY KEY AUTOINCREMENT, post_id INTEGER, user_id INTEGER, text TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS room_seats (room_id INTEGER, seat_index INTEGER, user_id INTEGER, is_muted INTEGER DEFAULT 0, PRIMARY KEY(room_id, seat_index));
    CREATE TABLE IF NOT EXISTS user_themes (user_id INTEGER, theme_key TEXT, PRIMARY KEY(user_id, theme_key));
    CREATE TABLE IF NOT EXISTS voice_messages (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, room_id INTEGER, url TEXT, duration INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS party_queue (id INTEGER PRIMARY KEY AUTOINCREMENT, room_id INTEGER, title TEXT, url TEXT, added_by INTEGER, position INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS room_mods (room_id INTEGER, user_id INTEGER, PRIMARY KEY(room_id, user_id));
    CREATE TABLE IF NOT EXISTS seasons (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, start TEXT, end TEXT, reward_pool INTEGER DEFAULT 0);
    CREATE TABLE IF NOT EXISTS season_points (season_id INTEGER, user_id INTEGER, points INTEGER DEFAULT 0, PRIMARY KEY(season_id, user_id));
    CREATE TABLE IF NOT EXISTS tournaments (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, entry_fee INTEGER, max_players INTEGER, status TEXT DEFAULT 'reg', prize_pool INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS tournament_players (tournament_id INTEGER, user_id INTEGER, PRIMARY KEY(tournament_id, user_id));
    CREATE TABLE IF NOT EXISTS clan_wars (id INTEGER PRIMARY KEY AUTOINCREMENT, clan1 INTEGER, clan2 INTEGER, score1 INTEGER DEFAULT 0, score2 INTEGER DEFAULT 0, status TEXT DEFAULT 'active', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS live_streams (id INTEGER PRIMARY KEY AUTOINCREMENT, host_id INTEGER, title TEXT, status TEXT DEFAULT 'live', viewers INTEGER DEFAULT 0, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
  `);

  // 1. TAKIP
  app.post('/api/follow/:id', auth, (req, res) => {
    const id = parseInt(req.params.id);
    if (id === req.uid) return res.status(400).json({ error: 'SELF' });
    try {
      db.prepare('INSERT INTO follows (follower, following) VALUES (?, ?)').run(req.uid, id);
      db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(id, 'follow', 'Yeni takipci', 'Biri seni takip etti');
      addXp(req.uid, 2);
      res.json({ ok: true });
    } catch (e) { res.status(400).json({ error: 'ALREADY_FOLLOWING' }); }
  });
  app.delete('/api/follow/:id', auth, (req, res) => {
    db.prepare('DELETE FROM follows WHERE follower = ? AND following = ?').run(req.uid, parseInt(req.params.id));
    res.json({ ok: true });
  });
  app.get('/api/follow/followers', auth, (req, res) => {
    res.json(db.prepare('SELECT u.id, u.username, u.vip, u.level FROM follows f JOIN users u ON u.id = f.follower WHERE f.following = ? LIMIT 100').all(req.uid));
  });
  app.get('/api/follow/following', auth, (req, res) => {
    res.json(db.prepare('SELECT u.id, u.username, u.vip, u.level FROM follows f JOIN users u ON u.id = f.following WHERE f.follower = ? LIMIT 100').all(req.uid));
  });
  app.get('/api/follow/count/:id', auth, (req, res) => {
    const id = parseInt(req.params.id);
    res.json({
      followers: db.prepare('SELECT COUNT(*) AS c FROM follows WHERE following = ?').get(id).c,
      following: db.prepare('SELECT COUNT(*) AS c FROM follows WHERE follower = ?').get(id).c
    });
  });

  // 2. ENGELLEME
  app.post('/api/block/:id', auth, (req, res) => {
    const id = parseInt(req.params.id);
    try {
      db.prepare('INSERT INTO blocks (user_id, blocked_id) VALUES (?, ?)').run(req.uid, id);
      db.prepare('DELETE FROM follows WHERE follower = ? AND following = ?').run(req.uid, id);
      db.prepare('DELETE FROM follows WHERE follower = ? AND following = ?').run(id, req.uid);
      res.json({ ok: true });
    } catch (e) { res.status(400).json({ error: 'ALREADY_BLOCKED' }); }
  });
  app.delete('/api/block/:id', auth, (req, res) => {
    db.prepare('DELETE FROM blocks WHERE user_id = ? AND blocked_id = ?').run(req.uid, parseInt(req.params.id));
    res.json({ ok: true });
  });
  app.get('/api/block/list', auth, (req, res) => {
    res.json(db.prepare('SELECT u.id, u.username FROM blocks b JOIN users u ON u.id = b.blocked_id WHERE b.user_id = ?').all(req.uid));
  });

  // 3. ARKADAS ISTEKLERI
  app.post('/api/friends/request/:id', auth, (req, res) => {
    const id = parseInt(req.params.id);
    if (id === req.uid) return res.status(400).json({ error: 'SELF' });
    try {
      db.prepare('INSERT INTO friend_requests (from_id, to_id) VALUES (?, ?)').run(req.uid, id);
      db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(id, 'friend_request', 'Arkadaslik istegi', 'Yeni arkadaslik istegi');
      res.json({ ok: true });
    } catch (e) { res.status(400).json({ error: 'ALREADY_SENT' }); }
  });
  app.post('/api/friends/accept/:id', auth, (req, res) => {
    db.prepare('UPDATE friend_requests SET status = ? WHERE from_id = ? AND to_id = ?').run('accepted', parseInt(req.params.id), req.uid);
    db.prepare('INSERT INTO notifications (user_id, type, title, body) VALUES (?, ?, ?, ?)').run(parseInt(req.params.id), 'friend_accept', 'Kabul edildi', 'Istegin kabul edildi');
    res.json({ ok: true });
  });
  app.post('/api/friends/reject/:id', auth, (req, res) => {
    db.prepare('UPDATE friend_requests SET status = ? WHERE from_id = ? AND to_id = ?').run('rejected', parseInt(req.params.id), req.uid);
    res.json({ ok: true });
  });
  app.get('/api/friends/requests', auth, (req, res) => {
    res.json(db.prepare('SELECT fr.id, fr.from_id, u.username, fr.created_at FROM friend_requests fr JOIN users u ON u.id = fr.from_id WHERE fr.to_id = ? AND fr.status = ? ORDER BY fr.id DESC').all(req.uid, 'pending'));
  });
  app.get('/api/friends/list', auth, (req, res) => {
    res.json(db.prepare('SELECT u.id, u.username, u.vip, u.level FROM friend_requests fr JOIN users u ON u.id = CASE WHEN fr.from_id = ? THEN fr.to_id ELSE fr.from_id END WHERE (fr.from_id = ? OR fr.to_id = ?) AND fr.status = ?').all(req.uid, req.uid, req.uid, 'accepted'));
  });

  // 4. BILDIRIMLER
  app.get('/api/notifications', auth, (req, res) => {
    res.json(db.prepare('SELECT * FROM notifications WHERE user_id = ? ORDER BY id DESC LIMIT 100').all(req.uid));
  });
  app.post('/api/notifications/read', auth, (req, res) => {
    db.prepare('UPDATE notifications SET is_read = 1 WHERE user_id = ?').run(req.uid);
    res.json({ ok: true });
  });
  app.get('/api/notifications/unread', auth, (req, res) => {
    res.json({ count: db.prepare('SELECT COUNT(*) AS c FROM notifications WHERE user_id = ? AND is_read = 0').get(req.uid).c });
  });

  // 5. POSTLAR
  app.post('/api/posts', auth, (req, res) => {
    const { text, media_url } = req.body;
    if (!text && !media_url) return res.status(400).json({ error: 'EMPTY' });
    const r = db.prepare('INSERT INTO posts (user_id, text, media_url) VALUES (?, ?, ?)').run(req.uid, text || '', media_url || null);
    res.json(db.prepare('SELECT * FROM posts WHERE id = ?').get(r.lastInsertRowid));
  });
  app.get('/api/posts', auth, (req, res) => {
    res.json(db.prepare('SELECT p.*, u.username, u.vip, u.level FROM posts p JOIN users u ON u.id = p.user_id WHERE p.user_id NOT IN (SELECT blocked_id FROM blocks WHERE user_id = ?) ORDER BY p.id DESC LIMIT 50').all(req.uid));
  });
  app.get('/api/posts/:id', auth, (req, res) => {
    res.json(db.prepare('SELECT p.*, u.username FROM posts p JOIN users u ON u.id = p.user_id WHERE p.id = ?').get(req.params.id));
  });
  app.delete('/api/posts/:id', auth, (req, res) => {
    db.prepare('DELETE FROM posts WHERE id = ? AND user_id = ?').run(req.params.id, req.uid);
    res.json({ ok: true });
  });

  // 6. YORUMLAR
  app.post('/api/posts/:id/comments', auth, (req, res) => {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'EMPTY' });
    const r = db.prepare('INSERT INTO comments (post_id, user_id, text) VALUES (?, ?, ?)').run(parseInt(req.params.id), req.uid, text);
    addXp(req.uid, 2);
    res.json(db.prepare('SELECT c.*, u.username FROM comments c JOIN users u ON u.id = c.user_id WHERE c.id = ?').get(r.lastInsertRowid));
  });
  app.get('/api/posts/:id/comments', auth, (req, res) => {
    res.json(db.prepare('SELECT c.*, u.username FROM comments c JOIN users u ON u.id = c.user_id WHERE c.post_id = ? ORDER BY c.id DESC LIMIT 100').all(req.params.id));
  });

  // 7. BEGENI
  app.post('/api/posts/:id/like', auth, (req, res) => {
    try {
      db.prepare('INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)').run(parseInt(req.params.id), req.uid);
      db.prepare('UPDATE posts SET likes = likes + 1 WHERE id = ?').run(req.params.id);
      addXp(req.uid, 1);
      res.json({ ok: true });
    } catch (e) { res.status(400).json({ error: 'ALREADY_LIKED' }); }
  });
  app.delete('/api/posts/:id/like', auth, (req, res) => {
    const r = db.prepare('DELETE FROM post_likes WHERE post_id = ? AND user_id = ?').run(parseInt(req.params.id), req.uid);
    if (r.changes > 0) db.prepare('UPDATE posts SET likes = MAX(0, likes - 1) WHERE id = ?').run(req.params.id);
    res.json({ ok: true });
  });

  // 8. KOLTUK YONETIMI
  app.post('/api/rooms/:id/seat/:index', auth, (req, res) => {
    const roomId = parseInt(req.params.id);
    const seatIdx = parseInt(req.params.index);
    if (seatIdx < 0 || seatIdx > 19) return res.status(400).json({ error: 'INVALID_SEAT' });
    const occupied = db.prepare('SELECT user_id FROM room_seats WHERE room_id = ? AND seat_index = ?').get(roomId, seatIdx);
    if (occupied && occupied.user_id) return res.status(409).json({ error: 'SEAT_TAKEN' });
    db.prepare('DELETE FROM room_seats WHERE room_id = ? AND user_id = ?').run(roomId, req.uid);
    db.prepare('INSERT OR REPLACE INTO room_seats (room_id, seat_index, user_id, is_muted) VALUES (?, ?, ?, 0)').run(roomId, seatIdx, req.uid);
    io.to('room_' + roomId).emit('seat:update', { roomId });
    res.json({ ok: true });
  });
  app.delete('/api/rooms/:id/seat', auth, (req, res) => {
    db.prepare('DELETE FROM room_seats WHERE room_id = ? AND user_id = ?').run(parseInt(req.params.id), req.uid);
    io.to('room_' + req.params.id).emit('seat:update', { roomId: req.params.id });
    res.json({ ok: true });
  });
  app.get('/api/rooms/:id/seats', auth, (req, res) => {
    res.json(db.prepare('SELECT rs.seat_index, rs.is_muted, u.id, u.username, u.vip, u.frame FROM room_seats rs LEFT JOIN users u ON u.id = rs.user_id WHERE rs.room_id = ? ORDER BY rs.seat_index').all(req.params.id));
  });

  // 9. ODA TEMALARI
  const THEMES = [
    { key: 'default', name: 'Varsayilan', price: 0 },
    { key: 'sunset', name: 'Gun Batimi', price: 10000 },
    { key: 'ocean', name: 'Okyanus', price: 15000 },
    { key: 'forest', name: 'Orman', price: 15000 },
    { key: 'galaxy', name: 'Galaksi', price: 50000 },
    { key: 'fire', name: 'Ates', price: 75000 },
    { key: 'ice', name: 'Buz', price: 75000 },
    { key: 'neon', name: 'Neon', price: 100000 },
    { key: 'royal', name: 'Kraliyet', price: 250000 },
    { key: 'dragon', name: 'Ejderha', price: 500000 }
  ];
  app.get('/api/themes', (req, res) => res.json(THEMES));
  app.get('/api/themes/my', auth, (req, res) => {
    res.json(db.prepare('SELECT theme_key FROM user_themes WHERE user_id = ?').all(req.uid).map(r => r.theme_key));
  });
  app.post('/api/themes/buy', auth, (req, res) => {
    const t = THEMES.find(x => x.key === req.body.key);
    if (!t) return res.status(400).json({ error: 'INVALID' });
    if (t.price > 0) {
      try { changeBal(req.uid, -t.price, 'theme_buy', t.key); }
      catch (e) { return res.status(400).json({ error: e.message }); }
    }
    db.prepare('INSERT OR IGNORE INTO user_themes (user_id, theme_key) VALUES (?, ?)').run(req.uid, t.key);
    res.json({ ok: true });
  });
  app.post('/api/rooms/:id/theme', auth, (req, res) => {
    const room = db.prepare('SELECT owner_id FROM rooms WHERE id = ?').get(req.params.id);
    if (!room || room.owner_id !== req.uid) return res.status(403).json({ error: 'NOT_OWNER' });
    db.prepare('UPDATE rooms SET theme = ? WHERE id = ?').run(req.body.theme, req.params.id);
    io.to('room_' + req.params.id).emit('room:theme', { theme: req.body.theme });
    res.json({ ok: true });
  });

  // 10. SESLI MESAJLAR
  app.post('/api/voice-messages', auth, (req, res) => {
    const { room_id, url, duration } = req.body;
    if (!url) return res.status(400).json({ error: 'NO_URL' });
    const r = db.prepare('INSERT INTO voice_messages (user_id, room_id, url, duration) VALUES (?, ?, ?, ?)').run(req.uid, room_id || null, url, duration || 0);
    if (room_id) io.to('room_' + room_id).emit('voice:new', { id: r.lastInsertRowid, user_id: req.uid, url, duration });
    addXp(req.uid, 5);
    res.json({ ok: true, id: r.lastInsertRowid });
  });
  app.get('/api/voice-messages', auth, (req, res) => {
    const q = req.query.room_id;
    if (q) res.json(db.prepare('SELECT v.*, u.username FROM voice_messages v JOIN users u ON u.id = v.user_id WHERE v.room_id = ? ORDER BY v.id DESC LIMIT 50').all(q));
    else res.json(db.prepare('SELECT v.*, u.username FROM voice_messages v JOIN users u ON u.id = v.user_id ORDER BY v.id DESC LIMIT 50').all());
  });

  // 11. PARTI MODU
  app.post('/api/party/queue', auth, (req, res) => {
    const { room_id, title, url } = req.body;
    if (!url) return res.status(400).json({ error: 'NO_URL' });
    const pos = db.prepare('SELECT COALESCE(MAX(position), 0) + 1 AS p FROM party_queue WHERE room_id = ?').get(room_id).p;
    const r = db.prepare('INSERT INTO party_queue (room_id, title, url, added_by, position) VALUES (?, ?, ?, ?, ?)').run(room_id, title || '', url, req.uid, pos);
    io.to('room_' + room_id).emit('party:update', { room_id });
    res.json({ ok: true, id: r.lastInsertRowid });
  });
  app.get('/api/party/queue/:roomId', auth, (req, res) => {
    res.json(db.prepare('SELECT q.*, u.username FROM party_queue q JOIN users u ON u.id = q.added_by WHERE q.room_id = ? ORDER BY q.position LIMIT 50').all(req.params.roomId));
  });
  app.delete('/api/party/queue/:id', auth, (req, res) => {
    db.prepare('DELETE FROM party_queue WHERE id = ? AND added_by = ?').run(req.params.id, req.uid);
    res.json({ ok: true });
  });

  // 12. MUZIK KATALOGU
  const MUSIC = [
    { id: 't1', title: 'Gece Yolculugu', artist: 'DJ Kaan' },
    { id: 't2', title: 'Kayip Sehir', artist: 'Nova' },
    { id: 't3', title: 'Yildiz Tozu', artist: 'Aurora' },
    { id: 't4', title: 'Alev', artist: 'Fenix' },
    { id: 't5', title: 'Okyanus', artist: 'Mavi' },
    { id: 't6', title: 'Ruzgar', artist: 'Firtina' },
    { id: 't7', title: 'Kalp Atisi', artist: 'Nabiz' },
    { id: 't8', title: 'Gokyuzu', artist: 'Bulut' },
    { id: 't9', title: 'Gun Dogumu', artist: 'Safak' },
    { id: 't10', title: 'Yildirim', artist: 'Simsek' }
  ];
  app.get('/api/music/catalog', auth, (req, res) => res.json(MUSIC));

  // 13. ODA MODERATORLERI
  app.post('/api/rooms/:id/mods/:uid', auth, (req, res) => {
    const room = db.prepare('SELECT owner_id FROM rooms WHERE id = ?').get(req.params.id);
    if (!room || room.owner_id !== req.uid) return res.status(403).json({ error: 'NOT_OWNER' });
    db.prepare('INSERT OR IGNORE INTO room_mods (room_id, user_id) VALUES (?, ?)').run(req.params.id, parseInt(req.params.uid));
    res.json({ ok: true });
  });
  app.delete('/api/rooms/:id/mods/:uid', auth, (req, res) => {
    const room = db.prepare('SELECT owner_id FROM rooms WHERE id = ?').get(req.params.id);
    if (!room || room.owner_id !== req.uid) return res.status(403).json({ error: 'NOT_OWNER' });
    db.prepare('DELETE FROM room_mods WHERE room_id = ? AND user_id = ?').run(req.params.id, parseInt(req.params.uid));
    res.json({ ok: true });
  });
  app.get('/api/rooms/:id/mods', auth, (req, res) => {
    res.json(db.prepare('SELECT u.id, u.username FROM room_mods rm JOIN users u ON u.id = rm.user_id WHERE rm.room_id = ?').all(req.params.id));
  });

  // 14. KICK/MUTE
  app.post('/api/rooms/:id/kick/:uid', auth, (req, res) => {
    const room = db.prepare('SELECT owner_id FROM rooms WHERE id = ?').get(req.params.id);
    const isMod = db.prepare('SELECT 1 FROM room_mods WHERE room_id = ? AND user_id = ?').get(req.params.id, req.uid);
    if (!room || (room.owner_id !== req.uid && !isMod)) return res.status(403).json({ error: 'FORBIDDEN' });
    io.to('user_' + req.params.uid).emit('room:kicked', { roomId: req.params.id });
    res.json({ ok: true });
  });
  app.post('/api/rooms/:id/mute/:uid', auth, (req, res) => {
    const room = db.prepare('SELECT owner_id FROM rooms WHERE id = ?').get(req.params.id);
    const isMod = db.prepare('SELECT 1 FROM room_mods WHERE room_id = ? AND user_id = ?').get(req.params.id, req.uid);
    if (!room || (room.owner_id !== req.uid && !isMod)) return res.status(403).json({ error: 'FORBIDDEN' });
    db.prepare('UPDATE room_seats SET is_muted = 1 WHERE room_id = ? AND user_id = ?').run(req.params.id, req.params.uid);
    io.to('room_' + req.params.id).emit('room:muted', { userId: req.params.uid });
    res.json({ ok: true });
  });

  // 15. SEZON
  app.get('/api/seasons/current', auth, (req, res) => {
    let s = db.prepare('SELECT * FROM seasons ORDER BY id DESC LIMIT 1').get();
    if (!s) {
      const r = db.prepare('INSERT INTO seasons (name, start, end, reward_pool) VALUES (?, ?, ?, ?)').run('Sezon 1', new Date().toISOString(), new Date(Date.now() + 30 * 86400000).toISOString(), 500000000);
      s = db.prepare('SELECT * FROM seasons WHERE id = ?').get(r.lastInsertRowid);
    }
    const me = db.prepare('SELECT points FROM season_points WHERE season_id = ? AND user_id = ?').get(s.id, req.uid) || { points: 0 };
    const lb = db.prepare('SELECT u.id, u.username, sp.points FROM season_points sp JOIN users u ON u.id = sp.user_id WHERE sp.season_id = ? ORDER BY sp.points DESC LIMIT 50').all(s.id);
    res.json({ season: s, my: me, leaderboard: lb });
  });
  app.post('/api/seasons/points', auth, (req, res) => {
    const pts = parseInt(req.body.points) || 0;
    if (pts <= 0) return res.status(400).json({ error: 'INVALID' });
    let s = db.prepare('SELECT id FROM seasons ORDER BY id DESC LIMIT 1').get();
    if (!s) {
      const r = db.prepare('INSERT INTO seasons (name, start, end) VALUES (?, ?, ?)').run('Sezon 1', new Date().toISOString(), new Date(Date.now() + 30 * 86400000).toISOString());
      s = { id: r.lastInsertRowid };
    }
    const existing = db.prepare('SELECT points FROM season_points WHERE season_id = ? AND user_id = ?').get(s.id, req.uid);
    if (existing) db.prepare('UPDATE season_points SET points = points + ? WHERE season_id = ? AND user_id = ?').run(pts, s.id, req.uid);
    else db.prepare('INSERT INTO season_points (season_id, user_id, points) VALUES (?, ?, ?)').run(s.id, req.uid, pts);
    res.json({ ok: true });
  });

  // 16. TURNUVA
  app.post('/api/tournaments', auth, (req, res) => {
    const { name, entry_fee, max_players } = req.body;
    if (!name) return res.status(400).json({ error: 'NO_NAME' });
    const r = db.prepare('INSERT INTO tournaments (name, entry_fee, max_players) VALUES (?, ?, ?)').run(name, parseInt(entry_fee) || 0, parseInt(max_players) || 8);
    res.json(db.prepare('SELECT * FROM tournaments WHERE id = ?').get(r.lastInsertRowid));
  });
  app.get('/api/tournaments', auth, (req, res) => {
    res.json(db.prepare('SELECT t.*, (SELECT COUNT(*) FROM tournament_players WHERE tournament_id = t.id) AS players FROM tournaments t ORDER BY t.id DESC LIMIT 20').all());
  });
  app.post('/api/tournaments/:id/join', auth, (req, res) => {
    const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(req.params.id);
    if (!t || t.status !== 'reg') return res.status(400).json({ error: 'NOT_OPEN' });
    if (t.entry_fee > 0) {
      try { changeBal(req.uid, -t.entry_fee, 'tournament_entry', String(t.id)); }
      catch (e) { return res.status(400).json({ error: e.message }); }
    }
    try {
      db.prepare('INSERT INTO tournament_players (tournament_id, user_id) VALUES (?, ?)').run(t.id, req.uid);
      db.prepare('UPDATE tournaments SET prize_pool = prize_pool + ? WHERE id = ?').run(t.entry_fee, t.id);
    } catch (e) { return res.status(400).json({ error: 'ALREADY_JOINED' }); }
    res.json({ ok: true });
  });

  // 17. KLAN SAVASLARI
  app.post('/api/clans/war/start', auth, (req, res) => {
    const my = db.prepare('SELECT clan_id FROM clan_members WHERE user_id = ? AND role = ?').get(req.uid, 'owner');
    if (!my) return res.status(403).json({ error: 'NOT_OWNER' });
    const enemy = parseInt(req.body.enemyClanId);
    if (!enemy || enemy === my.clan_id) return res.status(400).json({ error: 'INVALID_ENEMY' });
    const r = db.prepare('INSERT INTO clan_wars (clan1, clan2) VALUES (?, ?)').run(my.clan_id, enemy);
    res.json({ ok: true, id: r.lastInsertRowid });
  });
  app.get('/api/clans/:id/war', auth, (req, res) => {
    res.json(db.prepare('SELECT * FROM clan_wars WHERE (clan1 = ? OR clan2 = ?) AND status = ? ORDER BY id DESC LIMIT 1').get(req.params.id, req.params.id, 'active') || null);
  });

  // 18. CANLI YAYIN (metadata)
  app.post('/api/live/start', auth, (req, res) => {
    const { title } = req.body;
    const r = db.prepare('INSERT INTO live_streams (host_id, title) VALUES (?, ?)').run(req.uid, title || 'Canli Yayin');
    res.json(db.prepare('SELECT * FROM live_streams WHERE id = ?').get(r.lastInsertRowid));
  });
  app.get('/api/live/active', auth, (req, res) => {
    res.json(db.prepare('SELECT l.*, u.username FROM live_streams l JOIN users u ON u.id = l.host_id WHERE l.status = ? ORDER BY l.viewers DESC LIMIT 50').all('live'));
  });
  app.post('/api/live/:id/end', auth, (req, res) => {
    db.prepare('UPDATE live_streams SET status = ? WHERE id = ? AND host_id = ?').run('ended', req.params.id, req.uid);
    res.json({ ok: true });
  });
  app.post('/api/live/:id/view', auth, (req, res) => {
    db.prepare('UPDATE live_streams SET viewers = viewers + 1 WHERE id = ?').run(req.params.id);
    res.json({ ok: true });
  });

  console.log('[systems18] 18 sistem yuklendi');
};
