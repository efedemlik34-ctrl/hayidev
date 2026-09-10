const Database = require('better-sqlite3');
const path = require('path');
const bcrypt = require('bcryptjs');

const db = new Database(path.join(__dirname, 'data.db'));
db.pragma('journal_mode = WAL');

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  balance INTEGER DEFAULT 10000,
  diamonds INTEGER DEFAULT 100,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  vip INTEGER DEFAULT 0,
  bio TEXT DEFAULT '',
  gender TEXT DEFAULT 'male',
  age INTEGER DEFAULT 20,
  country TEXT DEFAULT 'TR',
  avatar_frame TEXT DEFAULT 'gold',
  last_seen INTEGER DEFAULT 0,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
CREATE TABLE IF NOT EXISTS rooms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  owner TEXT,
  background TEXT DEFAULT 'dark_purple',
  locked INTEGER DEFAULT 0,
  max_users INTEGER DEFAULT 10,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
CREATE TABLE IF NOT EXISTS room_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  room_id INTEGER,
  username TEXT,
  text TEXT,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
CREATE TABLE IF NOT EXISTS direct_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sender_id INTEGER,
  receiver_id INTEGER,
  text TEXT,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
CREATE TABLE IF NOT EXISTS friends (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  friend_id INTEGER,
  status TEXT DEFAULT 'pending'
);
CREATE TABLE IF NOT EXISTS game_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  game TEXT,
  bet INTEGER,
  win INTEGER,
  created_at INTEGER DEFAULT (strftime('%s','now'))
);
CREATE TABLE IF NOT EXISTS tournaments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  prize INTEGER,
  players INTEGER DEFAULT 0,
  ends_at INTEGER
);
`);

// Default kullanicilar
if (db.prepare('SELECT COUNT(*) as c FROM users').get().c === 0) {
  const h = bcrypt.hashSync('123456', 10);
  const ins = db.prepare(`INSERT INTO users (username, password, balance, diamonds, level, vip) VALUES (?,?,?,?,?,?)`);
  ins.run('admin', h, 1000000, 10000, 100, 1);
  ins.run('test', h, 50000, 500, 5, 0);
  ins.run('player1', h, 25000, 250, 3, 0);
  console.log('Default users: admin, test, player1 (sifre 123456)');
}

// Default odalar
if (db.prepare('SELECT COUNT(*) as c FROM rooms').get().c === 0) {
  const ins = db.prepare(`INSERT INTO rooms (name, owner, background, max_users) VALUES (?,?,?,?)`);
  ins.run('Genel Sohbet', 'admin', 'dark_purple', 50);
  ins.run('Turkce Odasi', 'test', 'fire_red', 30);
  ins.run('Muzik Odasi', 'player1', 'ocean_blue', 20);
}

// Default turnuva
if (db.prepare('SELECT COUNT(*) as c FROM tournaments').get().c === 0) {
  db.prepare(`INSERT INTO tournaments (name, prize, ends_at) VALUES (?,?,?)`)
    .run('Haftalik Turnuva', 5000000,
      Math.floor(Date.now()/1000) + 7*24*60*60);
}

module.exports = db;
