#!/usr/bin/env python3
"""
Script complet pour Firecrawl avec extraction de données
"""

import sys
import json
from firecrawl import FirecrawlApp, JsonConfig
from pydantic import BaseModel

class CompanyInfo(BaseModel):
    """Schéma de données à extraire"""
    company_mission: str = ""
    supports_sso: bool = False
    is_open_source: bool = False
    is_in_yc: bool = False

def main():
    # Récupération des arguments
    if len(sys.argv) < 3:
        print(json.dumps({"success": False, "error": "Usage: script.py <url> <api_key>"}))
        sys.exit(1)

    url = sys.argv[1]
    api_key = sys.argv[2]

    try:
        # Initialisation
        app = FirecrawlApp(api_key=api_key)
        
        # 1. D'abord récupérer le contenu du site en markdown
        result = app.scrape_url(url, formats=["markdown"])
        
        # 2. Extraire les informations de base
        markdown_content = result.markdown or ""
        
        # 3. Créer un objet pour stocker les informations extraites
        company_info = CompanyInfo()
        
        # 4. Extraire les informations
        # Extraire la mission (premiers paragraphes probablement)
        if markdown_content:
            first_paragraphs = " ".join(markdown_content.split('\n\n')[:2])
            company_info.company_mission = first_paragraphs[:300]
        
        # Recherche de mots-clés pour les autres champs
        company_info.supports_sso = "sso" in markdown_content.lower() or "single sign-on" in markdown_content.lower()
        company_info.is_open_source = "github" in markdown_content.lower() or "open source" in markdown_content.lower()
        company_info.is_in_yc = "y combinator" in markdown_content.lower() or "ycombinator" in markdown_content.lower()
        
        # 5. Construire le résultat final
        output = {
            "success": True,
            "data": {
                "url": url,
                "extraction": company_info.dict(),
                "content_preview": markdown_content[:500] + "..." if len(markdown_content) > 500 else markdown_content
            }
        }
        
        # Ajouter les métadonnées si disponibles
        if hasattr(result, "metadata") and result.metadata:
            output["data"]["metadata"] = result.metadata
        
        print(json.dumps(output))
        
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}))

if __name__ == "__main__":
    main()