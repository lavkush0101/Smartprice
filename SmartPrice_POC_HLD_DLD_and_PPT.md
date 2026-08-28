# SmartPrice — Quick-Commerce Price Comparison Engine
## Proof of Concept (POC): High-Level Design (HLD), Detailed-Level Design (DLD) & Pitch Deck

---

## Executive Summary
Consumers in urban India frequently toggle between multiple quick-commerce apps (Zepto, Blinkit, Instamart) to check product availability, delivery times, and price disparities. **SmartPrice** is a unified mobile aggregator built with **Android (Kotlin + Jetpack Compose)** and a **FastAPI backend** that allows users to search for any item, resolves the user's nearest dark stores via GPS coordinates, compares real-time prices and delivery ETAs side-by-side, highlights the cheapest option, and enables seamless one-tap purchase via Android deep linking.

---

## 1. Problem Statement & Market Opportunity
* **Price Arbitrage:** Identical FMCG items (e.g., Amul Milk, Tide Detergent, Coca-Cola) often carry 5% to 25% price differences across Blinkit and Zepto due to algorithmic dynamic pricing.
* **Hyperlocal Dark Store Variance:** Inventory and pricing are not nationwide; they are strictly tied to the user's physical GPS location (within 2-3 km radii).
* **Friction of App Switching:** Users open 3 separate apps, search the same item 3 times, compare manual delivery fees, and lose time.

---

## 2. High-Level Design (HLD)

### 2.1 System Architecture
```
┌────────────────────────────────────────────────────────┐
│             Android Mobile Client (Kotlin)             │
│        Jetpack Compose UI  |  Fused Location GPS       │
└───────────────────────────┬────────────────────────────┘
                            │  GET /api/v1/compare?query=milk&lat=..&lng=..
                            ▼
┌────────────────────────────────────────────────────────┐
│           SmartPrice API Gateway (FastAPI)             │
│    • Coordinates concurrent worker tasks               │
│    • Normalizes and matches cross-catalog products     │
│    • Identifies cheapest store and potential savings   │
└──────────────┬──────────────────────────┬──────────────┘
               │                          │
               ▼                          ▼
   ┌───────────────────────┐  ┌───────────────────────┐
   │    Blinkit Adapter    │  │     Zepto Adapter     │
   │  (Web Search Ingest)  │  │  (Web Search Ingest)  │
   └───────────────────────┘  └───────────────────────┘
```

### 2.2 System Components

| Layer | Component | Description |
| :--- | :--- | :--- |
| **Presentation** | Android App (Kotlin) | Jetpack Compose UI, GPS acquisition (FusedLocation), Search input, StateFlow rendering, Deep link intent launching. |
| **API Gateway** | Aggregator Microservice | Validates search queries & GPS coords, coordinates concurrent upstream async calls, aggregates and normalizes raw JSON. |
| **Ingestion Layer** | Platform Adapters | **Blinkit Adapter:** Queries Blinkit web API with Lat/Lng.<br/>**Zepto Adapter:** Queries Zepto web API with Lat/Lng. |
| **Matching Engine** | Normalization Engine | Fuzzy matching on Title + Brand + Pack size (e.g., '500 ml' vs '0.5 L') to combine identical items into a single comparison card. |
| **Caching Layer** | Redis In-Memory Cache | Caches product searches per Lat/Lng grid for 15 minutes to reduce upstream hits and achieve sub-100ms response times. |

---

## 3. Detailed-Level Design (DLD / LLD)

### 3.1 Android Client Architecture (Kotlin)
* **Design Pattern:** MVVM (Model-View-ViewModel) + Clean Architecture
* **UI Toolkit:** Jetpack Compose (Declarative, Reactive UI)
* **Async & State:** Kotlin Coroutines + `StateFlow<UiState>`
* **Networking:** Retrofit 2 + OkHttp 4
* **Location Engine:** Google Play Services `FusedLocationProviderClient` (`PRIORITY_BALANCED_POWER_ACCURACY`)

### 3.2 Deep Linking & Intent Navigation Logic
```kotlin
fun openStoreApp(context: Context, packageName: String, fallbackUrl: String) {
    val intent = context.packageManager.getLaunchIntentForPackage(packageName)
    if (intent != null) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    } else {
        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(fallbackUrl))
        context.startActivity(browserIntent)
    }
}
```

### 3.3 Backend API Specification
* **Endpoint:** `GET /api/v1/compare`
* **Query Parameters:**
  * `query` (String, required): Item name (e.g. `Amul Butter`)
  * `lat` (Float, required): User latitude
  * `lng` (Float, required): User longitude

#### Unified Response Payload (JSON):
```json
{
  "status": "success",
  "query": "Amul Butter",
  "location": { "lat": 12.9716, "lng": 77.5946 },
  "totalResults": 1,
  "products": [
    {
      "id": "prod_amul_butter_100g",
      "title": "Amul Pasteurised Butter",
      "packSize": "100 g",
      "imageUrl": "https://cdn.grofers.com/app/images/products/amul_butter.jpg",
      "cheapestStore": "Zepto",
      "maxSavings": 2.0,
      "offers": [
        {
          "store": "Zepto",
          "price": 58.0,
          "mrp": 60.0,
          "inStock": true,
          "eta": "10 mins",
          "deepLink": "https://www.zeptonow.com/pn/amul-pasteurised-butter/pvid/102",
          "packageName": "com.zeptoconsumerapp"
        },
        {
          "store": "Blinkit",
          "price": 60.0,
          "mrp": 60.0,
          "inStock": true,
          "eta": "14 mins",
          "deepLink": "https://blinkit.com/prn/amul-butter/prid/204",
          "packageName": "com.grofers.customerapp"
        }
      ]
    }
  ]
}
```

---

## 4. Pitch Deck & Presentation (10 Slides)

* **Slide 1: Title & Executive Summary** — SmartPrice: Next-Gen Hyperlocal Price Comparison Engine
* **Slide 2: The Core Problem** — Quick Commerce Fragmentation & Dynamic Price Discrepancies
* **Slide 3: The SmartPrice Solution** — Real-Time Side-by-Side Aggregation & 1-Tap Checkout
* **Slide 4: Key Platform Features** — POC Capabilities vs Full Scale Product
* **Slide 5: High-Level Architecture (HLD)** — Modern, Resilient, and Scalable 3-Tier Design
* **Slide 6: Android Client Design (DLD)** — Modern Android Architecture (MVVM + Jetpack Compose)
* **Slide 7: Ingestion & Fuzzy Matching Engine** — Overcoming Unofficial APIs & Catalog Differences
* **Slide 8: Cost Analysis & Unit Economics** — Zero Cost POC to Lean Production Scale
* **Slide 9: Security, Compliance & Anti-Scraping** — Building a Sustainable Aggregation Engine
* **Slide 10: Execution Roadmap & Milestones** — From Proof of Concept to App Store Launch

---

## 5. Cost Analysis & Zero-Cost Feasibility

| Item | POC Cost | Production Scale Cost |
| :--- | :--- | :--- |
| **API Ingestion** | **₹0** (Public web endpoints) | **₹0** (Cached endpoints) |
| **Android Development** | **₹0** (Android Studio + Phone) | **$25** one-time Play Console |
| **Server Hosting** | **₹0** (Localhost / Free Tier) | **~₹500 - ₹1,500/mo** (Cloud VPS) |
| **GPS / Location** | **₹0** (Device hardware GPS) | **₹0** (Device hardware GPS) |
