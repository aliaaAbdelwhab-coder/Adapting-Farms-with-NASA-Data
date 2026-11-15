# FieldShift – NASA-Powered Crop Intelligence

**Adapting Farms with NASA Data | NASA Space Apps Challenge 2026**

FieldShift is an AI-powered agricultural decision-support platform that helps farmers explore climate-aware crop rotation strategies based on NASA Earth observation data, farm-specific information, and agricultural research.

The project aims to make satellite climate data more accessible and useful for farm-level agricultural planning, especially in regions facing climate variability and water scarcity.

---

## The Problem

Farmers face increasing challenges from changing temperatures, irregular precipitation, and limited water resources. Choosing suitable crop rotation strategies requires considering environmental conditions, soil characteristics, crop history, irrigation practices, and farming priorities.

However, translating climate data and agricultural research into practical farm-level decisions can be difficult.

## Our Solution

FieldShift combines NASA climate data with farmer-provided farm information and agricultural research to generate **three alternative crop rotation strategies** using an AI-driven workflow.

Each strategy provides:

- **Crop Sequence:** Suggested crops across successive growing seasons.
- **Rationale:** Explanation behind the proposed rotation.
- **Potential Benefits:** Expected advantages based on the available information.
- **Risks:** Potential limitations and considerations.
- **Supporting Evidence:** Relevant agricultural research sources.

Rather than relying on predefined rotation templates, the system uses the available farm context and environmental analysis to generate dynamic alternatives.

---

## How It Works

The platform follows a multi-stage workflow:

1. **Farm Profile Collection:** The farmer provides the farm location, soil information, crop history, irrigation details, available water, and farming priorities.
2. **NASA Data Collection:** NASA POWER API retrieves climate data based on the farm's geographic coordinates.
3. **Climate Analysis:** Python and Pandas process the collected data and calculate relevant climate indicators.
4. **Agricultural Research:** Tavily Search retrieves relevant agricultural information and research.
5. **AI Strategy Generation:** A Groq-hosted LLM generates three alternative crop rotation strategies using the collected information.
6. **Output Validation:** Pydantic schemas and custom checks validate the structure of the generated strategies.

---

## NASA Data

FieldShift currently integrates **NASA POWER (Prediction Of Worldwide Energy Resources)**.

The climate parameters used include:

| Parameter | Description |
|---|---|
| T2M | Temperature at 2 meters |
| T2M_MAX | Maximum temperature |
| T2M_MIN | Minimum temperature |
| PRECTOTCORR | Corrected precipitation |
| ALLSKY_SFC_SW_DWN | All-sky surface shortwave downward irradiance |
| RH2M | Relative humidity at 2 meters |
| WS10M | Wind speed at 10 meters |

**NASA Resource:**  
[https://power.larc.nasa.gov/](https://power.larc.nasa.gov/)

### Additional Data Sources – Future Integration

- **NASA SMAP:** Soil moisture data.
- **NASA MODIS:** Vegetation indices such as NDVI.
- **NASA GPM:** Precipitation observations.

These datasets are planned extensions and are not integrated into the current workflow.

---

## System Architecture

```text
Flutter Application
       |
       v
   Farm Profile
       |
       v
    FastAPI
       |
       v
  LangGraph Workflow
       |
       +----------------------+
       |                      |
       v                      v
 NASA POWER API         Tavily Search
       |                      |
       v                      v
 Climate Analysis      Agricultural Research
       |                      |
       +----------+-----------+
                  |
                  v
             Groq LLM
                  |
                  v
       Crop Strategy Generation
                  |
                  v
        Structural Validation
                  |
                  v
          Three Strategies
                  |
                  v
          Application UI
```

---

## Technology Stack

| Component | Technologies |
|---|---|
| Frontend | Flutter, Dart |
| Backend | Python, FastAPI |
| NASA Data | NASA POWER API |
| Data Processing | Pandas, NumPy |
| AI Model | Groq-hosted LLM |
| Workflow Orchestration | LangChain, LangGraph |
| Agricultural Research | Tavily Search API |
| Data Validation | Pydantic, Custom Python Checks |

---

## Project Structure

The project is organized into two main components:

```text
FieldShift/
│
├── frontend/
│   └── Flutter application
│
├── backend/
│   ├── API endpoints
│   ├── Data collection
│   ├── Climate analysis
│   ├── Agricultural research
│   ├── AI strategy generation
│   ├── Validation
│   └── Schemas
│
└── README.md
```

*The structure above illustrates the main project organization; individual filenames and modules may differ.*

---

## Getting Started

### Prerequisites

- Python
- Flutter SDK
- Dart SDK
- API keys for Groq and Tavily

### Backend Setup

Navigate to the backend directory:

```bash
cd backend
```

Create and activate a virtual environment:

```bash
python -m venv .venv
```

Install the project dependencies:

```bash
pip install -r requirements.txt
```

Configure the required API credentials in a `.env` file according to the backend configuration.

Do not commit API keys or secret credentials to GitHub.

Start the FastAPI server using:

```bash
uvicorn main:app --reload
```

The API documentation is available at:

```text
http://127.0.0.1:8000/docs
```

**Main API Endpoint**

```http
POST /api/strategies
```

### Frontend Setup

Navigate to the frontend directory:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

*Note: Adjust the entry-point and environment configuration commands if your local project uses different filenames or settings.*

---

## Current Implementation Status

### Implemented

- Flutter farm-profile prototype.
- Map-based farm location selection.
- NASA POWER climate data retrieval and processing.
- Agricultural information retrieval through Tavily.
- Groq LLM integration.
- LangGraph-based workflow orchestration.
- Generation of three alternative crop rotation strategies.
- Structural validation of generated outputs.
- FastAPI endpoint for strategy generation.

### In Progress / Future Work

- NASA SMAP soil moisture extraction and integration.
- NASA MODIS vegetation-index integration.
- Expanded agricultural knowledge base.
- Agronomic validation of generated strategies.
- Real-farm testing and outcome evaluation.
- Further frontend-backend integration.

---

## Limitations

FieldShift is an experimental decision-support prototype, not a replacement for professional agronomic advice.

- NASA POWER provides climate indicators, not direct measurements of every farm's soil conditions.
- Soil characteristics and farm-management information are provided by the user.
- AI-generated crop rotation strategies depend on the quality and completeness of the available data and research.
- Current validation checks output structure, not agronomic correctness.
- The project has not yet undergone real-farm trials or verified measurements of yield improvement or water savings.

All generated strategies should be reviewed by qualified agricultural experts before practical implementation.

---

## Future Vision

FieldShift aims to evolve into a more comprehensive climate-smart agricultural decision-support platform by:

1. Integrating additional NASA Earth observation datasets.
2. Building a reliable agricultural knowledge base.
3. Developing stronger agronomic validation mechanisms.
4. Testing recommendations with real farms.
5. Evaluating measurable outcomes related to water use, crop productivity, and climate resilience.

---

## AI and SI Disclosure

AI tools were used during project development for ideation, research assistance, coding support, and technical troubleshooting.

A Groq-hosted Large Language Model is also a core component of the application, generating alternative crop rotation strategies from the collected environmental data, farm profile, and agricultural research.

---

## Acknowledgments

- [NASA POWER](https://power.larc.nasa.gov/) – Climate and environmental data.
- [Groq](https://groq.com/) – LLM inference.
- [Tavily](https://tavily.com/) – Agricultural research retrieval.
- [LangChain](https://www.langchain.com/) and [LangGraph](https://www.langchain.com/langgraph) – AI workflow development.

---

**FieldShift – Turning NASA Climate Data into Smarter Agricultural Decisions.**
