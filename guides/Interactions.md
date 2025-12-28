# Interactions


- [Introduction](#introduction)
- [Text generation](#text-generation)
  - [Non streamed](interactions-generation.md) 
  - [SSE Streaming](interactions-sse.md)


___

## Introduction
The **Gemini Interactions API** is an experimental API designed for building applications based on Gemini models. These models are natively multimodal and can process, combine, and generate information from multiple data types, including text, code, audio, images, and video.

The API supports a range of use cases such as joint text-and-image reasoning, content generation, conversational agents, and synthesis or classification pipelines. It provides a unified interface for accessing the multimodal reasoning and transformation capabilities of Gemini models.

<br>

## Text generation

This section describes text generation mechanisms using two execution modes: non-streamed and streamed, each available in both synchronous and asynchronous contexts.

This part is essential, as it goes beyond text generation itself and defines how requests are issued to Gemini models. In the remainder of this document, this approach will be used as a reference. However, for clarity and conciseness, only the JSON construction submitted to the model will be explicitly detailed.

For text content generation, refer to the following sections:
- [Non streamed](interactions-generation.md) 
- [SSE Streaming](interactions-sse.md)
