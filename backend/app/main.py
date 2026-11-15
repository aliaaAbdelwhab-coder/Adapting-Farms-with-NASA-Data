

from fastapi import FastAPI

from app.schemas.farm import FarmProfile
from app.services.workflow import build_graph
from app.utils.helpers import require_api_keys

app = FastAPI(
    title="Field Shift API",
    description="Agricultural crop rotation recommendations using NASA data",
    version="1.0.0",
)

# Build the graph once when the application starts.
graph = build_graph()


@app.get("/")
def home():
    return {"message": "Field Shift API is running"}


@app.post("/api/strategies")
def generate_strategies(farm: FarmProfile):
    try:
        require_api_keys()

        initial_state = {
            "farm": farm.model_dump()
        }

        final_state = graph.invoke(initial_state)

        return {
            "farm": final_state.get("farm"),
            "climate_summary": final_state.get("climate_summary"),
            "research_results": final_state.get("research_results"),
            "strategy_output": final_state.get("strategy_output"),
            "validation": final_state.get("validation"),
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Workflow failed: {str(exc)}",
        ) from exc
