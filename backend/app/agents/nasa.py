import os
from typing import Any

from app.services.nasaPower import get_nasa_data
from app.state.field_shift_state import FieldShiftState
from app.config.config import END_DATE, START_DATE



def nasa_collection_node(state: FieldShiftState) -> dict[str, Any]:
    farm = state["farm"]
    print("\n[1/6] Downloading historical climate data from NASA POWER...")

    df = get_nasa_data(
        latitude=float(farm["latitude"]),
        longitude=float(farm["longitude"]),
        start_date=START_DATE,
        end_date=END_DATE,
    )

    records = df.assign(
        date=df["date"].dt.strftime("%Y-%m-%d")
    ).to_dict(orient="records")

    print(f"Downloaded {len(records)} daily records.")
    return {"climate_data": records}
