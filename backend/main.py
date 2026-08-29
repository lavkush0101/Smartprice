import os
import sys
from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
import asyncio
import urllib.request
import json
import math

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adapters.blinkit_adapter import BlinkitAdapter
from adapters.zepto_adapter import ZeptoAdapter
from matching_engine import ProductNormalizer

app = FastAPI(
    title="SmartPrice Aggregator API & Web Preview",
    description="Hyperlocal price comparison microservice for Quick Commerce (Blinkit & Zepto)",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

KNOWN_SOCIETIES_AND_HUBS = [
    {
        "area": "18 1st main road 3rd cross",
        "building": "18 1st main road 3rd cross",
        "address": "18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru, 560067",
        "pincode": "560067",
        "eta": "8-11 MINS",
        "lat": 12.9922,
        "lng": 77.7290
    },
    {
        "area": "Prestige Shantiniketan",
        "building": "Prestige Shantiniketan Residential Complex",
        "address": "Tower 8, Prestige Shantiniketan, ITPL Main Rd, Whitefield, Bengaluru 560066",
        "pincode": "560066",
        "eta": "8-11 MINS",
        "lat": 12.9698,
        "lng": 77.7499
    },
    {
        "area": "Indiranagar 100ft Road",
        "building": "Prestige Meridian, HAL 2nd Stage",
        "address": "Flat 402, Prestige Meridian, 100ft Road, HAL 2nd Stage, Indiranagar, Bengaluru 560038",
        "pincode": "560038",
        "eta": "8-11 MINS",
        "lat": 12.9784,
        "lng": 77.6408
    },
    {
        "area": "Koramangala 4th Block",
        "building": "Raheja Residency, 80 Feet Road",
        "address": "Tower 2, Raheja Residency, 80 Feet Rd, 4th Block, Koramangala, Bengaluru 560034",
        "pincode": "560034",
        "eta": "9-12 MINS",
        "lat": 12.9352,
        "lng": 77.6245
    },
    {
        "area": "HSR Layout Sector 2",
        "building": "Purva Vantage, Sector 2",
        "address": "Flat 301, Purva Vantage, 27th Main Rd, Sector 2, HSR Layout, Bengaluru 560102",
        "pincode": "560102",
        "eta": "9-11 MINS",
        "lat": 12.9121,
        "lng": 77.6446
    },
    {
        "area": "DLF Cyber City",
        "building": "Building 10, DLF Cyber City",
        "address": "Tower B, Building 10, DLF Cyber City, Phase 2, Gurugram, Haryana 122002",
        "pincode": "122002",
        "eta": "10-13 MINS",
        "lat": 28.4595,
        "lng": 77.0266
    },
    {
        "area": "Bandra West",
        "building": "Galaxy Heights, Hill Road",
        "address": "Flat 502, Galaxy Heights, Hill Road, Bandra West, Mumbai 400050",
        "pincode": "400050",
        "eta": "8-11 MINS",
        "lat": 19.0596,
        "lng": 72.8295
    },
    {
        "area": "Powai Hiranandani",
        "building": "Somerset Heritage Tower, Hiranandani",
        "address": "Tower 3, Central Avenue, Hiranandani Gardens, Powai, Mumbai 400076",
        "pincode": "400076",
        "eta": "9-12 MINS",
        "lat": 19.1176,
        "lng": 72.9060
    },
]

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/api/v1/location/detect")
async def detect_live_location():
    try:
        req = urllib.request.Request(
            "http://ip-api.com/json/",
            headers={"User-Agent": "SmartPriceApp/1.0"}
        )
        with urllib.request.urlopen(req, timeout=4) as response:
            data = json.loads(response.read().decode())
            if data.get("status") == "success":
                city = data.get("city", "Bengaluru")
                region = data.get("regionName", "Karnataka")
                lat = float(data.get("lat", 12.9753))
                lng = float(data.get("lon", 77.5910))
                pincode = data.get("zip", "560001")
                
                for hub in KNOWN_SOCIETIES_AND_HUBS:
                    dlat = (lat - hub["lat"]) * 111.0
                    dlng = (lng - hub["lng"]) * 111.0 * math.cos(math.radians(lat))
                    if math.sqrt(dlat * dlat + dlng * dlng) < 25.0:
                        return {
                            "status": "success",
                            "areaName": hub["area"],
                            "buildingName": hub["building"],
                            "city": city,
                            "region": region,
                            "lat": lat,
                            "lng": lng,
                            "pincode": hub["pincode"],
                            "eta": hub["eta"],
                            "displayName": f"{hub['building']}, {hub['area']}",
                            "fullAddress": hub["address"]
                        }

                return {
                    "status": "success",
                    "areaName": f"{city} Central",
                    "buildingName": f"Main Area, {city}",
                    "city": city,
                    "region": region,
                    "country": data.get("country", "India"),
                    "lat": lat,
                    "lng": lng,
                    "pincode": pincode,
                    "eta": "9-12 MINS",
                    "displayName": f"{city} Central (Live Doorstep)",
                    "fullAddress": f"Doorstep Area, MG Road & Central Circle, {city}, {region} - {pincode}"
                }
    except Exception:
        pass
    
    fallback = KNOWN_SOCIETIES_AND_HUBS[0]
    return {
        "status": "success",
        "areaName": fallback["area"],
        "buildingName": fallback["building"],
        "city": "Bengaluru",
        "region": "Karnataka",
        "lat": fallback["lat"],
        "lng": fallback["lng"],
        "pincode": fallback["pincode"],
        "eta": fallback["eta"],
        "displayName": fallback["area"],
        "fullAddress": fallback["address"]
    }

@app.get("/api/v1/location/reverse")
async def reverse_geocode(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude")
):
    try:
        osm_url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lng}&zoom=18&addressdetails=1"
        req = urllib.request.Request(osm_url, headers={"User-Agent": "SmartPriceQuickCommerce/1.0"})
        with urllib.request.urlopen(req, timeout=4) as response:
            data = json.loads(response.read().decode())
            addr = data.get("address", {})
            building = addr.get("building") or addr.get("apartments") or addr.get("residential") or addr.get("commercial") or addr.get("office") or addr.get("amenity") or ""
            house_no = addr.get("house_number", "")
            road = addr.get("road") or addr.get("pedestrian") or addr.get("footway") or ""
            neighbourhood = addr.get("neighbourhood") or addr.get("suburb") or addr.get("residential") or ""
            city = addr.get("city") or addr.get("town") or addr.get("village") or "Bengaluru"
            state = addr.get("state", "Karnataka")
            pincode = addr.get("postcode", "560038")

            title = building if building else (f"{road}, {neighbourhood}" if road and neighbourhood else (neighbourhood or city))
            parts = [
                f"House No. {house_no}" if house_no else "",
                building,
                road,
                neighbourhood if neighbourhood != road else "",
                city,
                state,
                pincode
            ]
            full_addr = ", ".join([p for p in parts if p])

            return {
                "status": "success",
                "areaName": title,
                "buildingName": building,
                "flatNumber": house_no,
                "city": city,
                "fullAddress": full_addr,
                "pincode": pincode,
                "eta": "8-11 MINS",
                "displayName": f"{title} (Live GPS)",
                "lat": lat,
                "lng": lng
            }
    except Exception:
        pass

    fallback = KNOWN_SOCIETIES_AND_HUBS[0]
    return {
        "status": "success",
        "areaName": fallback["area"],
        "buildingName": fallback["building"],
        "city": "Bengaluru",
        "fullAddress": fallback["address"],
        "pincode": fallback["pincode"],
        "eta": fallback["eta"],
        "displayName": fallback["area"],
        "lat": lat,
        "lng": lng
    }

@app.get("/api/v1/compare")
async def compare_products(
    query: str = Query(..., min_length=2, description="Search item name (e.g. 'milk', 'egg', 'coke')"),
    lat: float = Query(12.9716, description="User latitude"),
    lng: float = Query(77.5946, description="User longitude")
):
    try:
        blinkit_task = BlinkitAdapter.search(query, lat, lng)
        zepto_task = ZeptoAdapter.search(query, lat, lng)
        blinkit_items, zepto_items = await asyncio.gather(blinkit_task, zepto_task)
        matched_results = ProductNormalizer.match_and_merge(blinkit_items, zepto_items)
        return {
            "status": "success",
            "query": query,
            "location": {"lat": lat, "lng": lng},
            "totalResults": len(matched_results),
            "products": matched_results
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Aggregation error: {str(e)}")

@app.get("/", response_class=HTMLResponse)
@app.get("/app", response_class=HTMLResponse)
def web_preview():
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartPrice — Quick-Commerce Delivery</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
        }
        body {
            background-color: #0f172a;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px 10px;
        }
        .phone-container {
            width: 100%;
            max-width: 440px;
            height: 92vh;
            max-height: 900px;
            background: #ffffff;
            border-radius: 36px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5), 0 0 0 10px #1e293b;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }
        .app-header {
            padding: 16px 18px 12px;
            background: #ffffff;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #f1f5f9;
        }
        .logo-box {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .logo-icon {
            background: #4f46e5;
            color: white;
            padding: 5px 8px;
            border-radius: 8px;
            font-weight: 800;
            font-size: 15px;
        }
        .logo-text {
            font-size: 18px;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.5px;
        }
        .badge {
            background: #e0e7ff;
            color: #3730a3;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 8px;
            border-radius: 20px;
        }
        .scrollable-body {
            flex: 1;
            overflow-y: auto;
            padding: 14px 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        /* Top Location Card (Matches User Screenshot 2) */
        .location-section {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .location-section-title {
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
            padding-left: 2px;
        }
        .location-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 12px 14px;
            display: flex;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            gap: 12px;
        }
        .loc-icon-circle {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: #eef2ff;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #4f46e5;
            font-size: 18px;
        }
        .loc-info {
            flex: 1;
            min-width: 0;
        }
        .loc-title {
            font-size: 14px;
            font-weight: 800;
            color: #0f172a;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .loc-sub {
            font-size: 11.5px;
            color: #64748b;
            margin-top: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .change-btn {
            color: #4f46e5;
            font-size: 13px;
            font-weight: 800;
            background: none;
            border: none;
            cursor: pointer;
            padding: 4px 6px;
            letter-spacing: 0.5px;
        }

        /* Search Box */
        .search-box {
            display: flex;
            gap: 8px;
            position: relative;
        }
        .search-input {
            flex: 1;
            padding: 11px 16px 11px 40px;
            border-radius: 12px;
            border: 1.5px solid #e2e8f0;
            background: #f8fafc;
            font-size: 13.5px;
            outline: none;
        }
        .search-input:focus {
            border-color: #4f46e5;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1);
        }
        .search-icon {
            position: absolute;
            left: 14px;
            top: 12px;
            font-size: 15px;
            color: #94a3b8;
        }
        .search-btn {
            background: #4f46e5;
            color: white;
            border: none;
            padding: 0 16px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
        }

        /* Chips */
        .chips-row {
            display: flex;
            gap: 8px;
            overflow-x: auto;
            padding-bottom: 2px;
        }
        .chip {
            background: #f1f5f9;
            color: #475569;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
        }
        .chip:hover, .chip.active {
            background: #e0e7ff;
            color: #4f46e5;
        }
        .results-container {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .card {
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 14px;
            background: #ffffff;
            box-shadow: 0 2px 6px rgba(0,0,0,0.03);
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        .item-info {
            display: flex;
            gap: 10px;
        }
        .item-thumb {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }
        .item-title {
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
        }
        .item-unit {
            font-size: 11.5px;
            color: #64748b;
            margin-top: 2px;
        }
        .savings-tag {
            background: #dcfce7;
            color: #166534;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 7px;
            border-radius: 6px;
        }
        .stores-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
        }
        .store-box {
            padding: 10px;
            border-radius: 10px;
            border: 1.5px solid #e2e8f0;
            background: #f8fafc;
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .store-box.cheapest {
            border-color: #86efac;
            background: #f0fdf4;
        }
        .store-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .store-name {
            font-size: 12.5px;
            font-weight: 800;
        }
        .store-name.zepto { color: #7c3aed; }
        .store-name.blinkit { color: #d97706; }
        .cheapest-badge {
            background: #16a34a;
            color: white;
            font-size: 9px;
            font-weight: 800;
            padding: 2px 4px;
            border-radius: 4px;
        }
        .price-row {
            display: flex;
            align-items: baseline;
            gap: 6px;
            margin-top: 2px;
        }
        .price {
            font-size: 16px;
            font-weight: 800;
            color: #0f172a;
        }
        .mrp {
            font-size: 11px;
            color: #94a3b8;
            text-decoration: line-through;
        }
        .eta-row {
            font-size: 10.5px;
            color: #64748b;
            display: flex;
            align-items: center;
            gap: 3px;
        }
        .buy-btn {
            margin-top: 6px;
            padding: 6px 0;
            border-radius: 8px;
            border: none;
            font-size: 11px;
            font-weight: 700;
            color: white;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            display: block;
        }
        .buy-btn.zepto { background: #7c3aed; }
        .buy-btn.blinkit { background: #d97706; }
        .buy-btn.cheapest-btn { background: #16a34a; }

        .loader {
            display: none;
            text-align: center;
            padding: 24px;
            color: #64748b;
            font-size: 13px;
        }
        .spinner {
            border: 3px solid #f1f5f9;
            border-top: 3px solid #4f46e5;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 8px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Modal 1: Change Delivery Location (Matches User Screenshot 1) */
        .modal-overlay {
            display: none;
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(3px);
            z-index: 100;
            justify-content: flex-end;
            flex-direction: column;
        }
        .modal-sheet {
            background: #f8fafc;
            border-radius: 24px 24px 0 0;
            padding: 18px 20px 24px;
            max-height: 90%;
            display: flex;
            flex-direction: column;
            gap: 12px;
            animation: slideUp 0.25s ease-out;
            overflow-y: auto;
        }
        @keyframes slideUp {
            from { transform: translateY(100%); }
            to { transform: translateY(0); }
        }
        .modal-header-row {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .back-circle-btn {
            width: 34px;
            height: 34px;
            background: #ffffff;
            border-radius: 50%;
            border: none;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 14px;
            font-weight: 800;
        }
        .modal-heading {
            font-size: 17px;
            font-weight: 800;
            color: #0f172a;
        }
        .action-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 14px;
            cursor: pointer;
            color: #4f46e5;
            font-weight: 700;
            font-size: 14px;
            transition: 0.15s;
        }
        .action-card:hover {
            background: #eef2ff;
        }

        /* Modal 2: Add New Address (Matches User Screenshot 3) */
        .field-label {
            font-size: 13.5px;
            font-weight: 800;
            color: #0f172a;
            margin-top: 4px;
        }
        .input-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 10px 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .input-card input, .input-card textarea {
            border: none;
            outline: none;
            width: 100%;
            font-size: 13.5px;
            background: transparent;
        }
        .tags-container {
            display: flex;
            gap: 10px;
        }
        .tag-segment {
            flex: 1;
            padding: 12px 0;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 700;
            color: #64748b;
            cursor: pointer;
        }
        .tag-segment.active {
            background: #eef2ff;
            border: 1.5px solid #6366f1;
            color: #4f46e5;
        }
        .save-address-btn {
            width: 100%;
            height: 48px;
            background: #4f46e5;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 14.5px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 10px;
        }
        .hubs-list {
            overflow-y: auto;
            max-height: 240px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .hub-item {
            padding: 10px 12px;
            background: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            cursor: pointer;
            border: 1px solid #f1f5f9;
        }
    </style>
</head>
<body>

<div class="phone-container">
    <!-- App Header -->
    <div class="app-header">
        <div class="logo-box">
            <div class="logo-icon">⇄</div>
            <div class="logo-text">SmartPrice</div>
        </div>
        <div class="badge">POC Beta</div>
    </div>

    <div class="scrollable-body">
        <!-- Top Location Card (Matches User Screenshot 2) -->
        <div class="location-section">
            <div class="location-section-title">Your Location</div>
            <div class="location-card">
                <div class="loc-icon-circle">📍</div>
                <div class="loc-info">
                    <div class="loc-title" id="loc-area">18 1st main road 3rd cross</div>
                    <div class="loc-sub" id="loc-address">18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru 560067</div>
                </div>
                <button class="change-btn" onclick="openChangeLocationModal()">CHANGE</button>
            </div>
        </div>

        <!-- Search Bar -->
        <div class="search-box">
            <span class="search-icon">🔍</span>
            <input type="text" class="search-input" id="search-input" placeholder="Search milk, eggs, coke, butter..." value="milk" onkeypress="handleEnter(event)">
            <button class="search-btn" onclick="executeSearch()">Compare</button>
        </div>

        <!-- Quick Tags -->
        <div class="chips-row">
            <div class="chip active" onclick="quickSearch('milk')">🥛 Milk</div>
            <div class="chip" onclick="quickSearch('egg')">🥚 Eggs</div>
            <div class="chip" onclick="quickSearch('coke')">🥤 Coca-Cola</div>
            <div class="chip" onclick="quickSearch('butter')">🧈 Butter</div>
            <div class="chip" onclick="quickSearch('bread')">🍞 Bread</div>
        </div>

        <!-- Loader -->
        <div class="loader" id="loader">
            <div class="spinner"></div>
            Comparing dark store prices on Blinkit & Zepto...
        </div>

        <!-- Results List -->
        <div class="results-container" id="results-container"></div>
    </div>

    <!-- Modal 1: Change Delivery Location (Matches User Screenshot 1) -->
    <div class="modal-overlay" id="change-loc-modal" onclick="closeChangeLocationModal()">
        <div class="modal-sheet" onclick="event.stopPropagation()">
            <div class="modal-header-row">
                <button class="back-circle-btn" onclick="closeChangeLocationModal()">‹</button>
                <div class="modal-heading">Change Delivery Location</div>
            </div>

            <!-- Search by area, street name, pin code -->
            <div class="input-card" style="margin-top: 4px;">
                <span style="color: #64748b;">🔍</span>
                <input type="text" id="modal-search" placeholder="Search by area, street name, pin code" oninput="filterHubs(this.value)">
            </div>

            <!-- Use Current Location Card -->
            <div class="action-card" onclick="detectLiveLocation(); closeChangeLocationModal();">
                <span style="font-size:18px;">🎯</span>
                <span>Use Current Location</span>
            </div>

            <!-- Add a New Address Card -->
            <div class="action-card" onclick="openAddAddressModal()">
                <span style="font-size:18px;">➕</span>
                <span>Add a New Address</span>
            </div>

            <div id="list-heading" style="font-size: 12.5px; font-weight: 700; color: #64748b; margin-top: 4px;">Saved Addresses (1)</div>
            <div class="hubs-list" id="hubs-list"></div>
        </div>
    </div>

    <!-- Modal 2: Add New Address (Matches User Screenshot 3) -->
    <div class="modal-overlay" id="add-address-modal" onclick="closeAddAddressModal()">
        <div class="modal-sheet" onclick="event.stopPropagation()">
            <div class="modal-header-row">
                <button class="back-circle-btn" onclick="closeAddAddressModal()">✕</button>
                <div class="modal-heading">Add New Address</div>
            </div>

            <!-- Use current location card -->
            <div class="action-card" onclick="detectLiveLocation(); closeAddAddressModal();">
                <span style="font-size:18px;">🎯</span>
                <span style="color: #0f172a;">Use current location</span>
            </div>

            <div class="field-label">Address Details</div>

            <!-- Search address input -->
            <div class="input-card">
                <span style="color: #4f46e5;">📍</span>
                <input type="text" id="add-search-input" placeholder="Search address" oninput="filterOnlineAddress(this.value)">
            </div>

            <!-- Enter complete address multiline -->
            <div class="input-card" style="align-items: flex-start;">
                <span style="color: #4f46e5; margin-top: 2px;">🏢</span>
                <textarea id="add-complete-address" rows="3" placeholder="Enter complete address"></textarea>
            </div>

            <div class="field-label">Saved Address as</div>

            <!-- 3 Tag Segments: Home, Office, Other -->
            <div class="tags-container">
                <div class="tag-segment" id="tag-home" onclick="setTag('Home')">🏠 Home</div>
                <div class="tag-segment" id="tag-office" onclick="setTag('Office')">🏢 Office</div>
                <div class="tag-segment active" id="tag-other" onclick="setTag('Other')">📍 Other</div>
            </div>

            <!-- Add label input -->
            <div class="input-card">
                <input type="text" id="add-label-input" placeholder="Add label (e.g. My Studio, Gym)">
            </div>

            <!-- Save Address Button -->
            <button class="save-address-btn" onclick="saveNewAddress()">Save Address</button>
        </div>
    </div>
</div>

<script>
    let currentLat = 12.9922;
    let currentLng = 77.7290;
    let currentArea = "18 1st main road 3rd cross";
    let currentAddress = "18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru, 560067";
    let activeTag = "Other";

    const popularHubs = [
        { area: "18 1st main road 3rd cross", address: "18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru 560067", eta: "8-11 MINS", lat: 12.9922, lng: 77.7290 },
        { area: "Prestige Shantiniketan", address: "Tower 8, Prestige Shantiniketan, ITPL Main Rd, Whitefield, Bengaluru 560066", eta: "8-11 MINS", lat: 12.9698, lng: 77.7499 },
        { area: "Indiranagar 100ft Road", address: "Flat 402, Prestige Meridian, 100ft Road, HAL 2nd Stage, Indiranagar, Bengaluru 560038", eta: "8-11 MINS", lat: 12.9784, lng: 77.6408 },
        { area: "Koramangala 4th Block", address: "Tower 2, Raheja Residency, 80 Feet Rd, 4th Block, Koramangala, Bengaluru 560034", eta: "9-12 MINS", lat: 12.9352, lng: 77.6245 },
        { area: "HSR Layout Sector 2", address: "Flat 301, Purva Vantage, 27th Main Rd, Sector 2, HSR Layout, Bengaluru 560102", eta: "9-11 MINS", lat: 12.9121, lng: 77.6446 },
        { area: "DLF Cyber City", address: "Tower B, Building 10, DLF Cyber City, Phase 2, Gurugram, Haryana 122002", eta: "10-13 MINS", lat: 28.4595, lng: 77.0266 },
        { area: "Bandra West", address: "Flat 502, Galaxy Heights, Hill Road, Bandra West, Mumbai 400050", eta: "8-11 MINS", lat: 19.0596, lng: 72.8295 },
        { area: "Powai Hiranandani", address: "Tower 3, Central Avenue, Hiranandani Gardens, Powai, Mumbai 400076", eta: "9-12 MINS", lat: 19.1176, lng: 72.9060 }
    ];

    function setTag(tag) {
        activeTag = tag;
        document.getElementById('tag-home').className = 'tag-segment' + (tag === 'Home' ? ' active' : '');
        document.getElementById('tag-office').className = 'tag-segment' + (tag === 'Office' ? ' active' : '');
        document.getElementById('tag-other').className = 'tag-segment' + (tag === 'Other' ? ' active' : '');
    }

    let savedAddressesList = [
        { id: '1', title: '18 1st main road 3rd cross', address: '18 1st main road 3rd cross, Sapthagiri Layout Rd, phase 2, Chansandra, Bengaluru 560067', tag: 'Home', eta: '8-11 MINS', lat: 12.9922, lng: 77.7290 }
    ];

    function loadSavedAddresses() {
        const raw = localStorage.getItem('sp_saved_addresses_list');
        if (raw) {
            try { savedAddressesList = JSON.parse(raw); } catch(_) {}
        }
    }

    function saveAddressToList(item) {
        savedAddressesList = savedAddressesList.filter(a => a.address !== item.address);
        savedAddressesList.unshift(item);
        localStorage.setItem('sp_saved_addresses_list', JSON.stringify(savedAddressesList));
    }

    function deleteSavedAddress(e, id) {
        e.stopPropagation();
        savedAddressesList = savedAddressesList.filter(a => a.id !== id);
        localStorage.setItem('sp_saved_addresses_list', JSON.stringify(savedAddressesList));
        renderSavedList();
    }

    function renderSavedList() {
        const container = document.getElementById('hubs-list');
        if (!savedAddressesList || savedAddressesList.length === 0) {
            container.innerHTML = '<div style="padding:20px; text-align:center; color:#94a3b8; font-size:12.5px;">No saved addresses yet.<br>Tap "+ Add a New Address" to save one.</div>';
            return;
        }
        container.innerHTML = savedAddressesList.map(item => {
            const icon = item.tag === 'Home' ? '🏠' : (item.tag === 'Office' ? '🏢' : '📍');
            return `
                <div class="hub-item" onclick="selectHub('${item.title}', '${item.address}', '${item.eta || '8-11 MINS'}', ${item.lat}, ${item.lng})">
                    <div style="font-size:18px; padding-right:10px;">${icon}</div>
                    <div style="flex:1;">
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span style="font-size:13.5px; font-weight:700; color:#0f172a;">${item.title}</span>
                            <span style="font-size:10px; background:#eef2ff; color:#4f46e5; padding:2px 6px; border-radius:4px; font-weight:700;">${item.tag}</span>
                        </div>
                        <div style="font-size:11.5px; color:#64748b; margin-top:2px;">${item.address}</div>
                    </div>
                    <button onclick="deleteSavedAddress(event, '${item.id}')" style="background:none; border:none; color:#94a3b8; font-size:16px; cursor:pointer; padding:4px;">🗑</button>
                </div>
            `;
        }).join('');
    }

    function renderSearchResults(results) {
        const container = document.getElementById('hubs-list');
        if (!results || results.length === 0) {
            container.innerHTML = '<div style="padding:20px; text-align:center; color:#94a3b8; font-size:12.5px;">No locations found.</div>';
            return;
        }
        container.innerHTML = results.map(item => `
            <div class="hub-item" onclick="selectHub('${item.area}', '${item.address}', '${item.eta || '8-11 MINS'}', ${item.lat}, ${item.lng})">
                <div style="flex:1;">
                    <div style="font-size:13.5px; font-weight:700; color:#0f172a;">${item.area}</div>
                    <div style="font-size:11.5px; color:#64748b; margin-top:2px;">${item.address}</div>
                </div>
                <span style="color:#4f46e5; font-size:16px;">›</span>
            </div>
        `).join('');
    }

    let searchDebounce = null;
    async function filterHubs(query) {
        const q = query.toLowerCase().trim();
        if (!q) {
            document.getElementById('list-heading').innerText = `Saved Addresses (${savedAddressesList.length})`;
            return renderSavedList();
        }

        document.getElementById('list-heading').innerText = 'Search Results';
        clearTimeout(searchDebounce);
        searchDebounce = setTimeout(async () => {
            try {
                const resp = await fetch(`https://photon.komoot.io/api/?q=${encodeURIComponent(q)}&limit=10&lat=${currentLat}&lon=${currentLng}&bbox=68.0,8.0,97.5,37.5`);
                const data = await resp.json();
                if (data && data.features) {
                    const online = data.features.map(f => {
                        const p = f.properties || {};
                        const c = f.geometry ? f.geometry.coordinates : [currentLng, currentLat];
                        const name = p.name || p.street || p.locality || q;
                        const street = p.street || '';
                        const locality = p.locality || p.district || '';
                        const city = p.city || p.county || p.state || 'India';
                        const state = p.state || '';
                        const postcode = p.postcode || '';
                        const parts = [name, street && street !== name ? street : '', locality && locality !== name ? locality : '', city, state, postcode].filter(Boolean);
                        return { area: name, address: parts.join(', '), eta: '8-11 MINS', lat: c[1], lng: c[0] };
                    });
                    renderSearchResults(online);
                }
            } catch (_) {}
        }, 250);
    }

    function openChangeLocationModal() {
        loadSavedAddresses();
        document.getElementById('modal-search').value = '';
        document.getElementById('list-heading').innerText = `Saved Addresses (${savedAddressesList.length})`;
        document.getElementById('change-loc-modal').style.display = 'flex';
        renderSavedList();
    }
    function closeChangeLocationModal() {
        document.getElementById('change-loc-modal').style.display = 'none';
    }

    function openAddAddressModal() {
        closeChangeLocationModal();
        document.getElementById('add-complete-address').value = currentAddress;
        document.getElementById('add-address-modal').style.display = 'flex';
    }
    function closeAddAddressModal() {
        document.getElementById('add-address-modal').style.display = 'none';
    }

    function selectHub(title, address, eta, lat, lng) {
        currentArea = title;
        currentAddress = address;
        currentLat = lat;
        currentLng = lng;

        document.getElementById('loc-area').innerText = currentArea;
        document.getElementById('loc-address').innerText = currentAddress;

        localStorage.setItem('sp_saved_loc', JSON.stringify({ area: title, address, lat, lng }));
        closeChangeLocationModal();
        closeAddAddressModal();
        executeSearch();
    }

    function saveNewAddress() {
        const fullAddr = document.getElementById('add-complete-address').value.trim();
        if (!fullAddr) return;
        const label = document.getElementById('add-label-input').value.trim();
        const searchVal = document.getElementById('add-search-input').value.trim();

        let title = label || searchVal || (activeTag !== 'Other' ? activeTag : fullAddr.split(',')[0].trim());
        const newItem = {
            id: Date.now().toString(),
            title: title,
            address: fullAddr,
            tag: activeTag,
            eta: "8-11 MINS",
            lat: currentLat,
            lng: currentLng
        };
        saveAddressToList(newItem);
        selectHub(title, fullAddr, "8-11 MINS", currentLat, currentLng);
    }

    async function detectLiveLocation() {
        try {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(async (pos) => {
                    const lat = pos.coords.latitude;
                    const lng = pos.coords.longitude;
                    const resp = await fetch(`/api/v1/location/reverse?lat=${lat}&lng=${lng}`);
                    const data = await resp.json();
                    if (data.status === 'success') {
                        selectHub(data.areaName, data.fullAddress, data.eta, lat, lng);
                        return;
                    }
                }, () => fallbackIpLocation());
            } else {
                fallbackIpLocation();
            }
        } catch (_) {
            fallbackIpLocation();
        }
    }

    async function fallbackIpLocation() {
        try {
            const resp = await fetch('/api/v1/location/detect');
            const data = await resp.json();
            if (data.status === 'success') {
                selectHub(data.areaName, data.fullAddress, data.eta, data.lat, data.lng);
            }
        } catch (_) {}
    }

    function handleEnter(e) {
        if (e.key === 'Enter') executeSearch();
    }

    function quickSearch(tag) {
        document.getElementById('search-input').value = tag;
        executeSearch();
    }

    async function executeSearch() {
        const query = document.getElementById('search-input').value.trim();
        if (!query) return;

        const loader = document.getElementById('loader');
        const container = document.getElementById('results-container');
        
        loader.style.display = 'block';
        container.innerHTML = '';

        try {
            const resp = await fetch(`/api/v1/compare?query=${encodeURIComponent(query)}&lat=${currentLat}&lng=${currentLng}`);
            const data = await resp.json();
            loader.style.display = 'none';

            if (data.products && data.products.length > 0) {
                renderProducts(data.products);
            } else {
                container.innerHTML = `<div style="text-align:center; padding:30px; color:#94a3b8;">No products found for "${query}".</div>`;
            }
        } catch (err) {
            loader.style.display = 'none';
            container.innerHTML = `<div style="text-align:center; padding:20px; color:#ef4444;">Error connecting to backend: ${err.message}</div>`;
        }
    }

    function renderProducts(products) {
        const container = document.getElementById('results-container');
        container.innerHTML = products.map(prod => {
            const savingsHtml = prod.savings > 0 
                ? `<div class="savings-tag">Save ₹${prod.savings.toFixed(1)}</div>` 
                : '';

            const storesHtml = prod.offers.map(offer => {
                const isCheapest = offer.store.toLowerCase() === prod.cheapestStore.toLowerCase();
                const isZepto = offer.store.toLowerCase() === 'zepto';
                const storeClass = isZepto ? 'zepto' : 'blinkit';

                return `
                    <div class="store-box ${isCheapest ? 'cheapest' : ''}">
                        <div class="store-header">
                            <span class="store-name ${storeClass}">${offer.store}</span>
                            ${isCheapest ? '<span class="cheapest-badge">★ CHEAPEST</span>' : ''}
                        </div>
                        <div class="price-row">
                            <span class="price">₹${offer.price.toFixed(1)}</span>
                            ${offer.mrp > offer.price ? `<span class="mrp">₹${offer.mrp.toFixed(0)}</span>` : ''}
                        </div>
                        <div class="eta-row">
                            <span>⚡ ${offer.eta}</span>
                        </div>
                        <a href="${offer.deepLink}" target="_blank" class="buy-btn ${isCheapest ? 'cheapest-btn' : storeClass}">
                            Buy on ${offer.store}
                        </a>
                    </div>
                `;
            }).join('');

            return `
                <div class="card">
                    <div class="card-top">
                        <div class="item-info">
                            <div class="item-thumb">🛍️</div>
                            <div>
                                <div class="item-title">${prod.title}</div>
                                <div class="item-unit">${prod.packSize}</div>
                            </div>
                        </div>
                        ${savingsHtml}
                    </div>
                    <div class="stores-grid">
                        ${storesHtml}
                    </div>
                </div>
            `;
        }).join('');
    }

    const saved = localStorage.getItem('sp_saved_loc');
    if (saved) {
        try {
            const parsed = JSON.parse(saved);
            selectHub(parsed.area, parsed.address, "8-11 MINS", parsed.lat, parsed.lng);
        } catch (_) {
            detectLiveLocation();
        }
    } else {
        detectLiveLocation();
    }
</script>
</body>
</html>
    """

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
