"""Maps raw workflow output into the UI-ready payload consumed by the app."""

from typing import Any


def _monthly_series(monthly: Any, key: str) -> list[float | None]:
    series: list[float | None] = [None] * 12
    if not isinstance(monthly, list):
        return series
    for item in monthly:
        if not isinstance(item, dict):
            continue
        month = item.get("month")
        value = item.get(key)
        if isinstance(month, (int, float)) and 1 <= month <= 12 and isinstance(
            value, (int, float)
        ):
            series[int(month) - 1] = float(value)
    return series


def environment_payload(climate_summary: Any) -> dict[str, Any]:
    summary = climate_summary if isinstance(climate_summary, dict) else {}
    annual = summary.get("annual")
    annual = annual if isinstance(annual, dict) else {}

    return {
        "temperature": annual.get("average_temperature_c"),
        "precipitation": annual.get("total_precipitation_mm"),
        "monthlyMeanTemperatureC": _monthly_series(
            summary.get("monthly"), "mean_temperature_c"
        ),
        "monthlyPrecipitationMm": _monthly_series(
            summary.get("monthly"), "precipitation_mm"
        ),
    }


def _join_items(value: Any) -> str:
    if not isinstance(value, list):
        return ""
    return "; ".join(
        str(item).strip() for item in value if str(item).strip()
    )


def plan_payloads(strategy_output: Any) -> list[dict[str, Any]]:
    output = strategy_output if isinstance(strategy_output, dict) else {}
    strategies = output.get("strategies")
    if not isinstance(strategies, list):
        return []

    plans: list[dict[str, Any]] = []
    for index, item in enumerate(strategies):
        if not isinstance(item, dict):
            continue

        crops = item.get("crop_sequence")
        seasons = item.get("seasons")
        benefits = _join_items(item.get("expected_benefits"))
        risks = _join_items(item.get("risks_and_uncertainties"))

        description_parts = []
        rationale = item.get("rationale")
        if isinstance(rationale, str) and rationale.strip():
            description_parts.append(rationale.strip())
        if isinstance(seasons, list) and seasons:
            description_parts.append(
                "Seasons: " + " → ".join(str(s) for s in seasons)
            )
        if benefits:
            description_parts.append(f"Expected benefits: {benefits}")
        if risks:
            description_parts.append(f"Risks: {risks}")

        name = item.get("name")
        plans.append({
            "id": f"strategy-{index + 1}",
            "title": name.strip() if isinstance(name, str) and name.strip()
                     else f"Strategy {index + 1}",
            "description": "\n".join(description_parts),
            "badgeLabel": "Generated Plan",
            "matchPercent": None,
            "crops": [str(c) for c in crops] if isinstance(crops, list) else [],
            "waterDemandLabel": None,
            "waterDemandPercent": None,
            "soilHealthScore": None,
            "climateResilienceScore": None,
            "biomassNitrogen": "Not available",
            "rootingDepth": "Not available",
        })
    return plans


def overall_notes(strategy_output: Any) -> list[str]:
    output = strategy_output if isinstance(strategy_output, dict) else {}
    notes = output.get("overall_notes")
    if not isinstance(notes, list):
        return []
    return [str(n).strip() for n in notes if str(n).strip()]


def validation_warnings(validation: Any) -> list[str]:
    result = validation if isinstance(validation, dict) else {}
    warnings = result.get("warnings")
    if not isinstance(warnings, list):
        return []
    return [str(w).strip() for w in warnings if str(w).strip()]


def analysis_payload(final_state: dict[str, Any]) -> dict[str, Any]:
    """UI-ready payload: environment readings + plan cards."""
    return {
        "farm": final_state.get("farm"),
        "environment": environment_payload(final_state.get("climate_summary")),
        "plans": plan_payloads(final_state.get("strategy_output")),
        "overallNotes": overall_notes(final_state.get("strategy_output")),
        "validationWarnings": validation_warnings(final_state.get("validation")),
        "validation": final_state.get("validation"),
    }
