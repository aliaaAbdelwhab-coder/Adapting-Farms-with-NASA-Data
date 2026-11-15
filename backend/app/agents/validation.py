
# ============================================================
# 10. NODE 5 - BASIC PROGRAMMATIC VALIDATION
# ============================================================

from typing import Any

from app.state.field_shift_state import FieldShiftState


def strategy_validation_node(state: FieldShiftState) -> dict[str, Any]:
    print("\n[5/5] Validating the generated strategies...")

    strategies = state["strategy_output"]["strategies"]
    farm = state["farm"]
    warnings: list[str] = []
    checks: list[dict[str, Any]] = []

    for index, strategy in enumerate(strategies, start=1):
        crops = strategy.get("crop_sequence", [])
        seasons = strategy.get("seasons", [])

        valid_sequence = isinstance(crops, list) and len(crops) >= 2
        matching_seasons = len(crops) == len(seasons)

        if not valid_sequence:
            warnings.append(
                f"Strategy {index}: crop sequence should contain at least 2 crops."
            )
        if not matching_seasons:
            warnings.append(
                f"Strategy {index}: number of seasons does not match number of crops."
            )

        normalized = [str(c).strip().casefold() for c in crops]
        if len(normalized) != len(set(normalized)):
            warnings.append(
                f"Strategy {index}: a crop is repeated in the proposed sequence. "
                "This is a review flag, not an automatic agronomic rejection."
            )

        current_crop = str(farm.get("currentCrop", "")).strip().casefold()
        if normalized and normalized[0] == current_crop:
            warnings.append(
                f"Strategy {index}: first proposed crop is the same as the "
                "current crop; verify the intended rotation timing."
            )

        checks.append({
            "strategy": strategy.get("name", f"Strategy {index}"),
            "has_at_least_two_crops": valid_sequence,
            "crop_and_season_counts_match": matching_seasons,
        })

    validation = {
        "passed_basic_structure_check": all(
            item["has_at_least_two_crops"]
            and item["crop_and_season_counts_match"]
            for item in checks
        ),
        "checks": checks,
        "warnings": warnings,
        "important_note": (
            "These are structural checks only. They do not prove agronomic "
            "suitability. A local agronomist should verify crop calendars, "
            "soil constraints, and irrigation requirements."
        ),
    }

    return {"validation": validation}