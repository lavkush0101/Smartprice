# SmartPrice — Quick-Commerce Price Comparison Engine (POC)

An end-to-end price comparison platform comparing **Blinkit & Zepto** in real-time based on your exact GPS location.

---

## 📁 Project Structure

```
d:\MyProject\smartprice\
├── backend/                             # Python FastAPI Microservice
│   ├── main.py                          # Aggregator API & Endpoints
│   ├── matching_engine.py               # Fuzzy Matcher & Normalizer
│   └── adapters/
│       ├── blinkit_adapter.py           # Blinkit Ingestion Adapter
│       └── zepto_adapter.py             # Zepto Ingestion Adapter
│
├── smartprice_mobile/                   # Flutter Cross-Platform App
│   ├── pubspec.yaml                     # Flutter Dependencies
│   └── lib/
│       ├── main.dart                    # App Entrypoint
│       ├── models/                      # Product & Store Data Models
│       ├── services/                    # Location & HTTP API Services
│       ├── screens/                     # Home Search & Comparison UI
│       └── widgets/                     # ProductCard & LocationBar
│
├── SmartPrice_POC_HLD_DLD_and_PPT.pdf   # Architecture Document (PDF)
├── SmartPrice_POC_HLD_DLD_and_PPT.md    # Architecture Document (Markdown)
└── run_backend.bat                      # 1-Click Backend Server Launcher
```

---

## 🚀 How to Run and Test Locally

### Step 1: Start the Backend Server
1. Double-click `run_backend.bat` or run in terminal:
   ```bash
   python backend/main.py
   ```
2. The server will start at: `http://localhost:8000`
3. Interactive API documentation is available at: `http://localhost:8000/docs`

---

### Step 2: Install Flutter (If not already installed)
1. Download Flutter SDK for Windows from [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
2. Extract the zip to `C:\src\flutter` (or any preferred folder).
3. Add `C:\src\flutter\bin` to your Windows **Environment Variables (PATH)**.
4. Verify by opening a terminal and running:
   ```bash
   flutter doctor
   ```

---

### Step 3: Run the Flutter Mobile App
1. Open terminal inside `smartprice_mobile`:
   ```bash
   cd smartprice_mobile
   flutter pub get
   ```
2. Run on your connected phone, emulator, or Chrome browser:
   ```bash
   flutter run
   ```
3. The app will fetch live comparison data from your running backend server!
