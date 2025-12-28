# Text generation (non-streamed interactions)

- [Overview](#overview)

___

<br>

## Overview

The `Client.Interactions.Create` and `Client.Interactions.AsyncAwaitCreate` methods request a Gemini model to generate a single, non-streamed response.

Unlike SSE streaming:
- the model produces its full output in one response,
- no intermediate chunks or events are emitted,
- the resulting `TInteraction` object contains the complete generated content.

<br>

Two usage styles are available:
- **Synchronous:** blocking call, immediate result.
- **Asynchronous (promise-based):** non-blocking, composable with &Then / &Catch.

<br>

>[!NOTE] **Tutorial support units**
>
