from typing import Any

from pydantic import BaseModel, Field


class FarmProfile(BaseModel):
    farmName: str = Field(..., min_length=1)
    location: str = Field(..., min_length=1)

    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)

    cultivatedArea: float = Field(..., gt=0)
    areaUnit: str

    soilType: str
    currentCrop: str

    waterSource: str | None = None
    country: str | None = None
    governorate: str | None = None
    soilPH: float | None = None
    soilSalinityEC: float | None = None
    soilOrganicMatter: float | None = None
    previousWinterCrop: str | None = None
    cropHistory: list[dict[str, Any]] | None = None
    plantingDate: str | None = None
    expectedHarvestDate: str | None = None
    irrigationMethod: str | None = None
    irrigationFrequency: str | None = None
    availableWaterAmount: float | None = None
    availableWaterUnit: str | None = None
    farmerGoal: list[str] | None = None
    goalPriority: list[str] | None = None
    priorities: dict[str, Any] | None = None
