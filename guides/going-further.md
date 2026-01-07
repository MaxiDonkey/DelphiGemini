# Going Further

<br>

- [Tips and Tricks](#tips-and-tricks) 

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

- [Video generation (Veo)](further-video-veo.md#video-with-veo)
  - **Veo** supports the generation of short videos with synchronized audio from *textual, image-based, or video-based inputs*, with an emphasis on photorealistic rendering.

- [Image generation (Imagen 4)](further-imagen.md#imagen)
  - Imagen is a text-to-image generative model based on language-conditioned diffusion architectures.

- [Image generation (Nano Banana)](further-nano-banana.md)
  - **Nano Banana** refers to the set of image generation capabilities natively integrated into the *Gemini models*. 

- [Speech generation](further-speech-generation.md#speech-generation-text-to-speech)
  - The **Gemini TTS** is not a traditional parametric speech synthesis engine, but a language-driven voice rendering system designed for controlled audio production from fixed text.

- [Vector stores](further-vector-store.md#vector-store)
  - The **File Search** tool of the Gemini API is a ***Retrieval Augmented Generation (RAG)*** mechanism that indexes documents as embeddings in order to provide relevant excerpts to the model during response generation.

- [Vectorized documents and fileSearch (Interactions)](further-vector-store-document.md#vector-store-document)
  - **Documents** are the persistent, File Search–side representations of imported files, broken into chunks that semantic retrieval can use.

___

<br>

## Tips and Tricks

- [How to prevent an error when closing an application while requests are still in progress](#how-to-prevent-an-error-when-closing-an-application-while-requests-are-still-in-progress)

<br>

### How to prevent an error when closing an application while requests are still in progress

Starting from version 1.1.0 of **DelphiGemini**, the `Gemini.Monitoring` unit is responsible for monitoring ongoing HTTP requests.

The Monitoring interface is accessible by including the Gemini.Monitoring unit in the uses clause. Alternatively, you can access it via the HttpMonitoring function, declared in the `Gemini` unit.

#### Usage Exemple
```pascal
//uses Gemini;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not HttpMonitoring.IsBusy;
  if not CanClose then
    MessageDLG(
      'Requests are still in progress. Please wait for them to complete before closing the application."',
      TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
end;
```
