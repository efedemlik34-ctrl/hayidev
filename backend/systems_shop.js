// ═══ Kapsamli Magaza + IAP Dogrulama ═══
const crypto = require('crypto');

module.exports = function setup(ctx) {
  const { app, db, io, auth, adminOnly, changeBal } = ctx;

  // Tablolar
  db.exec(`
    CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT UNIQUE, name TEXT, description TEXT, price_tl REAL, coins INTEGER DEFAULT 0, diamonds INTEGER DEFAULT 0, vip_days INTEGER DEFAULT 0, frame_key TEXT, category TEXT DEFAULT 'coins', icon TEXT, badge TEXT, sort_order INTEGER DEFAULT 0, active INTEGER DEFAULT 1);
    CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, product_key TEXT, platform TEXT, receipt TEXT, status TEXT DEFAULT 'pending', amount_tl REAL, coins_given INTEGER, diamonds_given INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS subscriptions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, product_key TEXT, expires_at TEXT, auto_renew INTEGER DEFAULT 1, platform TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS coupons (id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT UNIQUE, discount_percent INTEGER DEFAULT 0, discount_amount REAL DEFAULT 0, max_uses INTEGER DEFAULT 0, used INTEGER DEFAULT 0, active INTEGER DEFAULT 1, expires_at TEXT);
    CREATE TABLE IF NOT EXISTS campaigns (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, bonus_percent INTEGER DEFAULT 0, start_at TEXT, end_at TEXT, active INTEGER DEFAULT 1);
  `);

  // Varsayilan urunler
  const defaultProducts = [
    { key: 'coins_100k', name: '100K Coin', desc: 'Kucuk baslangic paketi', tl: 29.99, coins: 100000, cat: 'coins', icon: '🪙', badge: null, sort: 1 },
    { key: 'coins_500k', name: '500K Coin', desc: 'Populer paket', tl: 99.99, coins: 500000, cat: 'coins', icon: '💰', badge: 'POPULER', sort: 2 },
    { key: 'coins_1m', name: '1M Coin', desc: 'Avantajli paket', tl: 149.99, coins: 1000000, cat: 'coins', icon: '💎', badge: 'INDIRIM', sort: 3 },
    { key: 'coins_5m', name: '5M Coin', desc: 'Buyuk paket', tl: 499.99, coins: 5000000, cat: 'coins', icon: '🏆', badge: 'EN IYI', sort: 4 },
    { key: 'coins_10m', name: '10M Coin', desc: 'Premium paket', tl: 799.99, coins: 10000000, cat: 'coins', icon: '👑', badge: null, sort: 5 },
    { key: 'coins_50m', name: '50M Coin', desc: 'VIP paket', tl: 2499.99, coins: 50000000, cat: 'coins', icon: '🚀', badge: 'VIP', sort: 6 },
    { key: 'diamonds_100', name: '100 Elmas', desc: 'Kucuk elmas paketi', tl: 19.99, diamonds: 100, cat: 'diamonds', icon: '💠', badge: null, sort: 1 },
    { key: 'diamonds_500', name: '500 Elmas', desc: 'Elmas paketi', tl: 79.99, diamonds: 500, cat: 'diamonds', icon: '💠', badge: 'POPULER', sort: 2 },
    { key: 'diamonds_2000', name: '2000 Elmas', desc: 'Buyuk elmas paketi', tl: 249.99, diamonds: 2000, cat: 'diamonds', icon: '💠', badge: null, sort: 3 },
    { key: 'vip_1m', name: 'VIP 1 Ay', desc: '1 ay VIP uyelik', tl: 99.99, vip_days: 30, cat: 'vip', icon: '⭐', badge: null, sort: 1 },
    { key: 'vip_3m', name: 'VIP 3 Ay', desc: '3 ay VIP uyelik', tl: 249.99, vip_days: 90, cat: 'vip', icon: '🌟', badge: 'INDIRIM', sort: 2 },
    { key: 'vip_12m', name: 'VIP 1 Yil', desc: 'Yillik VIP uyelik', tl: 799.99, vip_days: 365, cat: 'vip', icon: '👑', badge: 'EN IYI', sort: 3 },
    { key: 'frame_gold', name: 'Altin Cerceve', desc: 'Kalici altin cerceve', tl: 49.99, frame_key: 'gold', cat: 'frames', icon: '🥇', badge: null, sort: 1 },
    { key: 'frame_dragon', name: 'Ejderha Cerceve', desc: 'Efsanevi cerceve', tl: 199.99, frame_key: 'dragon', cat: 'frames', icon: '🐉', badge: 'EFSANE', sort: 2 },
    { key: 'battle_pass', name: 'Sezon Pass', desc: 'Bu sezon tum oduller', tl: 149.99, coins: 500000, cat: 'battle_pass', icon: '🎫', badge: 'YENI', sort: 1 },
    { key: 'starter', name: 'Baslangic Paketi', desc: 'Yeni oyuncular icin', tl: 9.99, coins: 200000, diamonds: 50, cat: 'starter', icon: '🎁', badge: 'YENI', sort: 1 },
  ];

  defaultProducts.forEach(p => {
    try {
      db.prepare('INSERT OR IGNORE INTO products (key,name,description,price_tl,coins,diamonds,vip_days,frame_key,category,icon,badge,sort_order) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)')
        .run(p.key, p.name, p.desc, p.tl, p.coins || 0, p.diamonds || 0, p.vip_days || 0, p.frame_key || null, p.cat, p.icon, p.badge, p.sort);
    } catch (e) {}
  });

  // ═══ GET /api/shop/products ═══
  app.get('/api/shop/products', auth, (req, res) => {
    const products = db.prepare('SELECT * FROM products WHERE active = 1 ORDER BY category, sort_order').all();
    const grouped = {};
    products.forEach(p => {
      if (!grouped[p.category]) grouped[p.category] = [];
      grouped[p.category].push(p);
    });
    const campaigns = db.prepare("SELECT * FROM campaigns WHERE active = 1 AND (end_at IS NULL OR end_at > datetime('now'))").all();
    res.json({ categories: grouped, campaigns });
  });

  // ═══ POST /api/shop/create-order (Google Play oncesi) ═══
  app.post('/api/shop/create-order', auth, (req, res) => {
    const { productKey, platform } = req.body;
    if (!productKey) return res.status(400).json({ error: 'NO_PRODUCT' });
    const p = db.prepare('SELECT * FROM products WHERE key = ? AND active = 1').get(productKey);
    if (!p) return res.status(404).json({ error: 'PRODUCT_NOT_FOUND' });
    const r = db.prepare('INSERT INTO orders (user_id, product_key, platform, status, amount_tl) VALUES (?,?,?,?,?)')
      .run(req.uid, productKey, platform || 'google_play', 'pending', p.price_tl);
    res.json({ orderId: r.lastInsertRowid, product: p });
  });

  // ═══ POST /api/shop/verify/google ═══
  app.post('/api/shop/verify/google', auth, async (req, res) => {
    const { productKey, purchaseToken, orderId } = req.body;
    if (!productKey || !purchaseToken) return res.status(400).json({ error: 'MISSING' });

    const p = db.prepare('SELECT * FROM products WHERE key = ? AND active = 1').get(productKey);
    if (!p) return res.status(404).json({ error: 'PRODUCT_NOT_FOUND' });

    // Ayni token daha once kullanilmis mi?
    const existing = db.prepare('SELECT 1 FROM orders WHERE receipt = ?').get(purchaseToken);
    if (existing) return res.status(409).json({ error: 'ALREADY_USED' });

    // Google Play Developer API dogrulama (production)
    let verified = false;
    if (process.env.GOOGLE_SERVICE_ACCOUNT && process.env.ANDROID_PACKAGE) {
      try {
        const { google } = require('googleapis');
        const auth = new google.auth.GoogleAuth({
          credentials: JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT),
          scopes: ['https://www.googleapis.com/auth/androidpublisher']
        });
        const publisher = google.androidpublisher({ version: 'v3', auth });
        const r = await publisher.purchases.products.get({
          packageName: process.env.ANDROID_PACKAGE,
          productId: productKey,
          token: purchaseToken
        });
        // purchaseState: 0 = purchased
        verified = r.data.purchaseState === 0;
      } catch (e) {
        console.log('[shop] Google verify error:', e.message);
      }
    } else {
      // Dev modu: otomatik onayla
      console.log('[shop] DEV MODE - Google verify skipped');
      verified = true;
    }

    if (!verified) return res.status(400).json({ error: 'VERIFY_FAILED' });

    // Urunu ver
    const txResult = db.transaction(() => {
      db.prepare('UPDATE orders SET status = ?, receipt = ? WHERE id = ?')
        .run('completed', purchaseToken, orderId);

      if (p.coins > 0) changeBal(req.uid, p.coins, 'iap_coin', productKey);
      if (p.diamonds > 0) {
        db.prepare('UPDATE users SET diamonds = diamonds + ? WHERE id = ?').run(p.diamonds, req.uid);
      }
      if (p.vip_days > 0) {
        const now = new Date();
        const current = db.prepare('SELECT vip FROM users WHERE id = ?').get(req.uid);
        db.prepare('UPDATE users SET vip = MAX(vip, 1) WHERE id = ?').run(req.uid);
        db.prepare('INSERT INTO subscriptions (user_id, product_key, expires_at, platform) VALUES (?,?,?,?)')
          .run(req.uid, productKey, new Date(now.getTime() + p.vip_days * 86400000).toISOString(), 'google_play');
      }
      if (p.frame_key) {
        db.prepare('INSERT OR IGNORE INTO frames (user_id, frame_key) VALUES (?, ?)').run(req.uid, p.frame_key);
      }
      return true;
    });

    try {
      txResult();
      io.to('user_' + req.uid).emit('purchase:success', { productKey, coins: p.coins, diamonds: p.diamonds });
      res.json({ ok: true, coins: p.coins, diamonds: p.diamonds });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // ═══ POST /api/shop/verify/apple ═══
  app.post('/api/shop/verify/apple', auth, async (req, res) => {
    const { productKey, receiptData, orderId } = req.body;
    if (!productKey || !receiptData) return res.status(400).json({ error: 'MISSING' });

    const p = db.prepare('SELECT * FROM products WHERE key = ? AND active = 1').get(productKey);
    if (!p) return res.status(404).json({ error: 'PRODUCT_NOT_FOUND' });

    let verified = false;
    if (process.env.APPLE_SHARED_SECRET) {
      try {
        const endpoint = process.env.NODE_ENV === 'production'
          ? 'https://buy.itunes.apple.com/verifyReceipt'
          : 'https://sandbox.itunes.apple.com/verifyReceipt';
        const body = JSON.stringify({ 'receipt-data': receiptData, password: process.env.APPLE_SHARED_SECRET });
        const r = await fetch(endpoint, { method: 'POST', body });
        const data = await r.json();
        verified = data.status === 0;
      } catch (e) {
        console.log('[shop] Apple verify error:', e.message);
      }
    } else {
      verified = true; // dev
    }

    if (!verified) return res.status(400).json({ error: 'VERIFY_FAILED' });

    db.prepare('UPDATE orders SET status = ?, receipt = ? WHERE id = ?').run('completed', receiptData, orderId);
    if (p.coins > 0) changeBal(req.uid, p.coins, 'iap_coin', productKey);
    if (p.diamonds > 0) db.prepare('UPDATE users SET diamonds = diamonds + ? WHERE id = ?').run(p.diamonds, req.uid);
    if (p.vip_days > 0) db.prepare('UPDATE users SET vip = MAX(vip, 1) WHERE id = ?').run(req.uid);
    if (p.frame_key) db.prepare('INSERT OR IGNORE INTO frames (user_id, frame_key) VALUES (?, ?)').run(req.uid, p.frame_key);

    res.json({ ok: true, coins: p.coins, diamonds: p.diamonds });
  });

  // ═══ POST /api/shop/verify/stripe (web icin) ═══
  app.post('/api/shop/verify/stripe', auth, async (req, res) => {
    const { productKey, paymentIntentId, orderId } = req.body;
    if (!productKey || !paymentIntentId) return res.status(400).json({ error: 'MISSING' });

    if (!process.env.STRIPE_SECRET) {
      return res.status(503).json({ error: 'STRIPE_NOT_CONFIGURED' });
    }

    try {
      const Stripe = require('stripe');
      const stripe = new Stripe(process.env.STRIPE_SECRET);
      const intent = await stripe.paymentIntents.retrieve(paymentIntentId);
      if (intent.status !== 'succeeded') return res.status(400).json({ error: 'PAYMENT_NOT_SUCCEEDED' });

      const p = db.prepare('SELECT * FROM products WHERE key = ?').get(productKey);
      db.prepare('UPDATE orders SET status = ?, receipt = ? WHERE id = ?').run('completed', paymentIntentId, orderId);
      if (p.coins > 0) changeBal(req.uid, p.coins, 'stripe_coin', productKey);
      if (p.diamonds > 0) db.prepare('UPDATE users SET diamonds = diamonds + ? WHERE id = ?').run(p.diamonds, req.uid);
      res.json({ ok: true, coins: p.coins, diamonds: p.diamonds });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // ═══ GET /api/shop/orders ═══
  app.get('/api/shop/orders', auth, (req, res) => {
    const orders = db.prepare('SELECT * FROM orders WHERE user_id = ? ORDER BY id DESC LIMIT 50').all(req.uid);
    res.json(orders);
  });

  // ═══ GET /api/shop/subscription ═══
  app.get('/api/shop/subscription', auth, (req, res) => {
    const sub = db.prepare("SELECT * FROM subscriptions WHERE user_id = ? AND expires_at > datetime('now') ORDER BY id DESC LIMIT 1").get(req.uid);
    res.json(sub || null);
  });

  // ═══ POST /api/shop/coupon ═══
  app.post('/api/shop/coupon', auth, (req, res) => {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: 'NO_CODE' });
    const c = db.prepare('SELECT * FROM coupons WHERE code = ? AND active = 1').get(code.toUpperCase());
    if (!c) return res.status(404).json({ error: 'INVALID_CODE' });
    if (c.max_uses > 0 && c.used >= c.max_uses) return res.status(400).json({ error: 'MAX_USES' });
    res.json({ ok: true, discount_percent: c.discount_percent, discount_amount: c.discount_amount });
  });

  console.log('[shop] Kapsamli magaza yuklendi (' + defaultProducts.length + ' urun)');
};
