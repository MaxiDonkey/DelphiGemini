# Going Further

<br>

- [Model discovery](further-models.md#models)
  - The **models endpoint** allows you to programmatically *list available models* and *retrieve detailed metadata*, such as supported capabilities and context window size.

- [Embeddings](further-embeddings.md#embeddings)
  - The Gemini API provides **text embedding models** that generate vector representations of *words, expressions, sentences, and code*.  

- [File management](further-file-managment.md)
  - **Files** lets you upload multimodal files *(audio, images, video, documents, etc.)* and reuse them inside prompts sent to Gemini models.

- [Caching](further-caching.md#caching)
  - **Implicit Caching** and **Explicit Caching**: Definitions and Explicit Cache Management

- [Batch processing](further-batch.md#batch)
  - The **Batch API** is used to execute large volumes of non-urgent requests asynchronously, with a ***~50%*** cost reduction compared to the interactive API and a target completion time of ***≤24 hours***. 

- [Video generation (Veo)]()

- [Image generation (Imagen 4)]()

- [Vector stores](further-vector-store.md#vector-store)
  - The **File Search** tool of the Gemini API is a ***Retrieval Augmented Generation (RAG)*** mechanism that indexes documents as embeddings in order to provide relevant excerpts to the model during response generation.

- [Vectorized documents and fileSearch (Interactions)]()
  - **Documents** are the persistent, File Search–side representations of imported files, broken into chunks that semantic retrieval can use.