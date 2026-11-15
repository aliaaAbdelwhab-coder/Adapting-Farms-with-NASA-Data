

# ============================================================
# 6. NODE 2 - ANALYZE CLIMATE DATA
# ============================================================

import json
from typing import Any

import pandas as pd

from app.config.config import (
    END_DATE,
    NASA_PARAMETERS,
    START_DATE,
)
from app.state.field_shift_state import FieldShiftState


def analyze_climate_node(state: FieldShiftState) -> dict[str, Any]:
    print("\n[2/6] Analyzing climate data...")

    df = pd.DataFrame(state["climate_data"])
    df["date"] = pd.to_datetime(df["date"])

    summary: dict[str, Any] = {
        "period": f"{START_DATE} to {END_DATE}",
        "valid_daily_records": int(len(df)),
        "missing_values": {},
        "annual": {},
        "monthly": [],
    }

    for column in NASA_PARAMETERS:
        summary["missing_values"][column] = int(df[column].isna().sum())

    if "T2M" in df:
        summary["annual"]["average_temperature_c"] = round(
            float(df["T2M"].mean()), 2
        ) if df["T2M"].notna().any() else None

    if "T2M_MAX" in df:
        summary["annual"]["highest_daily_max_temperature_c"] = round(
            float(df["T2M_MAX"].max()), 2
        ) if df["T2M_MAX"].notna().any() else None

    if "T2M_MIN" in df:
        summary["annual"]["lowest_daily_min_temperature_c"] = round(
            float(df["T2M_MIN"].min()), 2
        ) if df["T2M_MIN"].notna().any() else None

    if "PRECTOTCORR" in df:
        summary["annual"]["total_precipitation_mm"] = round(
            float(df["PRECTOTCORR"].sum()), 2
        ) if df["PRECTOTCORR"].notna().any() else None
    if "ALLSKY_SFC_SW_DWN" in df:
        summary["annual"]["average_daily_solar_radiation"] = (
            float(df["ALLSKY_SFC_SW_DWN"].mean())
        )

    if "RH2M" in df:
        summary["annual"]["average_relative_humidity"] = (
            float(df["RH2M"].mean())
        )

    if "WS10M" in df:
        summary["annual"]["average_wind_speed_10m"] = (
            float(df["WS10M"].mean())
        )

    df["month"] = df["date"].dt.month
    monthly = df.groupby("month").agg(
        mean_temperature_c=("T2M", "mean"),
        precipitation_mm=("PRECTOTCORR", "sum"),
        mean_daily_max_temperature_c=("T2M_MAX", "mean"),
        mean_daily_min_temperature_c=("T2M_MIN", "mean"),
        mean_solar_radiation=(
                    "ALLSKY_SFC_SW_DWN", "mean"
                ),

                mean_relative_humidity=(
                    "RH2M", "mean"
                ),

                mean_wind_speed_10m=(
                    "WS10M", "mean"
                ),
    ).reset_index()

    summary["monthly"] = monthly.round(2).where(
        pd.notna(monthly), None
    ).to_dict(orient="records")

    print(json.dumps(summary["annual"], indent=2))
    return {"climate_summary": summary}
