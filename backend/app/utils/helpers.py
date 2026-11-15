
# ============================================================
# 4. HELPERS
# ============================================================
import json
import os
from typing import Any

from dotenv import load_dotenv
from langchain_groq import ChatGroq
from pydantic import BaseModel
from langchain_core.messages import HumanMessage, SystemMessage

load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
TAVILY_API_KEY = os.getenv("TAVILY_API_KEY")
GROQ_MODEL = os.getenv("GROQ_MODEL", "openai/gpt-oss-20b")

def require_api_keys() -> None:
    missing = []
    if not GROQ_API_KEY:
        missing.append("GROQ_API_KEY")
    if not TAVILY_API_KEY:
        missing.append("TAVILY_API_KEY")
    if missing:
        raise RuntimeError(
            "Missing API key(s): "
            + ", ".join(missing)
            + ". Add them to the .env file."
        )


def get_llm() -> ChatGroq:
    return ChatGroq(
        model=GROQ_MODEL,
        temperature=0.2,
        max_tokens=8192,
        api_key=GROQ_API_KEY,
    )


def content_to_text(response: Any) -> str:
    """Extract readable text from a LangChain AIMessage or plain string."""
    content = getattr(response, "content", response)

    if isinstance(content, str):
        return content

    if isinstance(content, list):
        parts = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(item.get("text", ""))
            elif isinstance(item, str):
                parts.append(item)
        return "\n".join(parts)

    return str(content)


def save_json_file(data: Any, file_path: str) -> None:
    """Save a JSON result or debugging record immediately."""
    with open(file_path, "w", encoding="utf-8") as file:
        json.dump(
            data,
            file,
            ensure_ascii=False,
            indent=2,
            default=str,
        )


def invoke_structured_once(
    llm: ChatGroq,
    schema: type[BaseModel],
    system_prompt: str,
    user_prompt: str,
    output_path: str,
) -> BaseModel:
    """
    Make exactly one model call using tool/function structured output; Pydantic validates the result.
    Save the validated result, or save raw debugging details if it fails.
    """

    structured_llm = llm.with_structured_output(
        schema,
        method="function_calling",
        strict=False,
        include_raw=True,
    )

    try:
        response = structured_llm.invoke([
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt),
        ])
    except Exception as exc:
        debug_path = output_path.replace(".json", "_debug.json")
        save_json_file(
            {
                "status": "model_call_failed",
                "error_type": type(exc).__name__,
                "error": str(exc),
            },
            debug_path,
        )
        raise

    raw_message = response.get("raw")
    parsed_result = response.get("parsed")
    parsing_error = response.get("parsing_error")

    raw_text = content_to_text(raw_message) if raw_message else ""
    metadata = getattr(raw_message, "response_metadata", {}) if raw_message else {}

    if parsing_error is not None or parsed_result is None:
        debug_path = output_path.replace(".json", "_debug.json")

        save_json_file(
            {
                "status": "structured_output_failed",
                "raw_response": raw_text,
                "response_metadata": metadata,
                "parsing_error": str(parsing_error),
            },
            debug_path,
        )

        print("\nSTRUCTURED OUTPUT FAILED")
        print("Raw response:")
        print(repr(raw_text))
        print("Parsing error:", parsing_error)
        print("Debug details saved to:", debug_path)

        raise ValueError(
            f"Could not produce valid {schema.__name__} output. "
            f"See {debug_path} for the raw response and error."
        )

    # Pydantic object has already been validated by with_structured_output.
    result_data = (
        parsed_result.model_dump()
        if isinstance(parsed_result, BaseModel)
        else parsed_result
    )

    save_json_file(result_data, output_path)
    print(f"Structured output saved to: {output_path}")

    return parsed_result