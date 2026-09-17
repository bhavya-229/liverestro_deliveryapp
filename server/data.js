// Dummy Seed Database matching liverestro.sql schema
// Tables: restaurants, admin_menu_categories, admin_menu_items, admin_combo_*, orders, online_orders

const restaurants = [
  {
    RestroID: 55,
    RestroName: "Chatkara Express",
    RestroEmail: "chatkara@liverestro.com",
    RestroPhone: "+919876543210",
    RestroAddress: "123 Food Street, University Road",
    City: "Rajkot",
    State: "Gujarat",
    ZipCode: "360005",
    Status: "Active",
    is_pure_veg: 0,
    is_pos_connected: 1,
    rating: 4.6,
    rating_count: 1420,
    delivery_time_minutes: 25,
    distance_km: 1.8,
    price_for_two: 350,
    tagline: "Cheesy Pizzas, Loaded Burgers & Thick Shakes",
    imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80",
    coverUrl: "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80",
    offerTag: "50% OFF up to ₹100",
    cuisines: ["Burgers", "Pizzas", "Fast Food", "Beverages"],
    latitude: 22.3039,
    longitude: 70.8022,
    categories: ["Burgers", "Pizzas", "Sides & Fries", "Beverages"]
  },
  {
    RestroID: 28,
    RestroName: "Prajapati Bhakhri Shak",
    RestroEmail: "mwx.jeet@gmail.com",
    RestroPhone: "9664858334",
    RestroAddress: "Kk Nagar, Sardar Patel Chowk, Ghatlodiya",
    City: "Ahmedabad",
    State: "Gujarat",
    ZipCode: "380061",
    Status: "Active",
    is_pure_veg: 1,
    is_pos_connected: 1,
    rating: 4.8,
    rating_count: 3200,
    delivery_time_minutes: 20,
    distance_km: 2.3,
    price_for_two: 280,
    tagline: "Authentic Kathiyawadi Desi Ghee Bhakhri & Shak",
    imageUrl: "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80",
    coverUrl: "https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=1200&q=80",
    offerTag: "FLAT ₹75 OFF on ₹299",
    cuisines: ["Gujarati", "Kathiyawadi", "Thali", "Pure Veg"],
    latitude: 23.0225,
    longitude: 72.5714,
    categories: ["Breads & Bhakhri", "Kathiyawadi Shak", "Khichdi & Kadhi", "Chaas & Sweets"]
  },
  {
    RestroID: 24,
    RestroName: "Radhe & Maruti Nandan",
    RestroEmail: "radhe@gmail.com",
    RestroPhone: "+919825000000",
    RestroAddress: "Near Kotecha Chowk, Kalawad Road",
    City: "Rajkot",
    State: "Gujarat",
    ZipCode: "360001",
    Status: "Active",
    is_pure_veg: 1,
    is_pos_connected: 1,
    rating: 4.7,
    rating_count: 5400,
    delivery_time_minutes: 30,
    distance_km: 3.1,
    price_for_two: 450,
    tagline: "Grand Multi-Cuisine Dining: Gujarati, Punjabi & South Indian",
    imageUrl: "https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=600&q=80",
    coverUrl: "https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=1200&q=80",
    offerTag: "20% OFF on all combos",
    cuisines: ["Punjabi", "Gujarati Thali", "South Indian", "Biryani"],
    latitude: 22.2900,
    longitude: 70.7900,
    categories: ["Special Thalis", "Punjabi Gravies & Naan", "South Indian Crispies", "Rice & Biryani"]
  }
];

const menuCategories = [
  // Chatkara (55)
  { id: 25, RestroID: 55, category_name: "Burgers", display_order: 1 },
  { id: 26, RestroID: 55, category_name: "Pizzas", display_order: 2 },
  { id: 21, RestroID: 55, category_name: "Sides & Fries", display_order: 3 },
  { id: 13, RestroID: 55, category_name: "Beverages", display_order: 4 },

  // Prajapati (28)
  { id: 101, RestroID: 28, category_name: "Breads & Bhakhri", display_order: 1 },
  { id: 102, RestroID: 28, category_name: "Kathiyawadi Shak", display_order: 2 },
  { id: 103, RestroID: 28, category_name: "Khichdi & Kadhi", display_order: 3 },
  { id: 104, RestroID: 28, category_name: "Chaas & Sweets", display_order: 4 },

  // Radhe & Maruti (24)
  { id: 201, RestroID: 24, category_name: "Special Thalis", display_order: 1 },
  { id: 202, RestroID: 24, category_name: "Punjabi Gravies & Naan", display_order: 2 },
  { id: 203, RestroID: 24, category_name: "South Indian Crispies", display_order: 3 },
  { id: 204, RestroID: 24, category_name: "Rice & Biryani", display_order: 4 }
];

const menuItems = [
  // Chatkara items
  {
    id: 101,
    RestroID: 55,
    category_id: 25,
    item_name: "Cheesy Double Smash Burger",
    item_description: "Double grilled patty loaded with cheddar cheese, caramelized onions, and secret Chatkara sauce.",
    item_price: 189.00,
    item_image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80",
    is_veg: 0,
    is_bestseller: 1,
    rating: 4.8,
    preparation_time: 15,
    is_available: 1,
    customizations: [
      {
        title: "Choose Patty Size",
        options: [
          { name: "Regular Patty", extra_price: 0 },
          { name: "Double Patty", extra_price: 49 }
        ]
      },
      {
        title: "Add-ons",
        options: [
          { name: "Extra Cheddar Cheese Slice", extra_price: 25 },
          { name: "Crispy Bacon Strips", extra_price: 40 }
        ]
      }
    ]
  },
  {
    id: 102,
    RestroID: 55,
    category_id: 25,
    item_name: "Crispy Veggie Deluxe Burger",
    item_description: "Crunchy potato & peas patty topped with fresh lettuce, tomatoes, and creamy herb mayo.",
    item_price: 139.00,
    item_image: "https://images.unsplash.com/photo-1585238342024-78d387f4a707?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.5,
    preparation_time: 12,
    is_available: 1
  },
  {
    id: 103,
    RestroID: 55,
    category_id: 26,
    item_name: "Farmhouse Overloaded Pizza (10\")",
    item_description: "Hand-stretched crust loaded with mozzarella, sweet corn, bell peppers, olives & paneer cubes.",
    item_price: 299.00,
    item_image: "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.7,
    preparation_time: 18,
    is_available: 1
  },
  {
    id: 104,
    RestroID: 55,
    category_id: 21,
    item_name: "Peri-Peri Crinkle Fries",
    item_description: "Golden crinkle-cut potato fries dusted with zesty African peri-peri seasoning mix.",
    item_price: 119.00,
    item_image: "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 0,
    rating: 4.4,
    preparation_time: 10,
    is_available: 1
  },
  {
    id: 105,
    RestroID: 55,
    category_id: 13,
    item_name: "Belgian Dark Chocolate Thickshake",
    item_description: "Rich Belgian chocolate blend with ice cream, choco fudge, and chocolate chips on top.",
    item_price: 169.00,
    item_image: "https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 0,
    rating: 4.9,
    preparation_time: 8,
    is_available: 1
  },

  // Prajapati items
  {
    id: 201,
    RestroID: 28,
    category_id: 101,
    item_name: "Garam Ghee Bhakhri (2 Pcs)",
    item_description: "Crispy, thick whole wheat Kathiyawadi bhakhri roasted with pure desi cow ghee.",
    item_price: 60.00,
    item_image: "https://images.unsplash.com/photo-1505253758473-96b3015f21c9?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.9,
    preparation_time: 10,
    is_available: 1
  },
  {
    id: 202,
    RestroID: 28,
    category_id: 102,
    item_name: "Sev Tameta Nu Shak",
    item_description: "Tangy and slightly sweet Kathiyawadi tomato gravy topped with crunchy Ratlami sev.",
    item_price: 130.00,
    item_image: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.8,
    preparation_time: 12,
    is_available: 1
  },
  {
    id: 203,
    RestroID: 28,
    category_id: 102,
    item_name: "Ringna No Olo (Baingan Bharta)",
    item_description: "Smoky roasted eggplant mashed and cooked with green garlic, ginger, and desi spices.",
    item_price: 150.00,
    item_image: "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.9,
    preparation_time: 15,
    is_available: 1
  },
  {
    id: 204,
    RestroID: 28,
    category_id: 103,
    item_name: "Vaghareli Khichdi & Gujarati Kadhi Combo",
    item_description: "Comforting spicy masala khichdi served with sweet & tangy authentic Gujarati yogurt kadhi.",
    item_price: 170.00,
    item_image: "https://images.unsplash.com/photo-1633945274405-b6c8069047b0?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.8,
    preparation_time: 15,
    is_available: 1
  },
  {
    id: 205,
    RestroID: 28,
    category_id: 104,
    item_name: "Kathiyawadi Masala Chaas (500ml)",
    item_description: "Refreshing spiced buttermilk with cumin, mint, ginger, and black salt.",
    item_price: 35.00,
    item_image: "https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 0,
    rating: 4.9,
    preparation_time: 5,
    is_available: 1
  },

  // Radhe & Maruti items
  {
    id: 301,
    RestroID: 24,
    category_id: 201,
    item_name: "Special Gujarati Deluxe Thali",
    item_description: "2 Shaks, 4 Phulka Rotis, Dal/Kadhi, Rice, Farsan (Dhokla), Sweet (Gulab Jamun), Papad & Chaas.",
    item_price: 240.00,
    item_image: "https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.9,
    preparation_time: 20,
    is_available: 1
  },
  {
    id: 302,
    RestroID: 24,
    category_id: 202,
    item_name: "Paneer Butter Masala & 2 Butter Naan",
    item_description: "Cottage cheese cubes in rich cashew-tomato gravy served with 2 freshly baked tandoori butter naans.",
    item_price: 280.00,
    item_image: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.8,
    preparation_time: 20,
    is_available: 1
  },
  {
    id: 303,
    RestroID: 24,
    category_id: 203,
    item_name: "Mysore Masala Dosa",
    item_description: "Crispy golden crepe smeared with spicy red chutney, filled with potato masala, served with sambar & 3 chutneys.",
    item_price: 150.00,
    item_image: "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=400&q=80",
    is_veg: 1,
    is_bestseller: 1,
    rating: 4.7,
    preparation_time: 15,
    is_available: 1
  }
];

// In-Memory Live Orders Database
let liveOrders = [];
let nextOrderId = 1001;

module.exports = {
  restaurants,
  menuCategories,
  menuItems,
  liveOrders,
  nextOrderId
};
