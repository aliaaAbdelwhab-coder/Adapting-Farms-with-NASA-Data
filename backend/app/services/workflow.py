
# ============================================================
# 11. BUILD LANGGRAPH
# ============================================================
from typing import Any

from langgraph.graph import END, START, StateGraph

from app.state.field_shift_state import FieldShiftState

from app.agents.nasa import nasa_collection_node
from app.agents.analyze_climate import analyze_climate_node
from app.agents.research import research_node
from app.agents.strateges import strategy_generation_node
from app.agents.validation import strategy_validation_node
from app.utils.helpers import require_api_keys


# from IPython.display import Image, display
# from langgraph.graph import END, START, StateGraph
# from typing import Any
# from app.state.field_shift_state import FieldShiftState
# from backend.app.agents.analyze_climate import analyze_climate_node
# from backend.app.agents.nasa import nasa_collection_node
# from backend.app.agents.research import research_node
# from backend.app.agents.strateges import strategy_generation_node
# from backend.app.agents.validation import strategy_validation_node
# from backend.app.state.field_shift_state import FieldShiftState
# from backend.app.utils.helpers import require_api_keys
def build_graph():
    builder = StateGraph(FieldShiftState)

    builder.add_node("nasa_collection", nasa_collection_node)
    builder.add_node("climate_analysis", analyze_climate_node)
    builder.add_node("agricultural_research", research_node)
    builder.add_node("strategy_generation", strategy_generation_node)
    builder.add_node("strategy_validation", strategy_validation_node)

    builder.add_edge(START, "nasa_collection")
    builder.add_edge("nasa_collection", "climate_analysis")
    builder.add_edge("climate_analysis", "agricultural_research")
    builder.add_edge("agricultural_research", "strategy_generation")
    builder.add_edge("strategy_generation", "strategy_validation")
    builder.add_edge("strategy_validation", END)
    graph  = builder.compile()
    
    return graph







def run_workflow(farm_data: dict[str, Any]) -> dict[str, Any]:
    """
    Run the complete Field Shift workflow for one farm.
    """

    require_api_keys()

    graph = build_graph()

    initial_state: FieldShiftState = {
        "farm": farm_data,
    }

    # Execute the complete workflow.
    final_state = graph.invoke(initial_state)

    # Return only the results needed by the application.
    return {
        "farm": farm_data,
        "climate_summary": final_state.get("climate_summary"),
        "research_results": final_state.get("research_results"),
        "strategy_output": final_state.get("strategy_output"),
        "validation": final_state.get("validation"),
    }


