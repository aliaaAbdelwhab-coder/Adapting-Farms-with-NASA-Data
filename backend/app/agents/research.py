# ============================================================
# 7. NODE 3 - AGRICULTURAL RESEARCH WITH TAVILY
# ============================================================

import json
from typing import Any

from langchain_tavily import TavilySearch

from app.state.field_shift_state import FieldShiftState


def research_node(state: FieldShiftState) -> dict[str, Any]:
    print("\n[3/6] Searching for agricultural research with Tavily...")

    farm = state["farm"]
    climate = state["climate_summary"]

    query = (
        f"Scientific studies and agricultural extension research about crop "
        f"rotation suitable for {farm['location']}, Egypt, under conditions "
        f"similar to {farm['soilType']} soil. Consider crop rotation after "
        f"{farm['currentCrop']}, soil organic matter, salinity, irrigation "
        f"water limitations, heat and rainfall patterns. Prioritize Egypt, "
        f"Nile Delta, and Mediterranean climate studies. Find evidence about "
        f"seasonal suitability, soil health, legumes, crop water requirements, "
        f"and rotation constraints. Climate summary: "
        f"{json.dumps(climate['annual'], ensure_ascii=False)}"
    )

    search_tool = TavilySearch(
        max_results=6,
        search_depth="basic",
        topic="general",
        include_answer=False,
        include_raw_content=False,
    )

    result = search_tool.invoke({"query": query})

    if isinstance(result, dict):
        results = result.get("results", [])
    elif isinstance(result, list):
        results = result
    else:
        results = []

    cleaned = []
    for item in results:
        if not isinstance(item, dict):
            continue

        cleaned.append({
            "title": item.get("title", "Untitled"),
            "url": item.get("url", ""),
            "content": (item.get("content") or "")[:1800],
            "score": item.get("score"),
        })

    if not cleaned:
        raise ValueError(
            "Tavily returned no search results. Check TAVILY_API_KEY "
            "and the search query."
        )

    print(f"Found {len(cleaned)} research sources.")
    print("Raw source excerpts will be passed directly to the strategy-generation model.")

    # Keep source text and provenance for the strategy-generation model.
    return {"research_results": cleaned}