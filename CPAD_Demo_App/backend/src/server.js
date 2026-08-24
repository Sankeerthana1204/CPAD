const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const { run, get, all } = require("./db");

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 4000);
const jwtSecret = process.env.JWT_SECRET || "cpad_demo_secret_change_me";

app.use(cors());
app.use(express.json());

function nowIso() {
  return new Date().toISOString();
}

async function initDb() {
  await run(`
    CREATE TABLE IF NOT EXISTS customers (
      customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'ACTIVE',
      created_at TEXT NOT NULL,
      last_login_at TEXT
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS products (
      product_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL CHECK(price >= 0),
      image_url TEXT,
      stock_qty INTEGER NOT NULL DEFAULT 0 CHECK(stock_qty >= 0),
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS login_sessions (
      session_id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL,
      issued_at TEXT NOT NULL,
      expires_at TEXT NOT NULL,
      is_revoked INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
    )
  `);

  const customerCount = await get("SELECT COUNT(*) AS count FROM customers");
  if (!customerCount || customerCount.count === 0) {
    const hash = await bcrypt.hash("demo123", 10);
    const createdAt = nowIso();
    await run(
      `
      INSERT INTO customers (full_name, email, password_hash, status, created_at)
      VALUES (?, ?, ?, 'ACTIVE', ?)
      `,
      ["Demo Customer", "customer@demo.com", hash, createdAt]
    );
  }

  const productCount = await get("SELECT COUNT(*) AS count FROM products");
  if (!productCount || productCount.count === 0) {
    const createdAt = nowIso();
    const sampleProducts = [
      ["Cotton T-Shirt", "Comfort-fit round neck cotton t-shirt.", 499.0, "https://picsum.photos/seed/p1/600/400", 52],
      ["Denim Jeans", "Mid-rise slim fit blue denim jeans.", 1499.0, "https://picsum.photos/seed/p2/600/400", 34],
      ["Sports Shoes", "Breathable running shoes for daily use.", 2299.0, "https://picsum.photos/seed/p3/600/400", 21],
      ["Leather Wallet", "Compact leather wallet with card slots.", 899.0, "https://picsum.photos/seed/p4/600/400", 44],
      ["Analog Watch", "Minimal design wrist watch with steel strap.", 3199.0, "https://picsum.photos/seed/p5/600/400", 17],
      ["Backpack", "22L daily carry backpack with laptop sleeve.", 1299.0, "https://picsum.photos/seed/p6/600/400", 29],
      ["Sunglasses", "UV-protected casual sunglasses.", 799.0, "https://picsum.photos/seed/p7/600/400", 63],
      ["Wireless Earbuds", "Bluetooth earbuds with charging case.", 1999.0, "https://picsum.photos/seed/p8/600/400", 26],
      ["Ceramic Mug", "350ml ceramic coffee mug.", 299.0, "https://picsum.photos/seed/p9/600/400", 70],
      ["Notebook", "Hardbound ruled notebook for daily notes.", 199.0, "https://picsum.photos/seed/p10/600/400", 85]
    ];

    for (const p of sampleProducts) {
      await run(
        `
        INSERT INTO products (name, description, price, image_url, stock_qty, is_active, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, 1, ?, ?)
        `,
        [p[0], p[1], p[2], p[3], p[4], createdAt, createdAt]
      );
    }
  }
}

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization || "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;

  if (!token) {
    return res.status(401).json({ message: "Missing bearer token" });
  }

  try {
    const payload = jwt.verify(token, jwtSecret);
    req.user = payload;
    return next();
  } catch (_err) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", service: "cpad-ecommerce-backend" });
});

app.post("/api/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    const customer = await get(
      `SELECT customer_id, full_name, email, password_hash, status FROM customers WHERE email = ?`,
      [email.trim().toLowerCase()]
    );

    if (!customer) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const validPassword = await bcrypt.compare(password, customer.password_hash);
    if (!validPassword) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    if (customer.status !== "ACTIVE") {
      return res.status(403).json({ message: "Customer account is inactive" });
    }

    const tokenPayload = {
      customerId: customer.customer_id,
      email: customer.email,
      fullName: customer.full_name,
    };

    const token = jwt.sign(tokenPayload, jwtSecret, { expiresIn: "2h" });

    const issuedAt = nowIso();
    const expiresAt = new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString();

    await run(
      `INSERT INTO login_sessions (customer_id, issued_at, expires_at, is_revoked) VALUES (?, ?, ?, 0)`,
      [customer.customer_id, issuedAt, expiresAt]
    );

    await run(`UPDATE customers SET last_login_at = ? WHERE customer_id = ?`, [issuedAt, customer.customer_id]);

    return res.json({
      token,
      customer: {
        customerId: customer.customer_id,
        fullName: customer.full_name,
        email: customer.email,
      },
    });
  } catch (err) {
    return res.status(500).json({ message: "Unexpected error", detail: err.message });
  }
});

app.get("/api/products", authMiddleware, async (req, res) => {
  try {
    const rawSearch = (req.query.search || "").toString().trim();
    const wildcard = `%${rawSearch.toLowerCase()}%`;

    const rows = await all(
      `
      SELECT product_id, name, description, price, image_url, stock_qty, is_active
      FROM products
      WHERE is_active = 1
        AND (
          ? = ''
          OR LOWER(name) LIKE ?
          OR LOWER(COALESCE(description, '')) LIKE ?
        )
      ORDER BY name ASC
      `,
      [rawSearch.toLowerCase(), wildcard, wildcard]
    );

    return res.json({ items: rows });
  } catch (err) {
    return res.status(500).json({ message: "Unexpected error", detail: err.message });
  }
});

app.get("/api/products/:id", authMiddleware, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ message: "Invalid product id" });
    }

    const row = await get(
      `
      SELECT product_id, name, description, price, image_url, stock_qty, is_active
      FROM products
      WHERE product_id = ? AND is_active = 1
      `,
      [id]
    );

    if (!row) {
      return res.status(404).json({ message: "Product not found" });
    }

    return res.json(row);
  } catch (err) {
    return res.status(500).json({ message: "Unexpected error", detail: err.message });
  }
});

async function start() {
  try {
    await initDb();
    app.listen(port, () => {
      console.log(`Backend running at http://localhost:${port}`);
      console.log("Demo credentials: customer@demo.com / demo123");
    });
  } catch (err) {
    console.error("Startup failed", err);
    process.exit(1);
  }
}

start();
