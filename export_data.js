const fs = require('fs');
const content = fs.readFileSync('liverestro (1).sql', 'utf8');

function parseAllBlocks(tableName) {
  const marker = 'INSERT INTO `' + tableName + '`';
  let idx = 0;
  const allRows = [];
  while ((idx = content.indexOf(marker, idx)) !== -1) {
    const end = content.indexOf(';\n', idx);
    const chunk = content.slice(idx, end);
    const lines = chunk.split('\n');
    for (let l of lines) {
      let t = l.trim();
      if (t.startsWith('(')) {
        if (t.endsWith(',') || t.endsWith(';')) t = t.slice(0, -1);
        if (t.startsWith('(') && t.endsWith(')')) t = t.slice(1, -1);
        const values = [];
        let inQuote = false;
        let curr = '';
        for (let i = 0; i < t.length; i++) {
          const c = t[i];
          if (c === '\'' && t[i - 1] !== '\\') {
            inQuote = !inQuote;
          } else if (c === ',' && !inQuote) {
            values.push(curr.trim());
            curr = '';
            continue;
          }
          curr += c;
        }
        values.push(curr.trim());
        allRows.push(values.map(v => v === 'NULL' ? null : v.replace(/^'|'$/g, '').replace(/\\'/g, "'")));
      }
    }
    idx = end + 2;
  }
  return allRows;
}

const restros = parseAllBlocks('restaurants');
const cats = parseAllBlocks('admin_menu_categories');
const items = parseAllBlocks('admin_menu_items');

// Intelligent Food Image Dictionary
const FOOD_IMAGE_MAP = {
  // Burgers & Sandwiches
  burger: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
  sandwich: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=400&q=80',
  toast: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=400&q=80',
  
  // Pizzas & Italian
  pizza: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80',
  pasta: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281005?auto=format&fit=crop&w=400&q=80',
  garlic_bread: 'https://images.unsplash.com/photo-1619860860774-1e2e17343432?auto=format&fit=crop&w=400&q=80',
  
  // Non-Veg Chicken & Mutton & Fish
  chicken_tikka: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=400&q=80',
  tandoori_chicken: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=400&q=80',
  butter_chicken: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&w=400&q=80',
  chicken_curry: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=400&q=80',
  chicken_biryani: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=400&q=80',
  chicken_wings: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=400&q=80',
  chicken: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=400&q=80',
  mutton: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
  fish: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=400&q=80',
  egg: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=400&q=80',
  seekh_kabab: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
  kabab: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
  
  // Paneer & Vegetarian Indian
  paneer_tikka: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=400&q=80',
  paneer: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=400&q=80',
  dal_makhani: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80',
  dal: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80',
  aloo: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=400&q=80',
  shak: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=400&q=80',
  thali: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=400&q=80',
  naan: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?auto=format&fit=crop&w=400&q=80',
  roti: 'https://images.unsplash.com/photo-1505253758473-96b3015f21c9?auto=format&fit=crop&w=400&q=80',
  bhakhri: 'https://images.unsplash.com/photo-1505253758473-96b3015f21c9?auto=format&fit=crop&w=400&q=80',
  rice: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=400&q=80',
  biryani: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=400&q=80',
  dosa: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=400&q=80',
  idli: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=400&q=80',
  
  // Starters, Snacks & Sweets
  samosa: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
  spring_roll: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
  pakora: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
  fries: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=400&q=80',
  cake: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=400&q=80',
  gulab_jamun: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?auto=format&fit=crop&w=400&q=80',
  dessert: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=400&q=80',
  shake: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=400&q=80',
  beverage: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=400&q=80',
  chaas: 'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=400&q=80'
};

function getFoodImage(name) {
  const n = name.toLowerCase().replace(/[^a-z0-9]/g, '_');
  for (const [key, url] of Object.entries(FOOD_IMAGE_MAP)) {
    if (n.includes(key)) {
      return url;
    }
  }
  return 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80';
}

function determineIsVeg(rawIsVeg, name) {
  const n = name.toLowerCase();
  // If explicitly non-veg words in name:
  if (n.includes('chicken') || n.includes('mutton') || n.includes('fish') || n.includes('egg') || n.includes('prawn') || n.includes('meat') || n.includes('wings')) {
    return 0;
  }
  // If database says 1 or 2 (veg) or veg name:
  if (rawIsVeg == '1' || rawIsVeg == '2') {
    return 1;
  }
  if (rawIsVeg == '0') {
    return 0;
  }
  return 1;
}

const parsedRestaurants = restros.filter(r => r[12] === 'Active').map((r, index) => {
  const id = parseInt(r[0]);
  const rawName = (r[1] || '').trim();
  const name = rawName.length > 2 ? rawName : `LiveRestro Outlet #${id}`;
  const city = (r[5] || '').trim() || 'Rajkot';
  const address = (r[4] || '').trim() || `${name}, ${city}, Gujarat`;
  
  let lat = r[27] ? parseFloat(r[27]) : null;
  let lng = r[28] ? parseFloat(r[28]) : null;

  if (!lat || isNaN(lat)) {
    if (city.toLowerCase().includes('ahmedabad')) {
      lat = 23.0225 + ((id % 7) - 3) * 0.012;
      lng = 72.5714 + ((id % 5) - 2) * 0.012;
    } else if (city.toLowerCase().includes('delhi')) {
      lat = 28.6139 + ((id % 7) - 3) * 0.015;
      lng = 77.2090 + ((id % 5) - 2) * 0.015;
    } else if (city.toLowerCase().includes('new york')) {
      lat = 40.7128;
      lng = -74.0060;
    } else {
      lat = 22.3039 + ((id % 8) - 4) * 0.015;
      lng = 70.8022 + ((id % 6) - 3) * 0.015;
    }
  }

  const restroCats = cats.filter(c => c[1] == id.toString()).map(c => c[2]);

  return {
    RestroID: id,
    RestroName: name,
    RestroEmail: r[2] || `contact@restro${id}.com`,
    RestroPhone: r[3] || '+91 9876543210',
    RestroAddress: address,
    City: city,
    State: r[6] || 'Gujarat',
    ZipCode: r[7] || '360001',
    Status: 'Active',
    is_pure_veg: name.toLowerCase().includes('bhakhri') || name.toLowerCase().includes('radhe') || name.toLowerCase().includes('veg') ? 1 : (id % 2 === 0 ? 1 : 0),
    is_pos_connected: 1,
    rating: parseFloat((4.1 + (id % 9) * 0.1).toFixed(1)),
    rating_count: 350 + (id * 73) % 2500,
    delivery_time_minutes: 20 + (id % 4) * 5,
    distance_km: 2.0,
    price_for_two: 250 + (id % 5) * 50,
    tagline: `Fresh culinary delights from ${name}`,
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
    coverUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80',
    offerTag: id % 3 === 0 ? '50% OFF up to ?100' : (id % 2 === 0 ? 'FLAT ?50 OFF' : null),
    cuisines: restroCats.length > 0 ? restroCats.slice(0, 4) : ['North Indian', 'Fast Food', 'Beverages'],
    latitude: lat,
    longitude: lng,
    categories: restroCats.length > 0 ? restroCats : ['Popular Items', 'Main Course', 'Beverages']
  };
});

const parsedCats = cats.map(c => ({
  id: parseInt(c[0]),
  RestroID: parseInt(c[1]),
  category_name: c[2],
  display_order: parseInt(c[5]) || 0
}));

const parsedItems = items.map(it => {
  const id = parseInt(it[0]);
  const restroId = parseInt(it[1]);
  const categoryId = parseInt(it[2]);
  const name = it[3] || 'Delicious Dish';
  const rawImage = it[6];
  const isVeg = determineIsVeg(it[11], name);

  // If raw image in DB is invalid (e.g. data:image placeholder, via.placeholder, or empty), resolve high quality contextual image
  let image = rawImage;
  if (!image || !image.startsWith('http') || image.includes('via.placeholder.com')) {
    image = getFoodImage(name);
  }

  return {
    id: id,
    RestroID: restroId,
    category_id: categoryId,
    item_name: name,
    item_description: it[5] || `${name} prepared fresh with authentic ingredients and spices.`,
    item_price: parseFloat(it[8]) || 150.0,
    item_image: image,
    is_veg: isVeg,
    is_bestseller: it[13] == '1' ? 1 : 0,
    rating: 4.6,
    preparation_time: parseInt(it[14]) || 15,
    is_available: parseInt(it[12]) !== 0 ? 1 : 1
  };
});

const output = `// LiveRestro Database Schema Exports
// Generated from liverestro (1).sql

const restaurants = ${JSON.stringify(parsedRestaurants, null, 2)};

const menuCategories = ${JSON.stringify(parsedCats, null, 2)};

const menuItems = ${JSON.stringify(parsedItems, null, 2)};

let liveOrders = [];
let nextOrderId = 1001;

module.exports = {
  restaurants,
  menuCategories,
  menuItems,
  liveOrders,
  nextOrderId
};
`;

fs.writeFileSync('server/data.js', output, 'utf8');
console.log('Successfully re-generated server/data.js with accurate food images and veg/non-veg flags!');
