### 2026, January 7 version 1.1.0
- **Dual-endpoint architecture:** GenerateContent and Interactions
  The wrapper exposes two Gemini endpoints with clearly distinct roles:

- **GenerateContent:**
  - Stateless execution
  - Text and multimodal generation
  - Simple SSE streaming
  - Well suited for direct generation scenarios and user-facing interfaces

- **Interactions:**
  - Resource-oriented API
  - Server-side persistent conversations
  - Agent-based workflows
  - Structured outputs (JSON schemas)
  - Advanced tools and orchestration
  - Event-based SSE streaming

  This architecture structures the entire API.

<br>

- **Persistent conversations:** Conversations are modeled as persistent server-side resources, enabling long-running interactions, multi-step reasoning, and asynchronous processing.

<br>

- **Agent-based workflows:** The wrapper supports agents capable of orchestrating tools, maintaining state, and driving complex execution chains.

<br>

- **Deep Research:** Support for deep research workflows, combining agents, persistent conversations, tools, and multi-step orchestration.

<br>

- **Structured outputs:** Responses can be produced in structured form (JSON schemas), suitable for data extraction and automation.

<br>

- **Orchestration and background execution:** Support for coordinating multi-step processing, including deferred and background execution.

<br>

- **Batch processing:** Support for batch processing to efficiently execute multiple requests.

<br>

- **Vectorization and search:** Support for:
  - embeddings
  - vector stores
  - vector search
  - fileSearch for vectorized documents and interactions

<br>

- **Image generation:** Native support for image generation using Imagen and Nano Banana models.

<br>

- **Video generation:** Support for video generation using Veo models.

<br>

- **Multimodal understanding:** Unified support for multimodal content:
  - text
  - images
  - audio
  - video
  - documents (PDF)

<br>

- **File management:** Full file management API:
  - upload
  - metadata retrieval
  - listing
  - deletion

<br>

- **Context caching:** Context caching support to optimize cost and performance when reusing recurring content.

<br>

- **Model discovery:** Access to available models, their metadata, and capabilities.

<br>

- **Fine-tuning:** Support for model fine-tuning, including creation, management, and usage of tuned models.

<br>

- **Grounding:** Support for grounding responses to improve factuality and traceability, including:
  - Grounding with Google Search
  - Grounding with Google Maps

<br>

- **Tools and code execution:** Support for code execution and tool usage within agentic and advanced reasoning workflows.

<br>

- **Functional coverage summary:** A consolidated overview of the wrapper’s capabilities is provided in the “Functional Coverage” section.
