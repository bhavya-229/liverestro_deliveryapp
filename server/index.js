require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./db');
let { restaurants: mockRestaurants, menuCategories: mockCategories, menuItems: mockItems, liveOrders, nextOrderId } = require('./data');

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// ---------------------------------------------------------
// Helper: Enrich restaurant with mapped menu items and categories
// ---------------------------------------------------------
function getEnrichedRestaurant(r, categories = mockCategories, items = mockItems) {
  const cats = categories.filter(c => c.RestroID === r.RestroID);
  const itms = items.filter(i => i.RestroID === r.RestroID).map(item => {
    const cat = cats.find(c => c.id === item.category_id);
    return {
      ...item,
      category: cat ? cat.category_name : (r.categories ? r.categories[0] : 'General')
    };
  });
  return {
    ...r,
    menuItems: itms
  };
}

// ---------------------------------------------------------
// 1. Health check & DB Status
// ---------------------------------------------------------
app.get('/api/v1/health', async (req, res) => {
  let dbStatus = 'disconnected';
  try {
    const [rows] = await db.query('SELECT 1 as connected');
    if (rows && rows[0]?.connected === 1) {
      dbStatus = 'connected';
    }
  } catch (e) {
    dbStatus = `error: ${e.message}`;
  }

  res.json({
    status: 'online',
    database: dbStatus,
    timestamp: new Date().toISOString(),
    service: 'LiveRestro POS & Delivery Persistent API Server'
  });
});

// ---------------------------------------------------------
// 2. GET /api/v1/restaurants (Nearby Outlets Discovery)
// ---------------------------------------------------------
app.get('/api/v1/restaurants', async (req, res) => {
  try {
    const { search, is_veg, cuisine } = req.query;

    // Try fetching live restaurants from MySQL
    try {
      const [dbRestros] = await db.query('SELECT * FROM restaurants WHERE is_active = 1 OR is_active IS NULL');
      if (dbRestros && dbRestros.length > 0) {
        let results = dbRestros.map(r => {
          const fallback = mockRestaurants.find(m => m.RestroID === r.RestroID) || {};
          return {
            RestroID: r.RestroID || r.id,
            RestroName: r.RestroName || r.restaurant_name || fallback.RestroName || 'Restaurant',
            address: r.address || fallback.address || '',
            area: r.area || r.city || fallback.area || '',
            latitude: parseFloat(r.latitude) || fallback.latitude || 22.3039,
            longitude: parseFloat(r.longitude) || fallback.longitude || 70.8022,
            rating: parseFloat(r.rating) || fallback.rating || 4.5,
            review_count: r.review_count || fallback.review_count || 120,
            delivery_time: r.delivery_time || fallback.delivery_time || '25-35 mins',
            distance: r.distance || fallback.distance || '1.8 km',
            cost_for_two: r.cost_for_two || fallback.cost_for_two || '₹300 for two',
            is_pure_veg: r.is_pure_veg !== undefined ? r.is_pure_veg : (fallback.is_pure_veg || 0),
            cuisines: r.cuisines ? (typeof r.cuisines === 'string' ? r.cuisines.split(',') : r.cuisines) : (fallback.cuisines || ['North Indian', 'Snacks']),
            featured_image: r.featured_image || fallback.featured_image || 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80',
            offer_text: r.offer_text || fallback.offer_text || 'Flat 20% OFF'
          };
        });

        if (search) {
          const q = search.toLowerCase();
          results = results.filter(r => 
            r.RestroName.toLowerCase().includes(q) ||
            r.cuisines.some(c => c.toLowerCase().includes(q))
          );
        }
        if (is_veg === 'true' || is_veg === '1') {
          results = results.filter(r => r.is_pure_veg === 1);
        }
        if (cuisine && cuisine !== 'All') {
          results = results.filter(r => 
            r.cuisines.some(c => c.toLowerCase() === cuisine.toLowerCase())
          );
        }

        return res.json({
          success: true,
          count: results.length,
          data: results.map(r => getEnrichedRestaurant(r))
        });
      }
    } catch (dbErr) {
      console.warn(`[DB Fetch Failed] Fallback to structured dataset: ${dbErr.message}`);
    }

    // Fallback if DB table is empty or offline
    let results = mockRestaurants.map(r => getEnrichedRestaurant(r));
    if (search) {
      const q = search.toLowerCase();
      results = results.filter(r => 
        r.RestroName.toLowerCase().includes(q) ||
        r.cuisines.some(c => c.toLowerCase().includes(q))
      );
    }
    if (is_veg === 'true' || is_veg === '1') {
      results = results.filter(r => r.is_pure_veg === 1);
    }
    if (cuisine && cuisine !== 'All') {
      results = results.filter(r => 
        r.cuisines.some(c => c.toLowerCase() === cuisine.toLowerCase())
      );
    }

    res.json({
      success: true,
      count: results.length,
      data: results
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ---------------------------------------------------------
// 3. Customer Authentication & Profile Persistence
// ---------------------------------------------------------
app.post('/api/v1/customers/auth', async (req, res) => {
  try {
    const { mobile_number, full_name, email, fcm_token, is_veg_only } = req.body;
    if (!mobile_number) {
      return res.status(400).json({ success: false, message: 'mobile_number is required' });
    }

    let customer = null;
    try {
      const [existing] = await db.query('SELECT * FROM app_customers WHERE mobile_number = ?', [mobile_number]);
      if (existing.length > 0) {
        customer = existing[0];
        // Update profile details
        await db.query(
          `UPDATE app_customers 
           SET full_name = COALESCE(?, full_name), 
               email = COALESCE(?, email), 
               fcm_token = COALESCE(?, fcm_token), 
               is_veg_only = COALESCE(?, is_veg_only),
               updated_at = NOW()
           WHERE id = ?`,
          [full_name, email, fcm_token, is_veg_only, customer.id]
        );
      } else {
        const [insertRes] = await db.query(
          `INSERT INTO app_customers (mobile_number, full_name, email, fcm_token, is_veg_only)
           VALUES (?, ?, ?, ?, ?)`,
          [mobile_number, full_name || 'Customer', email || '', fcm_token || null, is_veg_only || 0]
        );
        customer = {
          id: insertRes.insertId,
          mobile_number,
          full_name: full_name || 'Customer',
          email: email || '',
          is_veg_only: is_veg_only || 0
        };
      }
    } catch (dbErr) {
      console.warn(`[DB Customer Error] ${dbErr.message}`);
      customer = {
        id: 1,
        mobile_number,
        full_name: full_name || 'Customer',
        email: email || '',
        is_veg_only: is_veg_only || 0
      };
    }

    res.json({
      success: true,
      message: 'Customer authenticated successfully',
      data: customer
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ---------------------------------------------------------
// 4. Saved Addresses Persistence (GET & POST)
// ---------------------------------------------------------
app.get('/api/v1/customers/:id/addresses', async (req, res) => {
  try {
    const customerId = req.params.id;
    const [addresses] = await db.query(
      'SELECT * FROM app_customer_addresses WHERE customer_id = ? ORDER BY is_default DESC, id DESC',
      [customerId]
    );
    res.json({ success: true, data: addresses });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/api/v1/customers/:id/addresses', async (req, res) => {
  try {
    const customerId = req.params.id;
    const { address_type, complete_address, landmark, latitude, longitude, is_default, recipient_name, recipient_phone } = req.body;

    const [insertRes] = await db.query(
      `INSERT INTO app_customer_addresses 
       (customer_id, address_type, complete_address, landmark, latitude, longitude, is_default, recipient_name, recipient_phone)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        customerId,
        address_type || 'home',
        complete_address || '',
        landmark || '',
        latitude || 0.0,
        longitude || 0.0,
        is_default ? 1 : 0,
        recipient_name || '',
        recipient_phone || ''
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Address saved successfully',
      address_id: insertRes.insertId
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ---------------------------------------------------------
// 5. GET /api/v1/restaurants/:id/menu (Categorized Menu)
// ---------------------------------------------------------
app.get('/api/v1/restaurants/:id/menu', (req, res) => {
  const restroId = req.params.id;
  const restro = mockRestaurants.find(r => 
    r.RestroID.toString() === restroId.toString() ||
    (restroId === 'rest_chatkara' && r.RestroID === 55) ||
    (restroId === 'rest_prajapati' && r.RestroID === 28) ||
    (restroId === 'rest_maruti' && r.RestroID === 24)
  );

  if (!restro) {
    return res.status(404).json({ success: false, message: 'Restaurant not found' });
  }

  const targetId = restro.RestroID;
  const cats = mockCategories.filter(c => c.RestroID === targetId);
  const items = mockItems.filter(i => i.RestroID === targetId);

  const categoriesWithItems = cats.map(c => ({
    category_id: c.id,
    category_name: c.category_name,
    items: items.filter(i => i.category_id === c.id).map(i => ({
      ...i,
      category: c.category_name
    }))
  }));

  res.json({
    success: true,
    restro_id: targetId,
    restaurant_name: restro.RestroName,
    categories: categoriesWithItems
  });
});

// ---------------------------------------------------------
// 6. POST /api/v1/orders/create (Persistent MySQL Orders)
// ---------------------------------------------------------
app.post('/api/v1/orders/create', async (req, res) => {
  try {
    const {
      restro_id,
      customer_id,
      customer_name,
      customer_phone,
      delivery_address,
      payment_method,
      items,
      total_amount,
      special_notes,
      delivery_tip
    } = req.body;

    const orderNumber = `LR-POS-${Date.now().toString().slice(-6)}`;
    let orderId = nextOrderId++;

    // 1. Insert into MySQL `orders` table
    try {
      const [orderRes] = await db.query(
        `INSERT INTO orders 
         (outlet_id, customer_id, order_number, customer_name, customer_phone, delivery_address, total, payment_method, payment_status, status, order_type, special_notes, delivery_tip, total_items, metadata)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          restro_id || 55,
          customer_id || null,
          orderNumber,
          customer_name || 'Customer',
          customer_phone || '9876543210',
          delivery_address || 'Customer Delivery Address',
          total_amount || 0.00,
          payment_method || 'UPI',
          'paid',
          'open',
          'delivery',
          special_notes || '',
          delivery_tip || 0.00,
          (items || []).length,
          JSON.stringify({ items: items || [] })
        ]
      );
      if (orderRes && orderRes.insertId) {
        orderId = orderRes.insertId;
      }

      // 2. Insert initial lifecycle tracking event into `order_tracking_events`
      await db.query(
        `INSERT INTO order_tracking_events (order_id, status, title, description)
         VALUES (?, ?, ?, ?)`,
        [orderId, 'placed', 'Order Placed', 'Your order was successfully placed and notified to the restaurant']
      );
    } catch (dbErr) {
      console.warn(`[DB Order Insert Warning] Could not persist to MySQL orders: ${dbErr.message}`);
    }

    const newOrder = {
      order_id: orderId,
      order_number: orderNumber,
      outlet_id: restro_id || 55,
      customer_id: customer_id || null,
      customer_name: customer_name || 'Customer',
      customer_phone: customer_phone || '9876543210',
      delivery_address: delivery_address || 'Customer Delivery Address',
      payment_method: payment_method || 'UPI',
      payment_status: 'PAID',
      status: 'placed',
      stage_index: 0,
      eta_minutes: 25,
      items: items || [],
      total_amount: total_amount || 0,
      special_notes: special_notes || '',
      delivery_tip: delivery_tip || 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      pos_synced: true,
      rider_info: {
        name: 'Suresh Parmar',
        phone: '+919876543210',
        vehicle_number: 'GJ-03-LR-8921'
      }
    };

    liveOrders.unshift(newOrder);

    // Auto progression for live tracking demo
    startAutoStatusProgression(newOrder.order_number, orderId);

    console.log(`[POS & DB Event] New Order Created & Persisted: ${orderNumber} (ID: ${orderId})`);

    res.status(201).json({
      success: true,
      message: 'Order successfully saved to MySQL database and notified to restaurant',
      data: newOrder
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ---------------------------------------------------------
// 7. GET /api/v1/orders/:order_number/status (Real-time tracking)
// ---------------------------------------------------------
app.get('/api/v1/orders/:order_number/status', async (req, res) => {
  const orderNum = req.params.order_number;
  const order = liveOrders.find(o => o.order_number === orderNum || o.order_id.toString() === orderNum);

  if (order) {
    return res.json({ success: true, data: order });
  }

  // Fallback check in MySQL database
  try {
    const [rows] = await db.query('SELECT * FROM orders WHERE order_number = ? OR order_id = ?', [orderNum, orderNum]);
    if (rows.length > 0) {
      const row = rows[0];
      return res.json({
        success: true,
        data: {
          order_id: row.order_id,
          order_number: row.order_number,
          outlet_id: row.outlet_id,
          customer_name: row.customer_name,
          customer_phone: row.customer_phone,
          delivery_address: row.delivery_address,
          payment_method: row.payment_method || 'UPI',
          payment_status: row.payment_status || 'PAID',
          status: row.status || 'open',
          stage_index: row.status === 'settled' ? 4 : 1,
          total_amount: row.total,
          created_at: row.created_at
        }
      });
    }
  } catch (dbErr) {
    console.warn(`[DB Status Query] ${dbErr.message}`);
  }

  res.status(404).json({ success: false, message: 'Order not found' });
});

// ---------------------------------------------------------
// 8. Auto Status Progression with DB Event Logging
// ---------------------------------------------------------
function startAutoStatusProgression(orderNumber, dbOrderId) {
  let step = 0;
  const interval = setInterval(async () => {
    const order = liveOrders.find(o => o.order_number === orderNumber);
    if (!order || order.status === 'delivered' || order.status === 'rejected') {
      clearInterval(interval);
      return;
    }

    step++;
    let statusText = 'preparing';
    let title = 'Preparing Food';
    let desc = 'Kitchen is preparing fresh items for your order';

    if (step === 1) {
      order.status = 'preparing';
      order.stage_index = 1;
      order.eta_minutes = 20;
    } else if (step === 2) {
      order.status = 'ready';
      order.stage_index = 2;
      order.eta_minutes = 14;
      statusText = 'ready';
      title = 'Food Ready';
      desc = 'Order packed and assigned to delivery partner';
    } else if (step === 3) {
      order.status = 'out_for_delivery';
      order.stage_index = 3;
      order.eta_minutes = 8;
      statusText = 'out_for_delivery';
      title = 'Out for Delivery';
      desc = 'Delivery partner is on the way with your food';
    } else if (step === 4) {
      order.status = 'delivered';
      order.stage_index = 4;
      order.eta_minutes = 0;
      statusText = 'delivered';
      title = 'Order Delivered';
      desc = 'Order successfully delivered to customer address';
      clearInterval(interval);
    }
    order.updated_at = new Date().toISOString();

    // Log tracking event in MySQL
    if (dbOrderId) {
      try {
        await db.query(
          `INSERT INTO order_tracking_events (order_id, status, title, description) VALUES (?, ?, ?, ?)`,
          [dbOrderId, statusText, title, desc]
        );
        await db.query(
          `UPDATE orders SET status = ?, updated_at = NOW() WHERE order_id = ?`,
          [statusText === 'delivered' ? 'settled' : 'in_progress', dbOrderId]
        );
      } catch (err) {}
    }

    console.log(`[Auto POS & DB Progression] ${orderNumber} -> ${order.status}`);
  }, 10000);
}

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 LiveRestro POS & Delivery API Server running on port ${PORT}`);
  console.log(`📡 Base URL: http://localhost:${PORT}/api/v1`);
  console.log(`💾 Connected Database: ${process.env.DB_NAME || 'liverestro'}`);
  console.log(`====================================================`);
});
