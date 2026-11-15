# ============================================================
# 9. NODE 4 - GENERATE THREE CROP ROTATION STRATEGIES
# ============================================================

import json
from typing import Any

from app.schemas.strategy import StrategyOutput
from app.state.field_shift_state import FieldShiftState
from app.utils.helpers import get_llm, invoke_structured_once


STRATEGY_SYSTEM_PROMPT = """
You are an agricultural decision-support model for Field Shift.

MANDATORY OUTPUT:
- You MUST return the "strategies" field containing exactly THREE complete strategy objects.
- You MUST also return the "overall_notes" field.
- Never return overall_notes alone. Never omit strategies.
- If evidence is incomplete, still provide three provisional candidate rotations.
  Put uncertain crop suitability and assumptions in risks_and_uncertainties.
  Do not replace the strategies with a list of limitations.

Use the supplied farm profile, NASA POWER historical climate analysis,
and the raw Tavily research excerpts. Assess source relevance yourself.

For every strategy:
- Provide a distinct crop sequence and its corresponding seasons.
- Respect the known crop history, soil, irrigation, and farmer goals.
- Use only supplied research source titles in evidence_used.
- Explain the reasoning and distinguish evidence from assumptions.
- State risks and what needs local agronomist verification.

Across all strategies:
- Do not invent yields, profits, water savings, or numerical improvements.
- NASA POWER data here describe historical temperature and precipitation;
  they do not directly measure soil health or crop water use.
- Do not invent exact planting dates.
- Do not claim a crop is locally suitable unless the supplied evidence supports it.
"""


def strategy_generation_node(state: FieldShiftState) -> dict[str, Any]:
    print("\n[4/5] Generating crop-rotation strategies...")

    llm = get_llm()

    user_prompt = f"""
Farm profile:
{json.dumps(state["farm"], ensure_ascii=False)}

NASA POWER historical climate analysis:
{json.dumps(state["climate_summary"], ensure_ascii=False)}

Tavily agricultural research sources (original titles, URLs, and excerpts):
{json.dumps(state["research_results"], ensure_ascii=False)}

Return all required fields. The "strategies" array is mandatory and must
contain exactly 3 complete objects, even if some recommendations are provisional.
Review the supplied Tavily excerpts directly. Use only source titles that
actually appear in research_results in evidence_used. Do not invent citations.
Put missing information and assumptions in risks_and_uncertainties and overall_notes;
do not omit the strategies array.

For each strategy provide:
- name
- crop_sequence
- seasons (one season for each crop)
- rationale
- expected_benefits
- risks_and_uncertainties
- evidence_used (source titles only)

Also provide overall_notes for major assumptions, evidence limitations,
and information that should be checked locally.
"""

    strategy_result = invoke_structured_once(
        llm=llm,
        schema=StrategyOutput,
        system_prompt=STRATEGY_SYSTEM_PROMPT,
        user_prompt=user_prompt,
        output_path="strategy_output.json",
    )

    if len(strategy_result.strategies) != 3:
        raise ValueError(
            f"The model returned {len(strategy_result.strategies)} strategies; "
            "exactly 3 are required. The model output was saved for inspection."
        )

    result = strategy_result.model_dump()
    print("Generated exactly 3 strategies.")

    return {"strategy_output": result}