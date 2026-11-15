
from pydantic import BaseModel, ConfigDict, Field


class StrictOutputModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class RotationStrategy(StrictOutputModel):
    name: str = Field(description="Short, distinct strategy name")

    crop_sequence: list[str] = Field(
        description="Ordered crops in the proposed rotation"
    )

    seasons: list[str] = Field(
        description="Season corresponding to each crop in crop_sequence"
    )

    rationale: str = Field(
        description="Concise explanation of the rotation"
    )

    expected_benefits: list[str] = Field(
        description="Potential benefits without unsupported numerical claims"
    )

    risks_and_uncertainties: list[str] = Field(
        description="Risks, assumptions, and points needing local verification"
    )

    evidence_used: list[str] = Field(
        description="Titles of supplied evidence sources"
    )


class StrategyOutput(StrictOutputModel):
    strategies: list[RotationStrategy] = Field(
        min_length=3,
        max_length=3,
        description="Exactly three different crop rotation strategies"
    )

    overall_notes: list[str] = Field(
        description="Important cross-strategy notes and missing information"
    )
