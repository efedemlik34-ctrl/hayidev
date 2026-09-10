// ═══ Canlı Yayın — Agora Entegre TAM ═══
module.exports = function(ctx) {
  const { app, db, io, auth, changeBal } = ctx;

  // Agora token helper (opsiyonel)
  let RtcTokenBuilder = null;
  try {
    const agora = require('agora-token');
    RtcTokenBuilder = agora.RtcTokenBuilder;
  } catch (e) {
    console.log('[systems_live] agora-token kurulu degil, mock token uretilecek');
  }

  const AGORA_APP_ID = process.env.AGORA_APP_ID || 'demo-app-id';
  const AGORA_APP_CERT = process.env.AGORA_APP_CERT || '';

  app.post('/api/live/start', auth, (req, res) => {
    const { title, category } = req.body;
    const active = db.prepare("SELECT id FROM live_streams WHERE host_id = ? AND status = 'live'").get(req.uid);
    if (active) return res.status(400).json({ error: 'ALREADY_LIVE' });
    const r = db.prepare('INSERT INTO live_streams (host_id, title) VALUES (?, ?)').run(req.uid, title || 'Canli Yayin');
    const stream = db.prepare('SELECT * FROM live_streams WHERE id = ?').get(r.lastInsertRowid);
    io.emit('live:new', { id: stream.id, host_id: req.uid, title: stream.title });
    res.json(stream);
  });

  app.get('/api/live/active', auth, (req, res) => {
    const rows = db.prepare("SELECT l.*, u.username, u.vip, u.frame FROM live_streams l JOIN users u ON u.id = l.host_id WHERE l.status = 'live' ORDER BY l.viewers DESC LIMIT 50").all();
    res.json(rows);
  });

  app.get('/api/live/:id', auth, (req, res) => {
    const s = db.prepare('SELECT l.*, u.username FROM live_streams l JOIN users u ON u.id = l.host_id WHERE l.id = ?').get(req.params.id);
    if (!s) return res.status(404).json({ error: 'NOT_FOUND' });
    res.json(s);
  });

  // Agora token üret — yayıncı PUBLISHER, izleyici SUBSCRIBER
  app.get('/api/live/:id/token', auth, (req, res) => {
    const s = db.prepare('SELECT * FROM live_streams WHERE id = ?').get(req.params.id);
    if (!s) return res.status(404).json({ error: 'NOT_FOUND' });
    if (s.status !== 'live') return res.status(400).json({ error: 'NOT_LIVE' });

    const isHost = s.host_id === req.uid;
    const channelName = 'live_' + s.id;
    const uid = req.uid;
    const expireTs = Math.floor(Date.now() / 1000) + 7200;

    let token = 'mock_token_' + s.id + '_' + req.uid;
    if (RtcTokenBuilder && AGORA_APP_CERT) {
      try {
        const role = isHost ? 1 : 2; // 1=PUBLISHER, 2=SUBSCRIBER
        token = RtcTokenBuilder.buildTokenWithUid(AGORA_APP_ID, AGORA_APP_CERT, channelName, uid, role, expireTs, expireTs);
      } catch (e) {
        console.log('Agora token error:', e.message);
      }
    }

    if (!isHost) {
      db.prepare('UPDATE live_streams SET viewers = viewers + 1 WHERE id = ?').run(s.id);
      io.to('live_' + s.id).emit('live:viewer_join', { userId: req.uid });
    }

    res.json({ token, channel: channelName, appId: AGORA_APP_ID, role: isHost ? 'host' : 'viewer', uid });
  });

  app.post('/api/live/:id/end', auth, (req, res) => {
    const s = db.prepare('SELECT * FROM live_streams WHERE id = ?').get(req.params.id);
    if (!s) return res.status(404).json({ error: 'NOT_FOUND' });
    if (s.host_id !== req.uid) return res.status(403).json({ error: 'NOT_HOST' });
    db.prepare("UPDATE live_streams SET status = 'ended' WHERE id = ?").run(req.params.id);
    io.to('live_' + req.params.id).emit('live:ended', { id: req.params.id });
    res.json({ ok: true });
  });

  app.post('/api/live/:id/like', auth, (req, res) => {
    db.prepare('UPDATE live_streams SET viewers = viewers WHERE id = ?').run(req.params.id);
    io.to('live_' + req.params.id).emit('live:like', { userId: req.uid, ts: Date.now() });
    res.json({ ok: true });
  });

  // Canlı yayın chat
  app.post('/api/live/:id/comment', auth, (req, res) => {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'EMPTY' });
    const u = db.prepare('SELECT username FROM users WHERE id = ?').get(req.uid);
    io.to('live_' + req.params.id).emit('live:comment', { userId: req.uid, username: u.username, text, ts: Date.now() });
    res.json({ ok: true });
  });

  console.log('[systems_live] canli yayin TAM yuklendi');
};
