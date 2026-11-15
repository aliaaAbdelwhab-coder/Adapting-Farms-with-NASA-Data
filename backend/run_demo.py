"""Demo: sample farm dict -> NASA POWER (live) -> ClimateSummary.

Usage (from the backend/ folder):
    python run_demo.py iowa
    python run_demo.py nile_delta
    python run_demo.py wa_wheatbelt
    python run_demo.py kenya_highlands
"""
import sys

from app.clients.nasa_power import fetch_daily
from app.engine.climate_analysis import analyze_climate
from app.sample_input import SAMPLE_FARMS
from app.schemas import FarmInput


def main(key: str) -> None:
    farm = FarmInput(**SAMPLE_FARMS[key])
    print(f"Farm: {farm.farm_name} ({farm.lat}, {farm.lon})")
    df = fetch_daily(farm.lat, farm.lon)
    print(f"Downloaded {len(df)} daily rows, columns: {list(df.columns)}")
    summary = analyze_climate(df, farm.lat, farm.lon)
    print(summary.model_dump_json(indent=2))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "iowa")
