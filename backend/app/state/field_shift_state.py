# ============================================================
# 3. SHARED STATE
# ============================================================

from typing import Any, TypedDict


class FieldShiftState(TypedDict, total=False):
    farm: dict[str, Any]
    climate_data: list[dict[str, Any]]
    climate_summary: dict[str, Any]
    research_results: list[dict[str, Any]]
    strategy_output: dict[str, Any]
    validation: dict[str, Any]
    error: str