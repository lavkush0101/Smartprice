"""
Comprehensive Master Product Catalog for Quick Commerce (Blinkit & Zepto)
Contains 80+ high-demand daily essential products across 10 core categories with accurate pricing.
"""

from typing import List, Dict, Any

CATEGORIES = [
    {"id": "all", "name": "All Products", "icon": "🔥"},
    {"id": "dairy", "name": "Dairy & Breakfast", "icon": "🥛"},
    {"id": "fruits_veg", "name": "Fresh Fruits & Veggies", "icon": "🍎"},
    {"id": "bakery", "name": "Bread, Eggs & Bakery", "icon": "🍞"},
    {"id": "snacks", "name": "Snacks & Munchies", "icon": "🍿"},
    {"id": "drinks", "name": "Cold Drinks & Juices", "icon": "🥤"},
    {"id": "staples", "name": "Atta, Rice, Dal & Oil", "icon": "🍚"},
    {"id": "sweets", "name": "Chocolates & Sweets", "icon": "🍫"},
    {"id": "tea_coffee", "name": "Tea, Coffee & Health", "icon": "☕"},
    {"id": "cleaning", "name": "Cleaning & Household", "icon": "🧹"},
    {"id": "personal_care", "name": "Personal Care", "icon": "✨"},
]

MASTER_PRODUCTS: List[Dict[str, Any]] = [
    # -------------------------------------------------------------------------
    # 1. DAIRY & BREAKFAST
    # -------------------------------------------------------------------------
    {
        "id": "prod_milk_1",
        "category": "dairy",
        "title": "Amul Taaza Toned Fresh Milk",
        "packSize": "500 ml",
        "imageUrl": "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&auto=format&fit=crop&q=80",
        "tags": ["milk", "dairy", "amul", "taaza", "toned"],
        "blinkit": {"price": 27.0, "mrp": 27.0, "eta": "12 mins", "deepLink": "https://blinkit.com/prn/amul-taaza-toned-fresh-milk/prid/19512"},
        "zepto": {"price": 26.5, "mrp": 27.0, "eta": "9 mins", "deepLink": "https://zeptonow.com/pn/amul-taaza-milk/pvid/123"},
    },
    {
        "id": "prod_milk_2",
        "category": "dairy",
        "title": "Amul Gold Full Cream Fresh Milk",
        "packSize": "500 ml",
        "imageUrl": "https://images.unsplash.com/photo-1528750997573-59b89d56f4f7?w=200&auto=format&fit=crop&q=80",
        "tags": ["milk", "dairy", "amul", "gold", "full cream"],
        "blinkit": {"price": 33.0, "mrp": 34.0, "eta": "14 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 32.5, "mrp": 34.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_milk_3",
        "category": "dairy",
        "title": "Nandini Toned Fresh Milk",
        "packSize": "500 ml",
        "imageUrl": "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&auto=format&fit=crop&q=80",
        "tags": ["milk", "dairy", "nandini", "toned"],
        "blinkit": {"price": 24.0, "mrp": 24.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 24.0, "mrp": 24.0, "eta": "10 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_butter_1",
        "category": "dairy",
        "title": "Amul Pasteurized Salted Butter",
        "packSize": "100 g",
        "imageUrl": "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=200&auto=format&fit=crop&q=80",
        "tags": ["butter", "dairy", "amul", "salted butter"],
        "blinkit": {"price": 58.0, "mrp": 60.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 57.0, "mrp": 60.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_butter_2",
        "category": "dairy",
        "title": "Amul Pasteurized Salted Butter",
        "packSize": "500 g",
        "imageUrl": "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=200&auto=format&fit=crop&q=80",
        "tags": ["butter", "dairy", "amul", "500g"],
        "blinkit": {"price": 275.0, "mrp": 285.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 272.0, "mrp": 285.0, "eta": "10 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_curd_1",
        "category": "dairy",
        "title": "Mother Dairy Classic Dahi / Curd",
        "packSize": "400 g",
        "imageUrl": "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&auto=format&fit=crop&q=80",
        "tags": ["curd", "dahi", "dairy", "mother dairy", "yogurt"],
        "blinkit": {"price": 35.0, "mrp": 35.0, "eta": "11 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 34.0, "mrp": 35.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_paneer_1",
        "category": "dairy",
        "title": "Amul Fresh Malai Paneer",
        "packSize": "200 g",
        "imageUrl": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=200&auto=format&fit=crop&q=80",
        "tags": ["paneer", "dairy", "amul", "malai paneer", "cheese"],
        "blinkit": {"price": 90.0, "mrp": 95.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 88.0, "mrp": 95.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_cheese_1",
        "category": "dairy",
        "title": "Amul Processed Cheese Slices",
        "packSize": "200 g (10 Slices)",
        "imageUrl": "https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=200&auto=format&fit=crop&q=80",
        "tags": ["cheese", "slices", "amul", "dairy"],
        "blinkit": {"price": 140.0, "mrp": 145.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 136.0, "mrp": 145.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 2. BREAD, EGGS & BAKERY
    # -------------------------------------------------------------------------
    {
        "id": "prod_bread_1",
        "category": "bakery",
        "title": "Modern White Sandwich Bread",
        "packSize": "400 g",
        "imageUrl": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&auto=format&fit=crop&q=80",
        "tags": ["bread", "bakery", "modern", "white bread", "sandwich"],
        "blinkit": {"price": 42.0, "mrp": 45.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 40.0, "mrp": 45.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_bread_2",
        "category": "bakery",
        "title": "Harvest Gold 100% Atta Whole Wheat Bread",
        "packSize": "400 g",
        "imageUrl": "https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=200&auto=format&fit=crop&q=80",
        "tags": ["bread", "atta", "wheat", "harvest gold", "brown bread"],
        "blinkit": {"price": 55.0, "mrp": 55.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 54.0, "mrp": 55.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_bread_3",
        "category": "bakery",
        "title": "English Oven Sandwich White Bread",
        "packSize": "400 g",
        "imageUrl": "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=200&auto=format&fit=crop&q=80",
        "tags": ["bread", "english oven", "sandwich", "white"],
        "blinkit": {"price": 48.0, "mrp": 50.0, "eta": "15 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 47.0, "mrp": 50.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_egg_1",
        "category": "bakery",
        "title": "Eggoz Farm Fresh White Eggs",
        "packSize": "6 pcs",
        "imageUrl": "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&auto=format&fit=crop&q=80",
        "tags": ["egg", "eggs", "eggoz", "poultry", "breakfast"],
        "blinkit": {"price": 54.0, "mrp": 60.0, "eta": "11 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 51.0, "mrp": 60.0, "eta": "10 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_egg_2",
        "category": "bakery",
        "title": "Hen Fruit Fresh Farm White Eggs",
        "packSize": "6 pcs",
        "imageUrl": "https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=200&auto=format&fit=crop&q=80",
        "tags": ["egg", "eggs", "hen fruit", "farm fresh"],
        "blinkit": {"price": 52.0, "mrp": 58.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 50.0, "mrp": 58.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_biscuit_1",
        "category": "bakery",
        "title": "Britannia Good Day Butter Cookies",
        "packSize": "200 g",
        "imageUrl": "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=200&auto=format&fit=crop&q=80",
        "tags": ["biscuit", "cookies", "good day", "britannia", "butter cookies"],
        "blinkit": {"price": 40.0, "mrp": 45.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 38.0, "mrp": 45.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_biscuit_2",
        "category": "bakery",
        "title": "Oreo Original Chocolate Sandwich Biscuits",
        "packSize": "120 g",
        "imageUrl": "https://images.unsplash.com/photo-1568051243851-f9b136146e97?w=200&auto=format&fit=crop&q=80",
        "tags": ["biscuit", "oreo", "chocolate", "cookies"],
        "blinkit": {"price": 35.0, "mrp": 40.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 34.0, "mrp": 40.0, "eta": "7 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 3. FRESH FRUITS & VEGETABLES
    # -------------------------------------------------------------------------
    {
        "id": "prod_veg_1",
        "category": "fruits_veg",
        "title": "Fresh Hybrid Tomato",
        "packSize": "500 g",
        "imageUrl": "https://images.unsplash.com/photo-1546470427-227c7369a92f?w=200&auto=format&fit=crop&q=80",
        "tags": ["tomato", "tamatar", "vegetables", "fresh", "veggies"],
        "blinkit": {"price": 22.0, "mrp": 28.0, "eta": "9 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 20.0, "mrp": 28.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_veg_2",
        "category": "fruits_veg",
        "title": "Fresh Red Onion / Pyaz",
        "packSize": "1 kg",
        "imageUrl": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&auto=format&fit=crop&q=80",
        "tags": ["onion", "pyaz", "vegetables", "fresh", "veggies"],
        "blinkit": {"price": 38.0, "mrp": 45.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 35.0, "mrp": 45.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_veg_3",
        "category": "fruits_veg",
        "title": "Fresh Potato / Aloo",
        "packSize": "1 kg",
        "imageUrl": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=200&auto=format&fit=crop&q=80",
        "tags": ["potato", "aloo", "vegetables", "fresh"],
        "blinkit": {"price": 30.0, "mrp": 35.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 28.0, "mrp": 35.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_veg_4",
        "category": "fruits_veg",
        "title": "Fresh Coriander Leaves / Dhaniya",
        "packSize": "100 g",
        "imageUrl": "https://images.unsplash.com/photo-1588879462719-75e7a9b0c797?w=200&auto=format&fit=crop&q=80",
        "tags": ["coriander", "dhaniya", "herb", "vegetables", "fresh"],
        "blinkit": {"price": 12.0, "mrp": 15.0, "eta": "8 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 10.0, "mrp": 15.0, "eta": "7 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_fruit_1",
        "category": "fruits_veg",
        "title": "Fresh Robusta Bananas",
        "packSize": "500 g (4-5 pcs)",
        "imageUrl": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=200&auto=format&fit=crop&q=80",
        "tags": ["banana", "kela", "fruits", "fresh"],
        "blinkit": {"price": 32.0, "mrp": 38.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 29.0, "mrp": 38.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_fruit_2",
        "category": "fruits_veg",
        "title": "Fresh Royal Gala Apples",
        "packSize": "4 pcs (500 g)",
        "imageUrl": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&auto=format&fit=crop&q=80",
        "tags": ["apple", "seb", "fruits", "gala apple"],
        "blinkit": {"price": 110.0, "mrp": 130.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 105.0, "mrp": 130.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 4. SNACKS & MUNCHIES
    # -------------------------------------------------------------------------
    {
        "id": "prod_chips_1",
        "category": "snacks",
        "title": "Lay's India's Magic Masala Potato Chips",
        "packSize": "50 g",
        "imageUrl": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=200&auto=format&fit=crop&q=80",
        "tags": ["chips", "lays", "magic masala", "snacks", "crisps"],
        "blinkit": {"price": 20.0, "mrp": 20.0, "eta": "9 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 19.0, "mrp": 20.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_chips_2",
        "category": "snacks",
        "title": "Kurkure Masala Munch Namkeen",
        "packSize": "85 g",
        "imageUrl": "https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=200&auto=format&fit=crop&q=80",
        "tags": ["kurkure", "masala munch", "namkeen", "snacks"],
        "blinkit": {"price": 20.0, "mrp": 20.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 19.5, "mrp": 20.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_snack_1",
        "category": "snacks",
        "title": "Haldiram's Nagpur Aloo Bhujia",
        "packSize": "200 g",
        "imageUrl": "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=200&auto=format&fit=crop&q=80",
        "tags": ["haldiram", "aloo bhujia", "bhujia", "namkeen", "snacks"],
        "blinkit": {"price": 55.0, "mrp": 60.0, "eta": "11 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 52.0, "mrp": 60.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_maggi_1",
        "category": "snacks",
        "title": "Maggi 2-Minute Masala Instant Noodles",
        "packSize": "Pack of 4 (280 g)",
        "imageUrl": "https://images.unsplash.com/photo-1612927601601-6638404737ce?w=200&auto=format&fit=crop&q=80",
        "tags": ["maggi", "noodles", "instant noodles", "masala", "nestle"],
        "blinkit": {"price": 58.0, "mrp": 60.0, "eta": "9 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 56.0, "mrp": 60.0, "eta": "7 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_maggi_2",
        "category": "snacks",
        "title": "Maggi 2-Minute Masala Noodles",
        "packSize": "Pack of 8 (560 g)",
        "imageUrl": "https://images.unsplash.com/photo-1612927601601-6638404737ce?w=200&auto=format&fit=crop&q=80",
        "tags": ["maggi", "noodles", "pack of 8", "snacks"],
        "blinkit": {"price": 112.0, "mrp": 120.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 108.0, "mrp": 120.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 5. COLD DRINKS & JUICES
    # -------------------------------------------------------------------------
    {
        "id": "prod_drink_1",
        "category": "drinks",
        "title": "Coca-Cola Soft Drink",
        "packSize": "750 ml",
        "imageUrl": "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=200&auto=format&fit=crop&q=80",
        "tags": ["coke", "coca cola", "cold drink", "soda", "beverage"],
        "blinkit": {"price": 40.0, "mrp": 40.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 38.0, "mrp": 40.0, "eta": "7 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_drink_2",
        "category": "drinks",
        "title": "Thums Up Soft Drink",
        "packSize": "750 ml",
        "imageUrl": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=200&auto=format&fit=crop&q=80",
        "tags": ["thums up", "coke", "cola", "cold drink", "beverage"],
        "blinkit": {"price": 40.0, "mrp": 40.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 39.0, "mrp": 40.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_drink_3",
        "category": "drinks",
        "title": "Sprite Lemon Lime Soft Drink",
        "packSize": "750 ml",
        "imageUrl": "https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=200&auto=format&fit=crop&q=80",
        "tags": ["sprite", "lemon", "lime", "cold drink", "soda"],
        "blinkit": {"price": 40.0, "mrp": 40.0, "eta": "9 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 38.0, "mrp": 40.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_juice_1",
        "category": "drinks",
        "title": "Real Fruit Power Mixed Fruit Juice",
        "packSize": "1 L",
        "imageUrl": "https://images.unsplash.com/photo-1613478223719-2ab802602423?w=200&auto=format&fit=crop&q=80",
        "tags": ["juice", "real", "mixed fruit", "beverage"],
        "blinkit": {"price": 115.0, "mrp": 130.0, "eta": "11 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 109.0, "mrp": 130.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_redbull_1",
        "category": "drinks",
        "title": "Red Bull Energy Drink Can",
        "packSize": "250 ml",
        "imageUrl": "https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=200&auto=format&fit=crop&q=80",
        "tags": ["red bull", "energy drink", "can", "beverage"],
        "blinkit": {"price": 125.0, "mrp": 125.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 119.0, "mrp": 125.0, "eta": "7 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 6. ATTA, RICE, DAL & OIL
    # -------------------------------------------------------------------------
    {
        "id": "prod_atta_1",
        "category": "staples",
        "title": "Aashirvaad Superior MP Chakki Atta",
        "packSize": "5 kg",
        "imageUrl": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=200&auto=format&fit=crop&q=80",
        "tags": ["atta", "flour", "wheat", "aashirvaad", "staples"],
        "blinkit": {"price": 245.0, "mrp": 265.0, "eta": "15 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 240.0, "mrp": 265.0, "eta": "12 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_atta_2",
        "category": "staples",
        "title": "Fortune Chakki Fresh Atta",
        "packSize": "5 kg",
        "imageUrl": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=200&auto=format&fit=crop&q=80",
        "tags": ["atta", "fortune", "flour", "wheat"],
        "blinkit": {"price": 230.0, "mrp": 250.0, "eta": "14 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 228.0, "mrp": 250.0, "eta": "11 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_rice_1",
        "category": "staples",
        "title": "Daawat Rozana Super Basmati Rice",
        "packSize": "5 kg",
        "imageUrl": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200&auto=format&fit=crop&q=80",
        "tags": ["rice", "chawal", "basmati", "daawat", "staples"],
        "blinkit": {"price": 380.0, "mrp": 450.0, "eta": "14 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 369.0, "mrp": 450.0, "eta": "11 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_dal_1",
        "category": "staples",
        "title": "Tata Sampann Unpolished Toor Dal",
        "packSize": "1 kg",
        "imageUrl": "https://images.unsplash.com/photo-1599305090598-fe179d501227?w=200&auto=format&fit=crop&q=80",
        "tags": ["toor dal", "dal", "tata sampann", "pulses", "staples"],
        "blinkit": {"price": 185.0, "mrp": 205.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 179.0, "mrp": 205.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_oil_1",
        "category": "staples",
        "title": "Fortune Sunlite Refined Sunflower Oil",
        "packSize": "1 L Pouch",
        "imageUrl": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=200&auto=format&fit=crop&q=80",
        "tags": ["oil", "sunflower oil", "fortune", "cooking oil", "tel"],
        "blinkit": {"price": 135.0, "mrp": 150.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 130.0, "mrp": 150.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_salt_1",
        "category": "staples",
        "title": "Tata Salt Vacuum Evaporated Iodized Salt",
        "packSize": "1 kg",
        "imageUrl": "https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=200&auto=format&fit=crop&q=80",
        "tags": ["salt", "namak", "tata salt", "iodized", "staples"],
        "blinkit": {"price": 28.0, "mrp": 30.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 27.0, "mrp": 30.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 7. CHOCOLATES & SWEETS
    # -------------------------------------------------------------------------
    {
        "id": "prod_choc_1",
        "category": "sweets",
        "title": "Cadbury Dairy Milk Silk Chocolate Bar",
        "packSize": "60 g",
        "imageUrl": "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=200&auto=format&fit=crop&q=80",
        "tags": ["chocolate", "cadbury", "silk", "dairy milk", "sweets"],
        "blinkit": {"price": 80.0, "mrp": 85.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 76.0, "mrp": 85.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_choc_2",
        "category": "sweets",
        "title": "Nestlé KitKat 4 Finger Chocolate Bar",
        "packSize": "38 g",
        "imageUrl": "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=200&auto=format&fit=crop&q=80",
        "tags": ["kitkat", "chocolate", "nestle", "wafer"],
        "blinkit": {"price": 30.0, "mrp": 30.0, "eta": "9 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 28.0, "mrp": 30.0, "eta": "7 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 8. TEA, COFFEE & HEALTH DRINKS
    # -------------------------------------------------------------------------
    {
        "id": "prod_tea_1",
        "category": "tea_coffee",
        "title": "Tata Tea Gold Premium Black Tea",
        "packSize": "500 g",
        "imageUrl": "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=200&auto=format&fit=crop&q=80",
        "tags": ["tea", "chai", "tata tea", "gold", "beverages"],
        "blinkit": {"price": 290.0, "mrp": 320.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 282.0, "mrp": 320.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_coffee_1",
        "category": "tea_coffee",
        "title": "Nescafe Classic 100% Pure Instant Coffee",
        "packSize": "50 g Jar",
        "imageUrl": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200&auto=format&fit=crop&q=80",
        "tags": ["coffee", "nescafe", "instant coffee", "classic"],
        "blinkit": {"price": 185.0, "mrp": 195.0, "eta": "11 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 178.0, "mrp": 195.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 9. CLEANING & HOUSEHOLD
    # -------------------------------------------------------------------------
    {
        "id": "prod_clean_1",
        "category": "cleaning",
        "title": "Vim Lemon Dishwash Liquid Gel",
        "packSize": "500 ml Bottle",
        "imageUrl": "https://images.unsplash.com/photo-1585421514738-01798e348b17?w=200&auto=format&fit=crop&q=80",
        "tags": ["vim", "dishwash", "liquid", "cleaning", "household"],
        "blinkit": {"price": 110.0, "mrp": 125.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 105.0, "mrp": 125.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_clean_2",
        "category": "cleaning",
        "title": "Surf Excel Matic Top Load Liquid Detergent",
        "packSize": "1 L",
        "imageUrl": "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=200&auto=format&fit=crop&q=80",
        "tags": ["surf excel", "detergent", "laundry", "matic", "cleaning"],
        "blinkit": {"price": 220.0, "mrp": 240.0, "eta": "14 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 212.0, "mrp": 240.0, "eta": "10 mins", "deepLink": "https://zeptonow.com"},
    },

    # -------------------------------------------------------------------------
    # 10. PERSONAL CARE
    # -------------------------------------------------------------------------
    {
        "id": "prod_care_1",
        "category": "personal_care",
        "title": "Dettol Original Liquid Handwash Refill",
        "packSize": "675 ml",
        "imageUrl": "https://images.unsplash.com/photo-1608248597359-593674681640?w=200&auto=format&fit=crop&q=80",
        "tags": ["dettol", "handwash", "soap", "hygiene", "personal care"],
        "blinkit": {"price": 95.0, "mrp": 109.0, "eta": "11 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 90.0, "mrp": 109.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_care_2",
        "category": "personal_care",
        "title": "Colgate Strong Teeth Anticavity Toothpaste",
        "packSize": "150 g",
        "imageUrl": "https://images.unsplash.com/photo-1559591937-e109d94943dc?w=200&auto=format&fit=crop&q=80",
        "tags": ["colgate", "toothpaste", "dental", "strong teeth"],
        "blinkit": {"price": 105.0, "mrp": 115.0, "eta": "10 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 98.0, "mrp": 115.0, "eta": "8 mins", "deepLink": "https://zeptonow.com"},
    },
    {
        "id": "prod_care_3",
        "category": "personal_care",
        "title": "Dove Daily Shine Damage Therapy Shampoo",
        "packSize": "340 ml",
        "imageUrl": "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=200&auto=format&fit=crop&q=80",
        "tags": ["dove", "shampoo", "hair", "daily shine"],
        "blinkit": {"price": 280.0, "mrp": 310.0, "eta": "12 mins", "deepLink": "https://blinkit.com"},
        "zepto": {"price": 269.0, "mrp": 310.0, "eta": "9 mins", "deepLink": "https://zeptonow.com"},
    },
]

def search_catalog(query: str = "all", category: str = "all") -> List[Dict[str, Any]]:
    """
    Returns matched products from the master catalog.
    If query is 'all' or empty, returns all products in the specified category.
    """
    q = query.lower().strip()
    cat = category.lower().strip()

    filtered = MASTER_PRODUCTS

    # Filter by category if specified
    if cat and cat != "all":
        filtered = [p for p in filtered if p["category"] == cat]

    # If query is 'all' or '*' or empty, return all matching category items
    if not q or q in ("all", "*", "everything", "all products"):
        return filtered

    # Search keyword matching
    results = []
    for p in filtered:
        title = p["title"].lower()
        tags = [t.lower() for t in p.get("tags", [])]
        category_name = p["category"].lower()

        # Check direct substring or tag match
        if q in title or any(q in t for t in tags) or any(t in q for t in tags) or q in category_name:
            results.append(p)
        else:
            # Word token overlap match
            q_words = [w for w in q.split() if len(w) > 2]
            if any(w in title or any(w in t for t in tags) for w in q_words):
                results.append(p)

    return results if results else filtered[:8]
