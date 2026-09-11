// Ek tablolar
const Database = require('better-sqlite3');
const path = require('path');

module.exports = function(dbPath) {
  const db = new Database(dbPath || path.join(__dirname, 'data.db'));

  db.exec(`
    CREATE TABLE IF NOT EXISTS follows (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      follower_id INTEGER,
      following_id INTEGER,
      created_at INTEGER DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      username TEXT,
      text TEXT,
      likes INTEGER DEFAULT 0,
      created_at INTEGER DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS stories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      username TEXT,
      image TEXT,
      created_at INTEGER DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS profile_visitors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      visited_id INTEGER,
      visitor_id INTEGER,
      created_at INTEGER DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS groups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      owner_id INTEGER,
      created_at INTEGER DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS themes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      preview TEXT,
      price INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS clans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      owner_id INTEGER,
      points INTEGER DEFAULT 0,
      created_at INTEGER DEFAULT (strftime('%s','now'))
    );
  `);

  return db;
};
