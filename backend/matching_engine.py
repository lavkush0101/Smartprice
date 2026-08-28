from typing import List, Dict, Any, Optional
import re

class ProductNormalizer:
    """
    Standardizes product names, pack sizes, and brands across Blinkit and Zepto
    to accurately group identical items together.
    """
    
    @staticmethod
    def normalize_unit(unit_str: str) -> str:
        if not unit_str:
            return ""
        s = unit_str.lower().strip()
        # 500 ml / 500ml / 0.5 l -> canonical format
        s = re.sub(r'\s+', '', s)
        s = re.sub(r'(\d+)\s*g(ram)?s?', r'\1 g', s)
        s = re.sub(r'(\d+)\s*kg(s)?', r'\1 kg', s)
        s = re.sub(r'(\d+)\s*ml(s)?', r'\1 ml', s)
        s = re.sub(r'(\d+)\s*l(itre|iter)?s?', r'\1 l', s)
        return s

    @staticmethod
    def clean_title(title: str) -> str:
        if not title:
            return ""
        # Remove common marketing buzzwords that differ across stores
        filler_words = [
            "fresh", "pure", "delicious", "pouch", "pack", "packet", "box",
            "super saver", "combo", "value pack", "authentic", "premium"
        ]
        cleaned = title.lower()
        for word in filler_words:
            cleaned = re.sub(rf'\b{word}\b', '', cleaned)
        cleaned = re.sub(r'[^a-zA-Z0-9\s]', ' ', cleaned)
        return ' '.join(cleaned.split())

    @classmethod
    def match_and_merge(cls, blinkit_items: List[Dict[str, Any]], zepto_items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        merged_products: List[Dict[str, Any]] = []
        used_zepto_indices = set()

        for b_item in blinkit_items:
            b_clean = cls.clean_title(b_item.get("name", ""))
            b_unit = cls.normalize_unit(b_item.get("unit", ""))
            
            matched_zepto = None
            matched_idx = -1

            for z_idx, z_item in enumerate(zepto_items):
                if z_idx in used_zepto_indices:
                    continue
                z_clean = cls.clean_title(z_item.get("name", ""))
                z_unit = cls.normalize_unit(z_item.get("unit", ""))

                # Basic token matching
                b_tokens = set(b_clean.split())
                z_tokens = set(z_clean.split())
                common_tokens = b_tokens.intersection(z_tokens)
                
                # Check if core brand + product match with compatible units
                similarity = len(common_tokens) / max(len(b_tokens), len(z_tokens), 1)
                
                if similarity >= 0.5 or (b_unit and z_unit and b_unit == z_unit and len(common_tokens) >= 2):
                    matched_zepto = z_item
                    matched_idx = z_idx
                    break

            offers = []
            # Blinkit offer
            offers.append({
                "store": "Blinkit",
                "price": float(b_item.get("price", 0)),
                "mrp": float(b_item.get("mrp", b_item.get("price", 0))),
                "inStock": b_item.get("inStock", True),
                "eta": b_item.get("eta", "12-15 mins"),
                "deepLink": b_item.get("deepLink", "https://blinkit.com"),
                "packageName": "com.grofers.customerapp"
            })

            # Zepto offer (if matched)
            if matched_zepto:
                used_zepto_indices.add(matched_idx)
                offers.append({
                    "store": "Zepto",
                    "price": float(matched_zepto.get("price", 0)),
                    "mrp": float(matched_zepto.get("mrp", matched_zepto.get("price", 0))),
                    "inStock": matched_zepto.get("inStock", True),
                    "eta": matched_zepto.get("eta", "10 mins"),
                    "deepLink": matched_zepto.get("deepLink", "https://zeptonow.com"),
                    "packageName": "com.zeptoconsumerapp"
                })

            # Determine cheapest
            cheapest_store = min(offers, key=lambda x: x["price"])["store"]
            min_price = min(o["price"] for o in offers)
            max_price = max(o["price"] for o in offers)
            savings = round(max_price - min_price, 2)

            merged_products.append({
                "id": f"prod_{len(merged_products) + 1}",
                "title": b_item.get("name", "").title(),
                "packSize": b_item.get("unit", ""),
                "imageUrl": b_item.get("imageUrl") or (matched_zepto.get("imageUrl") if matched_zepto else "") or "https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&auto=format&fit=crop&q=80",
                "cheapestStore": cheapest_store,
                "savings": savings,
                "offers": offers
            })

        # Add remaining unmatched Zepto items
        for z_idx, z_item in enumerate(zepto_items):
            if z_idx not in used_zepto_indices:
                offers = [{
                    "store": "Zepto",
                    "price": float(z_item.get("price", 0)),
                    "mrp": float(z_item.get("mrp", z_item.get("price", 0))),
                    "inStock": z_item.get("inStock", True),
                    "eta": z_item.get("eta", "10 mins"),
                    "deepLink": z_item.get("deepLink", "https://zeptonow.com"),
                    "packageName": "com.zeptoconsumerapp"
                }]
                merged_products.append({
                    "id": f"prod_{len(merged_products) + 1}",
                    "title": z_item.get("name", "").title(),
                    "packSize": z_item.get("unit", ""),
                    "imageUrl": z_item.get("imageUrl", ""),
                    "cheapestStore": "Zepto",
                    "savings": 0.0,
                    "offers": offers
                })

        return merged_products
