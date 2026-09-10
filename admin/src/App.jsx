import React, { useState, useEffect } from 'react';
import axios from 'axios';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [id, setId] = useState('admin@hayidev.app');
  const [pw, setPw] = useState('HayiDev@2026!Admin');
  const [stats, setStats] = useState(null);
  const [users, setUsers] = useState([]);
  const [err, setErr] = useState('');

  useEffect(() => {
    if (!token) return;
    axios.defaults.headers.common['Authorization'] = 'Bearer ' + token;
    load();
    const t = setInterval(load, 8000);
    return () => clearInterval(t);
  }, [token]);

  const load = async () => {
    try {
      const s = await axios.get('/api/admin/stats');
      const u = await axios.get('/api/admin/users');
      setStats(s.data);
      setUsers(u.data);
    } catch (e) {
      if (e.response?.status === 401) { localStorage.removeItem('token'); setToken(null); }
    }
  };

  const login = async (e) => {
    e.preventDefault();
    setErr('');
    try {
      const r = await axios.post('/api/admin/login', { identifier: id, password: pw });
      localStorage.setItem('token', r.data.token);
      setToken(r.data.token);
    } catch (e) { setErr(e.response?.data?.error || 'Hata'); }
  };

  const give = async (uid) => {
    const a = prompt('Coin:');
    if (!a) return;
    await axios.post('/api/admin/users/' + uid + '/balance', { amount: parseInt(a) });
    load();
  };

  const ban = async (uid, b) => {
    await axios.post('/api/admin/users/' + uid + '/ban', { banned: b });
    load();
  };

  if (!token) {
    const inp = { width: '100%', background: '#ffffff10', border: 'none', color: '#fff', padding: 14, borderRadius: 10, marginBottom: 12, boxSizing: 'border-box' };
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 24 }}>
        <form onSubmit={login} style={{ width: 400, background: '#1A0F3E', padding: 40, borderRadius: 20, border: '1px solid #FFC107' }}>
          <div style={{ textAlign: 'center', fontSize: 36, fontWeight: 'bold', color: '#FFC107' }}>HayiDev</div>
          <div style={{ textAlign: 'center', fontSize: 11, color: '#ffffff60', letterSpacing: 3, marginBottom: 32 }}>25 SISTEM ADMIN</div>
          {err && <div style={{ background: '#F4433630', color: '#F44336', padding: 12, borderRadius: 8, marginBottom: 16 }}>{err}</div>}
          <input value={id} onChange={(e) => setId(e.target.value)} style={inp} placeholder="E-posta" />
          <input type="password" value={pw} onChange={(e) => setPw(e.target.value)} style={inp} placeholder="Sifre" />
          <button style={{ width: '100%', background: '#FFC107', color: '#000', border: 'none', padding: 14, borderRadius: 10, fontWeight: 'bold', cursor: 'pointer' }}>GIRIS YAP</button>
        </form>
      </div>
    );
  }

  if (!stats) return <div style={{ padding: 40, color: '#fff' }}>Yukleniyor...</div>;

  return (
    <div style={{ padding: 24, maxWidth: 1400, margin: '0 auto', color: '#fff' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 24 }}>
        <h1 style={{ margin: 0 }}>HayiDev Admin</h1>
        <button onClick={() => { localStorage.clear(); setToken(null); }} style={{ background: '#F4433620', color: '#F44336', border: '1px solid #F44336', padding: '8px 16px', borderRadius: 8, cursor: 'pointer' }}>Cikis</button>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 16, marginBottom: 24 }}>
        {[['Kullanici', stats.users, '#4CAF50'], ['Oda', stats.rooms, '#2196F3'], ['Bakiye', Math.floor(stats.balance/1000) + 'K', '#FFC107'], ['Bahis', Math.floor(stats.bets/1000) + 'K', '#FF6B35'], ['Hediye', stats.gifts, '#E91E63'], ['Mesaj', stats.messages, '#9C27B0'], ['Klan', stats.clans, '#3F51B5'], ['Sikayet', stats.reports, '#F44336']].map((row, i) => (
          <div key={i} style={{ background: '#1A0F3E', padding: 20, borderRadius: 16, border: '1px solid #ffffff10' }}>
            <div style={{ color: '#ffffff60', fontSize: 12 }}>{row[0]}</div>
            <div style={{ color: row[2], fontSize: 26, fontWeight: 'bold' }}>{row[1]}</div>
          </div>
        ))}
      </div>
      <table style={{ width: '100%', fontSize: 13, background: '#1A0F3E', borderRadius: 16, overflow: 'hidden', borderCollapse: 'collapse' }}>
        <thead style={{ background: '#ffffff08', color: '#ffffff60', fontSize: 11, textTransform: 'uppercase' }}>
          <tr>
            <th style={{ textAlign: 'left', padding: 12 }}>Kullanici</th>
            <th style={{ textAlign: 'left', padding: 12 }}>E-posta</th>
            <th style={{ textAlign: 'right', padding: 12 }}>Bakiye</th>
            <th style={{ textAlign: 'center', padding: 12 }}>VIP</th>
            <th style={{ textAlign: 'center', padding: 12 }}>Seviye</th>
            <th style={{ textAlign: 'center', padding: 12 }}>Durum</th>
            <th style={{ textAlign: 'right', padding: 12 }}>Islem</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id} style={{ borderTop: '1px solid #ffffff10' }}>
              <td style={{ padding: 12 }}>{u.username} {u.is_admin ? '👑' : ''}</td>
              <td style={{ padding: 12, color: '#ffffff60' }}>{u.email}</td>
              <td style={{ padding: 12, textAlign: 'right', color: '#FFC107', fontWeight: 'bold' }}>{u.balance}</td>
              <td style={{ padding: 12, textAlign: 'center' }}>VIP{u.vip}</td>
              <td style={{ padding: 12, textAlign: 'center' }}>{u.level}</td>
              <td style={{ padding: 12, textAlign: 'center' }}>{u.is_banned ? 'BAN' : 'OK'}</td>
              <td style={{ padding: 12, textAlign: 'right' }}>
                <button onClick={() => give(u.id)} style={{ background: '#FFC10730', color: '#FFC107', border: 'none', padding: '6px 10px', borderRadius: 6, cursor: 'pointer', fontSize: 11, marginRight: 4 }}>COIN</button>
                <button onClick={() => ban(u.id, !u.is_banned)} style={{ background: u.is_banned ? '#4CAF5030' : '#F4433630', color: u.is_banned ? '#4CAF50' : '#F44336', border: 'none', padding: '6px 10px', borderRadius: 6, cursor: 'pointer', fontSize: 11 }}>{u.is_banned ? 'AC' : 'BAN'}</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
