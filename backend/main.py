import os
import sys
from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
import asyncio

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

@app.get("/health")
def health_check():
    return {"status": "healthy"}

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
    """
    Renders an interactive, responsive mobile web application for instant local testing.
    """
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartPrice — Quick-Commerce Price Comparison</title>
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
            height: 90vh;
            max-height: 880px;
            background: #ffffff;
            border-radius: 36px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5), 0 0 0 10px #1e293b;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }
        .app-header {
            padding: 18px 20px 12px;
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
            background: #2563eb;
            color: white;
            padding: 6px 10px;
            border-radius: 10px;
            font-weight: 800;
            font-size: 16px;
        }
        .logo-text {
            font-size: 20px;
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
            padding: 16px 18px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .location-bar {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 10px 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
        }
        .location-left {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 600;
            color: #1e293b;
        }
        .location-select {
            border: none;
            background: transparent;
            font-size: 12px;
            font-weight: 700;
            color: #2563eb;
            cursor: pointer;
            outline: none;
        }
        .search-box {
            display: flex;
            gap: 8px;
            position: relative;
        }
        .search-input {
            flex: 1;
            padding: 12px 16px 12px 42px;
            border-radius: 14px;
            border: 1.5px solid #e2e8f0;
            background: #f8fafc;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
        }
        .search-input:focus {
            border-color: #2563eb;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        }
        .search-icon {
            position: absolute;
            left: 14px;
            top: 13px;
            font-size: 16px;
            color: #94a3b8;
        }
        .search-btn {
            background: #2563eb;
            color: white;
            border: none;
            padding: 0 18px;
            border-radius: 14px;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            transition: 0.2s;
        }
        .search-btn:hover {
            background: #1d4ed8;
        }
        .chips-row {
            display: flex;
            gap: 8px;
            overflow-x: auto;
            padding-bottom: 4px;
        }
        .chip {
            background: #f1f5f9;
            color: #475569;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            border: 1px solid transparent;
            transition: 0.2s;
        }
        .chip:hover, .chip.active {
            background: #e0e7ff;
            color: #2563eb;
            border-color: #c7d2fe;
        }
        .results-container {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .card {
            border: 1px solid #e2e8f0;
            border-radius: 18px;
            padding: 16px;
            background: #ffffff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.03);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        .item-info {
            display: flex;
            gap: 12px;
        }
        .item-thumb {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .item-title {
            font-size: 14.5px;
            font-weight: 700;
            color: #0f172a;
        }
        .item-unit {
            font-size: 12px;
            color: #64748b;
            margin-top: 2px;
        }
        .savings-tag {
            background: #dcfce7;
            color: #166534;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 8px;
            border-radius: 8px;
            border: 1px solid #bbf7d0;
            white-space: nowrap;
        }
        .stores-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .store-box {
            padding: 12px;
            border-radius: 12px;
            border: 1.5px solid #e2e8f0;
            background: #f8fafc;
            display: flex;
            flex-direction: column;
            gap: 4px;
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
            font-size: 13px;
            font-weight: 800;
        }
        .store-name.zepto { color: #7c3aed; }
        .store-name.blinkit { color: #d97706; }
        .cheapest-badge {
            background: #16a34a;
            color: white;
            font-size: 9px;
            font-weight: 800;
            padding: 2px 5px;
            border-radius: 4px;
        }
        .price-row {
            display: flex;
            align-items: baseline;
            gap: 6px;
            margin-top: 4px;
        }
        .price {
            font-size: 17px;
            font-weight: 800;
            color: #0f172a;
        }
        .mrp {
            font-size: 12px;
            color: #94a3b8;
            text-decoration: line-through;
        }
        .eta-row {
            font-size: 11px;
            color: #64748b;
            display: flex;
            align-items: center;
            gap: 3px;
        }
        .buy-btn {
            margin-top: 8px;
            padding: 7px 0;
            border-radius: 8px;
            border: none;
            font-size: 11.5px;
            font-weight: 700;
            color: white;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            display: block;
            transition: 0.15s;
        }
        .buy-btn.zepto { background: #7c3aed; }
        .buy-btn.blinkit { background: #d97706; }
        .buy-btn.cheapest-btn { background: #16a34a; }
        .buy-btn:hover { opacity: 0.9; }

        .loader {
            display: none;
            text-align: center;
            padding: 30px;
            color: #64748b;
            font-size: 14px;
        }
        .spinner {
            border: 3px solid #f1f5f9;
            border-top: 3px solid #2563eb;
            border-radius: 50%;
            width: 28px;
            height: 28px;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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
        <div class="badge">POC Simulator</div>
    </div>

    <div class="scrollable-body">
        <!-- Location Selector -->
        <div class="location-bar">
            <div class="location-left">
                <span>📍</span>
                <span id="location-text">Bangalore (Indiranagar)</span>
            </div>
            <select class="location-select" id="city-picker" onchange="changeCity()">
                <option value="12.9784,77.6408" selected>Bangalore (Indiranagar)</option>
                <option value="12.9352,77.6245">Bangalore (Koramangala)</option>
                <option value="28.4595,77.0266">Delhi NCR (Gurugram)</option>
                <option value="19.0596,72.8295">Mumbai (Bandra)</option>
                <option value="17.4474,78.3762">Hyderabad (Hitec City)</option>
            </select>
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
</div>

<script>
    let currentLat = 12.9784;
    let currentLng = 77.6408;

    function changeCity() {
        const picker = document.getElementById('city-picker');
        const [lat, lng] = picker.value.split(',');
        currentLat = parseFloat(lat);
        currentLng = parseFloat(lng);
        document.getElementById('location-text').innerText = picker.options[picker.selectedIndex].text;
        executeSearch();
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

    // Initial load
    executeSearch();
</script>
</body>
</html>
    """

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
