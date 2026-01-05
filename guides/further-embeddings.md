# Embeddings

The **Gemini API** provides text **embedding** models that generate vector representations of *words, expressions, sentences*, and *code*. These representations form a fundamental basis for **advanced natural language processing (NLP)** tasks such as *semantic search*, *classification*, and *clustering*. Compared to traditional keyword-based approaches, they enable more accurate and context-aware results.

**Embeddings** also play a central role in the design of **Retrieval-Augmented Generation (RAG) systems**. In this context, they contribute significantly to improving model performance by enhancing factual accuracy, coherence, and contextual richness. Relevant information is efficiently retrieved from knowledge bases represented as **embeddings** and then incorporated as additional context into the input queries sent to language models, thereby guiding them toward the **generation of more relevant and precise responses**.

<br>

- [Embeddings Creation](#embeddings-creation)
- [Batch Embeddings Creation](#batch-embeddings-creation)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Embeddings Creation

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);
  

  //Asynchronous promise example
  var Promise := Client.Embeddings.AsyncAwaitCreate(ModelName,
    procedure (Params: TEmbeddingsParams)
    begin
      Params
        .Content(['Hello', 'how', 'are you?']);
      TutorialHub.JSONRequest := Params.ToFormat();
    end);

  Promise
    .&Then<TArray<TArray<Double>>>(
       function (Value: TEmbedding): TArray<TArray<Double>>
       begin
         Display(TutorialHub, Value);
       end)
    .&Catch(
       procedure (E: Exception)
       begin
         Display(TutorialHub, E.Message);
       end);


  //Synchronous example
//  var Value := Client.Embeddings.Create(ModelName,
//    procedure (Params: TEmbeddingsParams)
//    begin
//      Params
//        .Content(['Hello', 'how', 'are you?']);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Batch Embeddings Creation
