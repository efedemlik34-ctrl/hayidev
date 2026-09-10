// ═══ Turnuva Bracket + Klan Savaşı Puanlama — TAM ═══
module.exports = function(ctx) {
  const { app, db, io, auth, adminOnly, changeBal, addXp } = ctx;

  // ═══ SİSTEM 41: TURNUVA — 8/16/32 BRACKET ═══
  const tournaments = {}; // tid -> { bracket, rounds, currentRound, players }

  function makeBracket(players) {
    // players: [uid, uid, ...] — 8/16/32 olmalı
    const n = players.length;
    const rounds = [];
    const first = [];
    for (let i = 0; i < n; i += 2) {
      first.push({
        id: 'm_' + Date.now() + '_r1_' + (i / 2),
        round: 1,
        p1: players[i],
        p2: players[i + 1],
        winner: null,
        status: 'pending'
      });
    }
    rounds.push(first);
    return rounds;
  }

  app.post('/api/tournaments/:id/start', auth, adminOnly, (req, res) => {
    const tid = parseInt(req.params.id);
    const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(tid);
    if (!t) return res.status(404).json({ error: 'NOT_FOUND' });
    const players = db.prepare('SELECT user_id FROM tournament_players WHERE tournament_id = ?').all(tid).map(r => r.user_id);
    if (players.length !== 8 && players.length !== 16 && players.length !== 32) {
      return res.status(400).json({ error: 'NEED_8_16_OR_32', current: players.length });
    }
    // Karıştır
    const shuffled = players.sort(() => Math.random() - 0.5);
    const rounds = makeBracket(shuffled);
    tournaments[tid] = { rounds, currentRound: 0, players: shuffled, status: 'running' };
    db.prepare('UPDATE tournaments SET status = ? WHERE id = ?').run('running', tid);
    io.emit('tournament:started', { tid, round: 1, matches: rounds[0].length });
    res.json({ ok: true, round1Matches: rounds[0].length });
  });

  app.get('/api/tournaments/:id/bracket', auth, (req, res) => {
    const state = tournaments[req.params.id];
    if (!state) return res.json({ rounds: [], status: 'not_started' });
    // Oyuncu isimlerini ekle
    const withNames = state.rounds.map(round => round.map(m => ({
      id: m.id,
      round: m.round,
      p1: m.p1 ? db.prepare('SELECT username FROM users WHERE id = ?').get(m.p1)?.username || '?' : null,
      p2: m.p2 ? db.prepare('SELECT username FROM users WHERE id = ?').get(m.p2)?.username || '?' : null,
      winner: m.winner ? db.prepare('SELECT username FROM users WHERE id = ?').get(m.winner)?.username || '?' : null,
      status: m.status
    })));
    res.json({ rounds: withNames, currentRound: state.currentRound, status: state.status });
  });

  app.post('/api/tournaments/:id/report', auth, (req, res) => {
    const tid = parseInt(req.params.id);
    const { matchId, winnerId } = req.body;
    const state = tournaments[tid];
    if (!state || state.status !== 'running') return res.status(400).json({ error: 'NOT_RUNNING' });

    let match = null;
    for (const round of state.rounds) {
      const m = round.find(x => x.id === matchId);
      if (m) { match = m; break; }
    }
    if (!match || match.status !== 'pending') return res.status(400).json({ error: 'INVALID_MATCH' });
    if (winnerId !== match.p1 && winnerId !== match.p2) return res.status(400).json({ error: 'INVALID_WINNER' });

    match.winner = winnerId;
    match.status = 'done';
    io.emit('tournament:match_done', { tid, matchId, winnerId });

    // Bu tur bitti mi?
    const currentRound = state.rounds[state.currentRound];
    if (currentRound.every(m => m.status === 'done')) {
      const winners = currentRound.map(m => m.winner);
      if (winners.length === 1) {
        state.status = 'finished';
        const t = db.prepare('SELECT * FROM tournaments WHERE id = ?').get(tid);
        const prize = Math.floor(t.prize_pool * 0.6);
        try { changeBal(winners[0], prize, 'tournament_win', String(tid)); } catch (e) {}
        db.prepare('UPDATE tournaments SET status = ? WHERE id = ?').run('finished', tid);
        io.emit('tournament:finished', { tid, winner: winners[0], prize });
      } else {
        const next = [];
        for (let i = 0; i < winners.length; i += 2) {
          next.push({
            id: 'm_' + Date.now() + '_r' + (state.rounds.length + 1) + '_' + (i / 2),
            round: state.rounds.length + 1,
            p1: winners[i],
            p2: winners[i + 1],
            winner: null,
            status: 'pending'
          });
        }
        state.rounds.push(next);
        state.currentRound++;
        io.emit('tournament:round', { tid, round: state.rounds.length });
      }
    }
    res.json({ ok: true });
  });

  // ═══ SİSTEM 42: KLAN SAVAŞI PUANLAMA — TAM ═══
  const addWarPoints = (uid, points) => {
    const cm = db.prepare('SELECT clan_id FROM clan_members WHERE user_id = ? LIMIT 1').get(uid);
    if (!cm) return;
    const war = db.prepare("SELECT * FROM clan_wars WHERE (clan1 = ? OR clan2 = ?) AND status = \'active\' ORDER BY id DESC LIMIT 1").get(cm.clan_id, cm.clan_id);
    if (!war) return;
    if (war.clan1 === cm.clan_id) {
      db.prepare('UPDATE clan_wars SET score1 = score1 + ? WHERE id = ?').run(points, war.id);
    } else {
      db.prepare('UPDATE clan_wars SET score2 = score2 + ? WHERE id = ?').run(points, war.id);
    }
    io.emit('war:update', { warId: war.id, clan: cm.clan_id, points });
  };

  app.post('/api/clans/war/start', auth, (req, res) => {
    const my = db.prepare("SELECT clan_id FROM clan_members WHERE user_id = ? AND role = \'owner\'").get(req.uid);
    if (!my) return res.status(403).json({ error: 'NOT_OWNER' });
    const enemy = parseInt(req.body.enemyClanId);
    if (!enemy || enemy === my.clan_id) return res.status(400).json({ error: 'INVALID' });
    const r = db.prepare('INSERT INTO clan_wars (clan1, clan2) VALUES (?, ?)').run(my.clan_id, enemy);
    res.json({ ok: true, warId: r.lastInsertRowid });
  });

  app.get('/api/clans/:id/war', auth, (req, res) => {
    const war = db.prepare("SELECT * FROM clan_wars WHERE (clan1 = ? OR clan2 = ?) AND status = \'active\' ORDER BY id DESC LIMIT 1").get(req.params.id, req.params.id);
    if (!war) return res.json(null);
    const c1 = db.prepare('SELECT name FROM clans WHERE id = ?').get(war.clan1)?.name || '?';
    const c2 = db.prepare('SELECT name FROM clans WHERE id = ?').get(war.clan2)?.name || '?';
    res.json({ ...war, clan1Name: c1, clan2Name: c2 });
  });

  app.post('/api/clans/war/:id/end', auth, (req, res) => {
    const war = db.prepare('SELECT * FROM clan_wars WHERE id = ?').get(req.params.id);
    if (!war) return res.status(404).json({ error: 'NOT_FOUND' });
    const winner = war.score1 > war.score2 ? war.clan1 : war.clan2;
    if (war.score1 === war.score2) {
      db.prepare('UPDATE clan_wars SET status = ? WHERE id = ?').run('draw', req.params.id);
      return res.json({ ok: true, result: 'draw' });
    }
    db.prepare('UPDATE clan_wars SET status = ? WHERE id = ?').run('finished', req.params.id);
    db.prepare('UPDATE clans SET points = points + 100 WHERE id = ?').run(winner);
    res.json({ ok: true, winner });
  });

  app.post('/api/clans/war/points', auth, (req, res) => {
    const pts = parseInt(req.body.points) || 0;
    if (pts <= 0) return res.status(400).json({ error: 'INVALID' });
    addWarPoints(req.uid, pts);
    res.json({ ok: true });
  });

  // Otomatik: her oyun kazancında çağır
  app.post('/api/games/report-war', auth, (req, res) => {
    addWarPoints(req.uid, 10);
    res.json({ ok: true });
  });

  console.log('[systems_bracket] turnuva + klan savasi TAM yuklendi');
};
