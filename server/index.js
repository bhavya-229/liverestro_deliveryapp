const express = require('express');
const cors = require('cors');
let { restaurants, menuCategories, menuItems, liveOrders, nextOrderId } = require('./data');

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// Helper: Enrich restaurant with mapped menu items and categories
function getEnrichedRestaurant(r) {
  const cats = menuCategories.filter(c => c.RestroID === r.RestroID);
  const items = menuItems.filter(i => i.RestroID === r.RestroID).map(item => {
    const cat = cats.find(c => c.id === item.category_id);
    return {
      ...item,
      category: cat ? cat.category_name : (r.categories ? r.categories[0] : 'General')
    };
  });
  return {
    ...r,
    menuItems: items
  };
}

// 1. Health check
app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'online',
    timestamp: new Date().toISOString(),
    service: 'LiveRestro POS & Delivery API Server'
  });
});

// 2. GET /api/v1/restaurants (Nearby Outlets Discovery)
app.get('/api/v1/restaurants', (req, res) => {
  try {
    const { search, is_veg, cuisine } = req.query;
    let results = restaurants.map(getEnrichedRestaurant);

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

// 3. GET /api/v1/restaurants/:id (Restaurant details)
app.get('/api/v1/restaurants/:id', (req, res) => {
  const restroId = req.params.id;
  const restro = restaurants.find(r => 
    r.RestroID.toString() === restroId.toString() ||
    `rest_${r.RestroName.toLowerCase()}`.includes(restroId.toLowerCase()) ||
    (restroId === 'rest_chatkara' && r.RestroID === 55) ||
    (restroId === 'rest_prajapati' && r.RestroID === 28) ||
    (restroId === 'rest_maruti' && r.RestroID === 24)
  );

  if (!restro) {
    return res.status(404).json({ success: false, message: 'Restaurant not found' });
  }

  res.json({ success: true, data: getEnrichedRestaurant(restro) });
});

// 4. GET /api/v1/restaurants/:id/menu (Categorized Menu & Modifiers)
app.get('/api/v1/restaurants/:id/menu', (req, res) => {
  const restroId = req.params.id;
  const restro = restaurants.find(r => 
    r.RestroID.toString() === restroId.toString() ||
    (restroId === 'rest_chatkara' && r.RestroID === 55) ||
    (restroId === 'rest_prajapati' && r.RestroID === 28) ||
    (restroId === 'rest_maruti' && r.RestroID === 24)
  );

  if (!restro) {
    return res.status(404).json({ success: false, message: 'Restaurant not found' });
  }

  const targetId = restro.RestroID;
  const cats = menuCategories.filter(c => c.RestroID === targetId);
  const items = menuItems.filter(i => i.RestroID === targetId);

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

// 5. POST /api/v1/orders/create (Order submission into LiveRestro POS)
app.post('/api/v1/orders/create', (req, res) => {
  try {
    const {
      restro_id,
      customer_name,
      customer_phone,
      delivery_address,
      payment_method,
      items,
      total_amount,
      special_notes,
      delivery_tip
    } = req.body;

    const id = nextOrderId++;
    const orderNumber = `LR-POS-${Date.now().toString().slice(-6)}`;

    const newOrder = {
      order_id: id,
      order_number: orderNumber,
      outlet_id: restro_id || 55,
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

    // Start auto lifecycle progression simulation
    startAutoStatusProgression(newOrder.order_number);

    console.log(`[POS Event] New Order Received: ${orderNumber} for Outlet ${newOrder.outlet_id}`);

    res.status(201).json({
      success: true,
      message: 'Order successfully sent to restaurant POS terminal',
      data: newOrder
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// 6. GET /api/v1/orders/:order_number/status (Real-time tracking)
app.get('/api/v1/orders/:order_number/status', (req, res) => {
  const orderNum = req.params.order_number;
  const order = liveOrders.find(o => o.order_number === orderNum || o.order_id.toString() === orderNum);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found' });
  }

  res.json({
    success: true,
    data: order
  });
});

// 7. POST /api/v1/pos/orders/:order_number/action (POS Web Action Simulation)
app.post('/api/v1/pos/orders/:order_number/action', (req, res) => {
  const orderNum = req.params.order_number;
  const { action, rejection_reason } = req.body;
  const order = liveOrders.find(o => o.order_number === orderNum || o.order_id.toString() === orderNum);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Order not found' });
  }

  switch (action) {
    case 'accept':
    case 'preparing':
      order.status = 'preparing';
      order.stage_index = 1;
      order.eta_minutes = 20;
      break;
    case 'ready':
      order.status = 'ready';
      order.stage_index = 2;
      order.eta_minutes = 14;
      break;
    case 'out_for_delivery':
      order.status = 'out_for_delivery';
      order.stage_index = 3;
      order.eta_minutes = 8;
      break;
    case 'delivered':
      order.status = 'delivered';
      order.stage_index = 4;
      order.eta_minutes = 0;
      break;
    case 'reject':
      order.status = 'rejected';
      order.rejection_reason = rejection_reason || 'Restaurant is currently at peak capacity';
      break;
    default:
      return res.status(400).json({ success: false, message: 'Invalid action' });
  }

  order.updated_at = new Date().toISOString();
  console.log(`[POS Update] Order ${order.order_number} status updated to: ${order.status}`);

  res.json({
    success: true,
    message: `Order status updated to ${order.status}`,
    data: order
  });
});

function startAutoStatusProgression(orderNumber) {
  let step = 0;
  const interval = setInterval(() => {
    const order = liveOrders.find(o => o.order_number === orderNumber);
    if (!order || order.status === 'delivered' || order.status === 'rejected') {
      clearInterval(interval);
      return;
    }

    step++;
    if (step === 1) {
      order.status = 'preparing';
      order.stage_index = 1;
      order.eta_minutes = 20;
    } else if (step === 2) {
      order.status = 'ready';
      order.stage_index = 2;
      order.eta_minutes = 14;
    } else if (step === 3) {
      order.status = 'out_for_delivery';
      order.stage_index = 3;
      order.eta_minutes = 8;
    } else if (step === 4) {
      order.status = 'delivered';
      order.stage_index = 4;
      order.eta_minutes = 0;
      clearInterval(interval);
    }
    order.updated_at = new Date().toISOString();
    console.log(`[Auto POS Progression] ${orderNumber} -> ${order.status}`);
  }, 10000);
}

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 LiveRestro POS & Delivery API Server running on port ${PORT}`);
  console.log(`📡 Base URL: http://localhost:${PORT}/api/v1`);
  console.log(`====================================================`);
});
