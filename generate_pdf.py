import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            # Skip header/footer on cover page
            return
        
        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header
        self.drawString(54, 11 * 72 - 36, "SmartPrice — Quick-Commerce Price Comparison Engine")
        self.drawRightString(8.5 * 72 - 54, 11 * 72 - 36, "POC Architecture: HLD, DLD & Presentation")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 11 * 72 - 42, 8.5 * 72 - 54, 11 * 72 - 42)
        
        # Footer
        self.line(54, 45, 8.5 * 72 - 54, 45)
        self.drawString(54, 32, "Confidential — Engineering & Product Architecture Document")
        self.drawRightString(8.5 * 72 - 54, 32, f"Page {self._pageNumber} of {page_count}")
        self.restoreState()


def generate_smartprice_pdf(filename="SmartPrice_POC_HLD_DLD_and_PPT.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    # Custom Palette
    PRIMARY = colors.HexColor("#0F172A")    # Dark Slate
    SECONDARY = colors.HexColor("#2563EB")  # Royal Blue
    ACCENT = colors.HexColor("#059669")     # Emerald Green
    ZEPTO_PURPLE = colors.HexColor("#7C3AED")
    BLINKIT_YELLOW = colors.HexColor("#D97706")
    BG_LIGHT = colors.HexColor("#F8FAFC")
    BORDER_COLOR = colors.HexColor("#E2E8F0")
    TEXT_DARK = colors.HexColor("#1E293B")
    TEXT_MUTED = colors.HexColor("#475569")
    
    # Typography Styles
    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=28,
        leading=34,
        textColor=PRIMARY,
        alignment=0
    )
    
    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=13,
        leading=18,
        textColor=SECONDARY,
        alignment=0
    )
    
    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=PRIMARY,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )
    
    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=SECONDARY,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )
    
    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=14,
        textColor=TEXT_DARK,
        spaceAfter=6
    )
    
    bullet_style = ParagraphStyle(
        'BulletText',
        parent=body_style,
        leftIndent=12,
        firstLineIndent=-8,
        spaceAfter=3
    )
    
    code_style = ParagraphStyle(
        'CodeSnippet',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor("#0F172A")
    )
    
    slide_title_style = ParagraphStyle(
        'SlideTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=15,
        textColor=PRIMARY
    )
    
    slide_body_style = ParagraphStyle(
        'SlideBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=TEXT_DARK
    )
    
    story = []
    
    # ----------------------------------------------------
    # COVER PAGE
    # ----------------------------------------------------
    story.append(Spacer(1, 40))
    story.append(Paragraph("SmartPrice", ParagraphStyle('SuperTitle', fontName='Helvetica-Bold', fontSize=14, textColor=SECONDARY, leading=16)))
    story.append(Spacer(1, 6))
    story.append(Paragraph("Hyperlocal Quick-Commerce Price Comparison Engine", title_style))
    story.append(Spacer(1, 10))
    story.append(Paragraph("High-Level Design (HLD), Detailed-Level Design (DLD) & Pitch Deck for Android (Kotlin)", subtitle_style))
    story.append(Spacer(1, 14))
    story.append(HRFlowable(width="100%", thickness=3, color=SECONDARY, spaceAfter=20, spaceBefore=0))
    
    metadata_data = [
        [Paragraph("<b>Target Platforms:</b>", body_style), Paragraph("Blinkit & Zepto (Expandable to Instamart, BigBasket, Amazon Fresh)", body_style)],
        [Paragraph("<b>Mobile Tech Stack:</b>", body_style), Paragraph("Native Android (Kotlin), Jetpack Compose, Coroutines, Flow, Retrofit", body_style)],
        [Paragraph("<b>Backend Architecture:</b>", body_style), Paragraph("Python (FastAPI) / Node.js Microservice with Location-Aware Scraper Pipeline", body_style)],
        [Paragraph("<b>Document Version:</b>", body_style), Paragraph("1.0 (Proof of Concept - Production Blueprint)", body_style)],
        [Paragraph("<b>Author / Project:</b>", body_style), Paragraph("SmartPrice Engineering & Product Architecture Team", body_style)],
        [Paragraph("<b>API Cost / Charges:</b>", body_style), Paragraph("<font color='#059669'><b>₹0 (100% Free Public Web Ingestion for POC)</b></font>", body_style)]
    ]
    t_meta = Table(metadata_data, colWidths=[1.8*inch, 5.2*inch])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(t_meta)
    
    story.append(Spacer(1, 30))
    story.append(Paragraph("<b>Executive Summary:</b>", h2_style))
    story.append(Paragraph(
        "Consumers in urban India frequently toggle between multiple quick-commerce apps (Zepto, Blinkit, Instamart) "
        "to check product availability, delivery times, and price disparities. <b>SmartPrice</b> is a unified mobile aggregator "
        "that allows users to search for any item, resolves the user's nearest dark stores via GPS coordinates, compares real-time "
        "prices and delivery ETAs side-by-side, highlights the cheapest option, and enables seamless one-tap purchase via Android deep linking.",
        body_style
    ))
    
    story.append(PageBreak())
    
    # ----------------------------------------------------
    # SECTION 1: SYSTEM OVERVIEW & PROBLEM STATEMENT
    # ----------------------------------------------------
    story.append(Paragraph("1. Problem Statement & Market Opportunity", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=PRIMARY, spaceAfter=10, spaceBefore=2))
    
    story.append(Paragraph("<b>The Consumer Dilemma:</b>", h2_style))
    story.append(Paragraph("• <b>Price Arbitrage:</b> Identical FMCG items (e.g., Amul Milk, Tide Detergent, Coca-Cola) often carry 5% to 25% price differences across Blinkit and Zepto due to algorithmic dynamic pricing.", bullet_style))
    story.append(Paragraph("• <b>Hyperlocal Dark Store Variance:</b> Inventory and pricing are not nationwide; they are strictly tied to the user's physical GPS location (within 2-3 km radii).", bullet_style))
    story.append(Paragraph("• <b>Friction of App Switching:</b> Users open 3 separate apps, search the same item 3 times, compare manual delivery fees, and lose time.", bullet_style))
    
    story.append(Spacer(1, 8))
    story.append(Paragraph("<b>Core Objectives of the POC:</b>", h2_style))
    story.append(Paragraph("1. <b>Single-Query Search:</b> User types an item name once and retrieves combined results from both Blinkit and Zepto in < 1.5 seconds.", bullet_style))
    story.append(Paragraph("2. <b>Live GPS Location Ingestion:</b> Pass latitude and longitude dynamically to query the exact dark stores serving the user.", bullet_style))
    story.append(Paragraph("3. <b>Cheapest Indicator:</b> Clearly tag the lowest-price platform with exact MRP, discounted price, and estimated delivery minutes.", bullet_style))
    story.append(Paragraph("4. <b>Direct Deep Linking:</b> Tap 'Buy' to immediately launch the respective store app on Android or fall back to their mobile site.", bullet_style))
    
    story.append(Spacer(1, 14))
    
    # ----------------------------------------------------
    # SECTION 2: HIGH-LEVEL DESIGN (HLD)
    # ----------------------------------------------------
    story.append(Paragraph("2. High-Level Design (HLD)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=PRIMARY, spaceAfter=10, spaceBefore=2))
    
    story.append(Paragraph("<b>2.1 End-to-End System Architecture:</b>", h2_style))
    story.append(Paragraph(
        "The architecture is designed as a decoupled 3-tier system: Mobile Client (Android/Kotlin), "
        "Unified Aggregator API Gateway (Python/FastAPI), and Hyperlocal Fetching Workers (Blinkit & Zepto Scraper Nodes).",
        body_style
    ))
    
    arch_table_data = [
        [Paragraph("<b>Layer</b>", body_style), Paragraph("<b>Component</b>", body_style), Paragraph("<b>Key Responsibilities</b>", body_style)],
        [Paragraph("<b>Presentation</b>", body_style), Paragraph("Android App (Kotlin)", body_style), Paragraph("Jetpack Compose UI, GPS acquisition (FusedLocation), Search input, StateFlow rendering, Deep link intent launching.", body_style)],
        [Paragraph("<b>API Gateway</b>", body_style), Paragraph("Aggregator Microservice", body_style), Paragraph("Validates search queries & GPS coords, coordinates concurrent upstream async calls, aggregates and normalizes raw JSON.", body_style)],
        [Paragraph("<b>Ingestion Layer</b>", body_style), Paragraph("Platform Adapters", body_style), Paragraph("<b>Blinkit Adapter:</b> Queries Blinkit web API with Lat/Lng.<br/><b>Zepto Adapter:</b> Queries Zepto web API with Lat/Lng.", body_style)],
        [Paragraph("<b>Matching Engine</b>", body_style), Paragraph("Normalization Engine", body_style), Paragraph("Fuzzy matching on Title + Brand + Pack size (e.g., '500 ml' vs '0.5 L') to combine identical items into a single comparison card.", body_style)],
        [Paragraph("<b>Caching (Optional)</b>", body_style), Paragraph("Redis In-Memory Cache", body_style), Paragraph("Caches product searches per Lat/Lng grid for 15 minutes to reduce upstream hits and achieve sub-100ms response times.", body_style)]
    ]
    t_arch = Table(arch_table_data, colWidths=[1.2*inch, 1.8*inch, 4.0*inch])
    t_arch.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#E2E8F0")),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_arch)
    
    story.append(Spacer(1, 10))
    story.append(Paragraph("<b>2.2 Architectural Data Flow:</b>", h2_style))
    story.append(Paragraph("1. User opens SmartPrice app $\\rightarrow$ App requests GPS permission $\\rightarrow$ Acquires `(Lat: 12.9716, Lng: 77.5946)`.", bullet_style))
    story.append(Paragraph("2. User types <i>'Amul Butter'</i> $\\rightarrow$ Android ViewModel executes Retrofit call to `/api/v1/compare?query=amul+butter&lat=12.9716&lng=77.5946`.", bullet_style))
    story.append(Paragraph("3. Backend microservice spawns 2 concurrent asynchronous HTTP workers (Blinkit Worker + Zepto Worker).", bullet_style))
    story.append(Paragraph("4. Upstream responses parsed $\\rightarrow$ Filter out of stock items $\\rightarrow$ Fuzzy Matcher groups products $\\rightarrow$ Calculates cheapest store.", bullet_style))
    story.append(Paragraph("5. Android client receives clean unified JSON payload and displays cards with green 'CHEAPEST' badges.", bullet_style))
    story.append(Paragraph("6. User clicks 'Buy on Zepto' $\\rightarrow$ Android Intent launches Zepto application or web fallback.", bullet_style))
    
    story.append(PageBreak())
    
    # ----------------------------------------------------
    # SECTION 3: DETAILED-LEVEL DESIGN (DLD)
    # ----------------------------------------------------
    story.append(Paragraph("3. Detailed-Level Design (DLD / LLD)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=PRIMARY, spaceAfter=10, spaceBefore=2))
    
    story.append(Paragraph("<b>3.1 Android (Kotlin) Client Architecture:</b>", h2_style))
    story.append(Paragraph(
        "The Android client adheres strictly to <b>Google's Recommended Modern Android Architecture (MVVM + Clean Architecture)</b> "
        "using declarative <b>Jetpack Compose</b> for UI and <b>Kotlin Coroutines/StateFlow</b> for reactive state management.",
        body_style
    ))
    
    story.append(Paragraph("• <b>UI Layer:</b> Jetpack Compose (`ComparisonScreen`, `ProductCard`, `StoreBadge`, `SearchBarComponent`).", bullet_style))
    story.append(Paragraph("• <b>ViewModel Layer:</b> `ComparisonViewModel` exposes immutable `StateFlow<UiState>` (`Idle`, `Loading`, `Success`, `Error`).", bullet_style))
    story.append(Paragraph("• <b>Domain / Repository Layer:</b> `ComparisonRepositoryImpl` coordinates location provider and API calls.", bullet_style))
    story.append(Paragraph("• <b>Data Layer:</b> Retrofit 2 + OkHttp 4 client configured with timeouts and logging interceptors.", bullet_style))
    story.append(Paragraph("• <b>Location Services:</b> Google Play Services `FusedLocationProviderClient` with `PRIORITY_BALANCED_POWER_ACCURACY`.", bullet_style))
    
    story.append(Spacer(1, 8))
    story.append(Paragraph("<b>3.2 Backend API Specifications:</b>", h2_style))
    
    api_spec_data = [
        [Paragraph("<b>Endpoint:</b>", body_style), Paragraph("<code>GET /api/v1/compare</code>", body_style)],
        [Paragraph("<b>Query Parameters:</b>", body_style), Paragraph("<code>query</code> (String, required): Search term (e.g., 'milk')<br/><code>lat</code> (Float, required): User latitude (e.g., 12.9716)<br/><code>lng</code> (Float, required): User longitude (e.g., 77.5946)", body_style)],
        [Paragraph("<b>Response Status:</b>", body_style), Paragraph("<code>200 OK</code> on success | <code>400 Bad Request</code> on missing coords | <code>502 Bad Gateway</code> if upstream down", body_style)]
    ]
    t_api = Table(api_spec_data, colWidths=[1.8*inch, 5.2*inch])
    t_api.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(t_api)
    
    story.append(Spacer(1, 8))
    story.append(Paragraph("<b>Unified Response Schema (JSON):</b>", h2_style))
    
    schema_code = (
        "{\n"
        '  "status": "success",\n'
        '  "query": "Amul Butter",\n'
        '  "location": { "lat": 12.9716, "lng": 77.5946 },\n'
        '  "totalResults": 1,\n'
        '  "products": [\n'
        '    {\n'
        '      "id": "prod_amul_butter_100g",\n'
        '      "title": "Amul Pasteurised Butter",\n'
        '      "packSize": "100 g",\n'
        '      "imageUrl": "https://cdn.grofers.com/app/images/products/amul_butter.jpg",\n'
        '      "cheapestStore": "Zepto",\n'
        '      "maxSavings": 2.0,\n'
        '      "offers": [\n'
        '        {\n'
        '          "store": "Zepto",\n'
        '          "price": 58.0,\n'
        '          "mrp": 60.0,\n'
        '          "inStock": true,\n'
        '          "eta": "10 mins",\n'
        '          "deepLink": "https://www.zeptonow.com/pn/amul-pasteurised-butter/pvid/102",\n'
        '          "packageName": "com.zeptoconsumerapp"\n'
        '        },\n'
        '        {\n'
        '          "store": "Blinkit",\n'
        '          "price": 60.0,\n'
        '          "mrp": 60.0,\n'
        '          "inStock": true,\n'
        '          "eta": "14 mins",\n'
        '          "deepLink": "https://blinkit.com/prn/amul-butter/prid/204",\n'
        '          "packageName": "com.grofers.customerapp"\n'
        '        }\n'
        '      ]\n'
        '    }\n'
        '  ]\n'
        "}"
    )
    t_code = Table([[Paragraph(schema_code.replace("\n", "<br/>").replace(" ", "&nbsp;"), code_style)]], colWidths=[7.0*inch])
    t_code.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(t_code)
    
    story.append(Spacer(1, 8))
    story.append(Paragraph("<b>3.3 Cross-Platform Product Matching Algorithm:</b>", h2_style))
    story.append(Paragraph("Because Zepto and Blinkit use different catalog naming conventions, matching is done in 3 stages:", body_style))
    story.append(Paragraph("1. <b>Standardized Unit Tokenizer:</b> Convert <code>'500ml'</code>, <code>'500 ml'</code>, <code>'0.5L'</code> into canonical <code>'500_ml'</code>.", bullet_style))
    story.append(Paragraph("2. <b>Brand & Stopword Extraction:</b> Extract verified brands (e.g. <i>Amul, Britannia, Nestle, Coca-Cola</i>) and remove filler words (e.g. <i>'Fresh', 'Delicious', 'Pouch'</i>).", bullet_style))
    story.append(Paragraph("3. <b>Token Set Ratio Matching:</b> Calculate string similarity score $> 85\\%$. Items meeting threshold with identical normalized pack sizes are combined into one comparison card.", bullet_style))
    
    story.append(PageBreak())
    
    # ----------------------------------------------------
    # SECTION 4: PRESENTATION (PPT PITCH DECK FORMAT)
    # ----------------------------------------------------
    story.append(Paragraph("4. Project Presentation & Pitch Deck (10 Slides)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=PRIMARY, spaceAfter=8, spaceBefore=2))
    story.append(Paragraph("The following 10 slides provide a structured presentation suitable for product showcases, stakeholders, and engineering reviews:", body_style))
    story.append(Spacer(1, 6))
    
    slides = [
        ("Slide 1: Title & Executive Summary", "SmartPrice: Next-Gen Hyperlocal Price Comparison Engine", [
            "<b>Vision:</b> Eliminate quick-commerce overspending by empowering shoppers with instant price comparison across Blinkit, Zepto, and Instamart.",
            "<b>Value Proposition:</b> Save consumers 10-20% on monthly grocery bills while reducing app-switching friction to zero.",
            "<b>Target Audience:</b> Urban shoppers, bargain hunters, daily FMCG buyers in Tier 1 & Tier 2 cities."
        ]),
        ("Slide 2: The Core Problem", "Quick Commerce Fragmentation & Dynamic Price Discrepancies", [
            "<b>Price Variance:</b> Dark stores dynamically adjust prices based on local demand; identical products carry significant price gaps across apps.",
            "<b>Hyperlocal Barriers:</b> No centralized platform allows users to compare prices for their exact GPS block.",
            "<b>Wasted Time & Money:</b> Users spend 5-10 minutes checking multiple apps or settle for higher prices out of convenience."
        ]),
        ("Slide 3: The SmartPrice Solution", "Real-Time Side-by-Side Aggregation & 1-Tap Checkout", [
            "<b>Single Search:</b> Type once, compare everywhere in under 1.5 seconds.",
            "<b>Hyperlocal Dark Store Awareness:</b> Automatically routes queries to dark stores serving user's live latitude/longitude.",
            "<b>Cheapest Badge:</b> Instant visual highlighting of lowest cost, discounts, and delivery ETAs.",
            "<b>Seamless Routing:</b> Deep links open the store app directly to the product checkout."
        ]),
        ("Slide 4: Key Platform Features", "POC Capabilities vs Full Scale Product", [
            "<b>POC Scope:</b> Blinkit + Zepto comparison for FMCG, Dairy, Beverages, and Essentials.",
            "<b>Smart Sorting:</b> Filter by Lowest Price, Fastest Delivery (ETA), or Highest Discount.",
            "<b>Basket Optimizer (Phase 2):</b> Total grocery list optimization taking delivery fees into account.",
            "<b>Price Drop Alerts (Phase 3):</b> Push notifications when wishlisted products hit all-time low prices."
        ]),
        ("Slide 5: High-Level Architecture (HLD)", "Modern, Resilient, and Scalable 3-Tier Design", [
            "<b>Client Tier:</b> Native Android Kotlin app with Jetpack Compose & GPS location resolution.",
            "<b>API Gateway:</b> High-performance FastAPI backend coordinating parallel async worker tasks.",
            "<b>Ingestion Engine:</b> Web endpoint scrapers with User-Agent rotation and location header injection.",
            "<b>Cache & Resilience:</b> Redis caching layer protecting against upstream throttling and rate limits."
        ]),
        ("Slide 6: Android Client Design (DLD)", "Modern Android Architecture (MVVM + Jetpack Compose)", [
            "<b>UI / UX:</b> Declarative, silky-smooth Compose UI with responsive comparison cards & badges.",
            "<b>Reactive State:</b> Kotlin StateFlow & Coroutines ensuring zero UI freezes during searches.",
            "<b>Networking:</b> Robust Retrofit 2 client with automatic retry policies and error handling.",
            "<b>Intent Engine:</b> Launches native Android app (<code>com.grofers.customerapp</code> / <code>com.zeptoconsumerapp</code>) with browser fallback."
        ]),
        ("Slide 7: Ingestion & Fuzzy Matching Engine", "Overcoming Unofficial APIs & Catalog Differences", [
            "<b>No Paid APIs Required:</b> Ingests public search endpoints for ₹0 total API costs during POC.",
            "<b>Canonical Unit Normalizer:</b> Standardizes grams, kilograms, milliliters, and liter metrics.",
            "<b>Fuzzy Token Matcher:</b> Accurately pairs items across disparate catalog titles with >85% confidence score.",
            "<b>Dynamic Fallbacks:</b> Gracefully handles out-of-stock items and store closures."
        ]),
        ("Slide 8: Cost Analysis & Unit Economics", "Zero Cost POC to Lean Production Scale", [
            "<b>POC Cost:</b> ₹0 (Android Studio + Local FastAPI + Device GPS + Free Public Web Endpoints).",
            "<b>Scale Cost:</b> ~₹500 - ₹1,500/month (Basic Cloud VPS on Render/DigitalOcean + Redis).",
            "<b>Publishing:</b> $25 one-time Google Play Console developer registration fee.",
            "<b>Monetization Potential:</b> Affiliate commission on redirected sales, sponsored brand placements, and premium subscription for automated price alerts."
        ]),
        ("Slide 9: Security, Compliance & Anti-Scraping", "Building a Sustainable Aggregation Engine", [
            "<b>Rate-Limiting Defense:</b> 15-minute geo-grid caching reduces upstream hits by up to 80%.",
            "<b>Privacy First:</b> User location used purely for transient dark store resolution; no personal tracking.",
            "<b>Affiliate Alignment:</b> Drives qualified buying traffic directly into Blinkit & Zepto apps, creating win-win value."
        ]),
        ("Slide 10: Execution Roadmap & Milestones", "From Proof of Concept to App Store Launch", [
            "<b>Milestone 1 (Week 1-2):</b> Backend aggregator & Blinkit + Zepto adapters completed and tested.",
            "<b>Milestone 2 (Week 3-4):</b> Kotlin Android app UI, Location Provider, and Deep Linking completed.",
            "<b>Milestone 3 (Week 5):</b> Closed beta testing with 50 live users across 5 pincodes.",
            "<b>Milestone 4 (Week 6+):</b> Add Swiggy Instamart, Basket Optimizer & Play Store Launch."
        ])
    ]
    
    for i, (stitle, ssub, sbullets) in enumerate(slides, 1):
        slide_content = [
            [Paragraph(f"<b>{stitle}</b> — <font color='#2563EB'>{ssub}</font>", slide_title_style)],
            [HRFlowable(width="100%", thickness=0.75, color=SECONDARY, spaceAfter=4, spaceBefore=2)]
        ]
        for b in sbullets:
            slide_content.append([Paragraph(f"• {b}", slide_body_style)])
            
        t_slide = Table(slide_content, colWidths=[7.0*inch])
        t_slide.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
            ('BOX', (0, 0), (-1, -1), 1, BORDER_COLOR),
            ('TOPPADDING', (0, 0), (-1, -1), 3),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ]))
        story.append(t_slide)
        story.append(Spacer(1, 5))
        if i % 3 == 0 and i != len(slides):
            story.append(PageBreak())
            
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Successfully generated: {filename}")

if __name__ == "__main__":
    generate_smartprice_pdf()
