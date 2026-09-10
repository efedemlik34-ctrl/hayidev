// ═══ Sesli Mesaj + Parti Modu — TAM ═══
const multer = require('multer');
const path = require('path');
const fs = require('fs');

module.exports = function(ctx) {
  const { app, db, io, auth, changeBal, addXp } = ctx;

  // Yükleme klasörü
  const UPLOAD_DIR = path.join(__dirname, 'uploads', 'voice');
  if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

  const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, UPLOAD_DIR),
    filename: (req, file, cb) => cb(null, Date.now() + '_' + req.uid + '.m4a')
  });
  const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } });

  // ═══ SİSTEM 35: SESLİ MESAJ — TAM ═══
  app.post('/api/voice/upload', auth, upload.single('voice'), (req, res) => {
    if (!req.file) return res.status(400).json({ error: 'NO_FILE' });
    const { roomId, duration } = req.body;
    const url = '/uploads/voice/' + req.file.filename;
    const r = db.prepare('INSERT INTO voice_messages (user_id, room_id, url, duration) VALUES (?, ?, ?, ?)').run(req.uid, roomId || null, url, parseInt(duration) || 0);
    const u = db.prepare('SELECT username FROM users WHERE id = ?').get(req.uid);
    if (roomId) io.to('room_' + roomId).emit('voice:new', { id: r.lastInsertRowid, user_id: req.uid, username: u.username, url, duration: parseInt(duration) || 0 });
    addXp(req.uid, 5);
    res.json({ ok: true, id: r.lastInsertRowid, url });
  });

  app.get('/api/voice/list', auth, (req, res) => {
    const roomId = req.query.room_id;
    let rows;
    if (roomId) rows = db.prepare('SELECT v.*, u.username FROM voice_messages v JOIN users u ON u.id = v.user_id WHERE v.room_id = ? ORDER BY v.id DESC LIMIT 50').all(roomId);
    else rows = db.prepare('SELECT v.*, u.username FROM voice_messages v JOIN users u ON u.id = v.user_id WHERE v.room_id IS NULL ORDER BY v.id DESC LIMIT 50').all();
    res.json(rows);
  });

  app.delete('/api/voice/:id', auth, (req, res) => {
    const r = db.prepare('SELECT url, user_id FROM voice_messages WHERE id = ?').get(req.params.id);
    if (!r) return res.status(404).json({ error: 'NOT_FOUND' });
    if (r.user_id !== req.uid) return res.status(403).json({ error: 'NOT_OWNER' });
    db.prepare('DELETE FROM voice_messages WHERE id = ?').run(req.params.id);
    const filepath = path.join(__dirname, r.url.replace('/uploads/voice/', 'uploads/voice/'));
    if (fs.existsSync(filepath)) fs.unlinkSync(filepath);
    res.json({ ok: true });
  });

  // ═══ SİSTEM 36: PARTİ MODU — TAM (Senkronize müzik) ═══
  // Her odada tek bir DJ, müzik pozisyonu timestamp ile senkronize
  const partyState = {}; // roomId -> { current, startedAt, playing, dj, queue }

  const broadcastParty = (roomId) => {
    const st = partyState[roomId];
    if (!st) return;
    io.to('room_' + roomId).emit('party:state', {
      roomId: roomId,
      playing: st.playing,
      dj: st.dj,
      current: st.current,
      startedAt: st.startedAt,
      elapsed: st.playing ? Math.floor((Date.now() - st.startedAt) / 1000) : 0
    });
  };

  app.post('/api/party/take-dj', auth, (req, res) => {
    const roomId = req.body.roomId;
    if (!partyState[roomId]) partyState[roomId] = { queue: [], current: null, playing: false, startedAt: 0, dj: null };
    partyState[roomId].dj = req.uid;
    broadcastParty(roomId);
    res.json({ ok: true });
  });

  app.post('/api/party/queue', auth, (req, res) => {
    const { roomId, title, url, artist } = req.body;
    if (!url) return res.status(400).json({ error: 'NO_URL' });
    if (!partyState[roomId]) partyState[roomId] = { queue: [], current: null, playing: false, startedAt: 0, dj: null };
    partyState[roomId].queue.push({ id: Date.now() + '_' + req.uid, title: title || 'Bilinmeyen', url, artist: artist || '', addedBy: req.uid, addedAt: Date.now() });
    broadcastParty(roomId);
    res.json({ ok: true, queueLength: partyState[roomId].queue.length });
  });

  app.get('/api/party/queue/:roomId', auth, (req, res) => {
    const st = partyState[req.params.roomId] || { queue: [], current: null, playing: false, dj: null, startedAt: 0 };
    res.json({
      queue: st.queue,
      current: st.current,
      playing: st.playing,
      dj: st.dj,
      elapsed: st.playing ? Math.floor((Date.now() - st.startedAt) / 1000) : 0
    });
  });

  app.post('/api/party/play', auth, (req, res) => {
    const { roomId, trackId } = req.body;
    const st = partyState[roomId];
    if (!st) return res.status(404).json({ error: 'NO_ROOM' });
    if (st.dj !== req.uid) return res.status(403).json({ error: 'NOT_DJ' });
    const idx = st.queue.findIndex(t => t.id === trackId);
    if (idx < 0) return res.status(404).json({ error: 'TRACK_NOT_FOUND' });
    st.current = st.queue[idx];
    st.queue.splice(idx, 1);
    st.playing = true;
    st.startedAt = Date.now();
    broadcastParty(roomId);
    res.json({ ok: true });
  });

  app.post('/api/party/pause', auth, (req, res) => {
    const st = partyState[req.body.roomId];
    if (!st || st.dj !== req.uid) return res.status(403).json({ error: 'NOT_DJ' });
    st.playing = false;
    broadcastParty(req.body.roomId);
    res.json({ ok: true });
  });

  app.post('/api/party/resume', auth, (req, res) => {
    const st = partyState[req.body.roomId];
    if (!st || st.dj !== req.uid) return res.status(403).json({ error: 'NOT_DJ' });
    st.playing = true;
    st.startedAt = Date.now();
    broadcastParty(req.body.roomId);
    res.json({ ok: true });
  });

  app.post('/api/party/skip', auth, (req, res) => {
    const st = partyState[req.body.roomId];
    if (!st || st.dj !== req.uid) return res.status(403).json({ error: 'NOT_DJ' });
    st.current = null;
    st.playing = false;
    st.startedAt = 0;
    if (st.queue.length) {
      st.current = st.queue.shift();
      st.playing = true;
      st.startedAt = Date.now();
    }
    broadcastParty(req.body.roomId);
    res.json({ ok: true });
  });

  app.post('/api/party/release-dj', auth, (req, res) => {
    const st = partyState[req.body.roomId];
    if (!st) return res.status(404).json({ error: 'NO_ROOM' });
    if (st.dj === req.uid) st.dj = null;
    broadcastParty(req.body.roomId);
    res.json({ ok: true });
  });

  // ═══ MUZIK KATALOGU (parça indirme) ═══
  const MUSIC = [
    { id: 't1', title: 'Gece Yolculugu', artist: 'DJ Kaan', url: '/uploads/voice/demo1.mp3', duration: 180 },
    { id: 't2', title: 'Kayip Sehir', artist: 'Nova', url: '/uploads/voice/demo2.mp3', duration: 200 },
    { id: 't3', title: 'Yildiz Tozu', artist: 'Aurora', url: '/uploads/voice/demo3.mp3', duration: 220 },
    { id: 't4', title: 'Alev', artist: 'Fenix', url: '/uploads/voice/demo4.mp3', duration: 190 },
    { id: 't5', title: 'Okyanus', artist: 'Mavi', url: '/uploads/voice/demo5.mp3', duration: 210 },
    { id: 't6', title: 'Ruzgar', artist: 'Firtina', url: '/uploads/voice/demo6.mp3', duration: 175 },
    { id: 't7', title: 'Kalp Atisi', artist: 'Nabiz', url: '/uploads/voice/demo7.mp3', duration: 240 },
    { id: 't8', title: 'Gokyuzu', artist: 'Bulut', url: '/uploads/voice/demo8.mp3', duration: 200 },
    { id: 't9', title: 'Gun Dogumu', artist: 'Safak', url: '/uploads/voice/demo9.mp3', duration: 185 },
    { id: 't10', title: 'Yildirim', artist: 'Simsek', url: '/uploads/voice/demo10.mp3', duration: 195 }
  ];
  app.get('/api/music/catalog', (req, res) => res.json(MUSIC));

  console.log('[systems_audio] sesli mesaj + parti modu TAM yuklendi');
};
