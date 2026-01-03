unit Gemini.Helpers;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Gemini.API.Params, Gemini.Types, Gemini.API.ArrayBuilder,
  Gemini.Chat.Request, Gemini.Chat.Request.Content, Gemini.Chat.Request.ToolConfig,
  Gemini.Chat.Request.GenerationConfig, Gemini.Chat.Request.Tools,
  Gemini.Embeddings, Gemini.Batch, Gemini.Interactions, Gemini.Interactions.Content,
  Gemini.Interactions.Tools, Gemini.Video, Gemini.ImageGen;

type

{$REGION 'Gemini.Chat.Request.Content'}

  TParts = TArrayBuilder<TPartParams>;

  TPartsHelper = record Helper for TParts
    /// <summary>
    /// Appends a text part to the builder, optionally marking it as model thought.
    /// </summary>
    /// <param name="Text">
    /// The textual content to append as a new part.
    /// </param>
    /// <param name="Thought">
    /// Optional. When <c>True</c>, marks the appended part with <c>thought = true</c>. When <c>False</c>,
    /// the part is treated as normal text content.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewText(Text, Thought)</c>.
    /// </para>
    /// </remarks>
    function AddText(const Text: string; Thought: Boolean = False): TParts;

    /// <summary>
    /// Appends an inline media part to the builder using Base64-encoded bytes and a MIME type.
    /// </summary>
    /// <param name="Base64">
    /// The media content encoded as a Base64 string (raw bytes of the media file).
    /// </param>
    /// <param name="MimeType">
    /// The IANA MIME type of the media (for example: <c>image/png</c>, <c>image/jpeg</c>, <c>application/pdf</c>).
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewInlineData(Base64, MimeType)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on the Base64 payload; ensure it is valid and matches <paramref name="MimeType"/>.
    /// </para>
    /// </remarks>
    function AddInlineData(const Base64: string; const MimeType: string): TParts; overload;

    /// <summary>
    /// Appends a URI-based media part to the builder by referencing the resource via <c>fileData</c>.
    /// </summary>
    /// <param name="Uri">
    /// The URI of the media resource to attach (for example, a remote URL or a provider-specific file URI).
    /// </param>
    /// <param name="MimeType">
    /// The IANA MIME type of the referenced media (for example: <c>image/png</c>, <c>image/jpeg</c>, <c>application/pdf</c>).
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewFileData(Uri, MimeType)</c>.
    /// </para>
    /// <para>
    /// • Ensure that <paramref name="MimeType"/> matches the content type of the resource referenced by
    /// <paramref name="Uri"/> to avoid API errors.
    /// </para>
    /// </remarks>
    function AddFileData(const Uri: string; const MimeType: string): TParts;

    /// <summary>
    /// Appends a function call part to the builder for the specified function name.
    /// </summary>
    /// <param name="Name">
    /// The name of the function to call. The name must be composed of <c>a-z</c>, <c>A-Z</c>, <c>0-9</c>,
    /// underscores, or dashes, with a maximum length of 64 characters.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewFunctionCall(Name)</c>.
    /// </para>
    /// <para>
    /// • No call id or arguments are provided. To include them, build a <c>TFunctionCallParams</c> and append it
    /// via <c>TPartParams.FunctionCall(...)</c>.
    /// </para>
    /// </remarks>
    function AddFunctionCall(const Name: string): TParts;

    /// <summary>
    /// Appends a function response part to the builder for the specified function name.
    /// </summary>
    /// <param name="Name">
    /// The name of the function this response corresponds to. The name must be composed of <c>a-z</c>, <c>A-Z</c>,
    /// <c>0-9</c>, underscores, or dashes, with a maximum length of 64 characters.
    /// </param>
    /// <param name="Response">
    /// The function result encoded as a JSON object. Callers may use any keys that match the function's expected
    /// schema (for example: <c>"output"</c>, <c>"result"</c>). If execution failed, the object may include an
    /// <c>"error"</c> key with details.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewFunctionResponse(Name, Response)</c>.
    /// </para>
    /// <para>
    /// • The <paramref name="Response"/> object is attached as-is; ensure it matches the function contract used by
    /// your tool/function declaration.
    /// </para>
    /// </remarks>
    function AddFunctionResponse(const Name: string; const Response: TJSONObject): TParts;

    /// <summary>
    /// Appends an executable code part to the builder.
    /// </summary>
    /// <param name="Language">
    /// The programming language of the code to be executed.
    /// </param>
    /// <param name="Code">
    /// The source code to be executed.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewExecutableCode(Language, Code)</c>.
    /// </para>
    /// <para>
    /// • The code is attached verbatim; no validation is performed on syntax or safety.
    /// </para>
    /// </remarks>
    function AddExecutableCode(const Language: TLanguageType; const Code: string): TParts; overload;

    /// <summary>
    /// Appends an executable code part to the builder.
    /// </summary>
    /// <param name="Language">
    /// The programming language of the code to be executed.
    /// </param>
    /// <param name="Code">
    /// The source code to be executed.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewExecutableCode(Language, Code)</c>.
    /// </para>
    /// <para>
    /// • The code is attached verbatim; no validation is performed on syntax or safety.
    /// </para>
    /// </remarks>
    function AddExecutableCode(const Language: string; const Code: string): TParts; overload;

    /// <summary>
    /// Appends a code execution result part to the builder with the specified outcome.
    /// </summary>
    /// <param name="Outcome">
    /// The outcome of the code execution (for example, success or failure) as defined by <c>TOutcomeType</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewCodeExecutionResult(Outcome)</c>.
    /// </para>
    /// <para>
    /// • Only the execution outcome is included; no output text (stdout/stderr) is attached.
    /// </para>
    /// </remarks>
    function AddCodeExecutionResult(const Outcome: TOutcomeType; const Output: string = ''): TParts; overload;

    /// <summary>
    /// Appends a code execution result part to the builder with the specified outcome.
    /// </summary>
    /// <param name="Outcome">
    /// The outcome of the code execution (for example, success or failure) as defined by <c>TOutcomeType</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TParts</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TPartParams</c> created via <c>TPartParams.NewCodeExecutionResult(Outcome)</c>.
    /// </para>
    /// <para>
    /// • Only the execution outcome is included; no output text (stdout/stderr) is attached.
    /// </para>
    /// </remarks>
    function AddCodeExecutionResult(const Outcome: string; const Output: string = ''): TParts; overload;
  end;

  TGenerationPart = record
    /// <summary>
    /// Creates a new parts builder for assembling generation parts.
    /// </summary>
    /// <returns>
    /// A new <c>TParts</c> builder instance, ready to receive <c>TPartParams</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TParts</c> builder (internally a <c>TArrayBuilder&lt;TPartParams&gt;</c>).
    /// </para>
    /// <para>
    /// • It is provided as a convenience entry point when only parts are needed, without
    /// creating a full <c>TGenerationContent</c> helper.
    /// </para>
    /// </remarks>
    class function Parts: TParts; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request'}

  TContent = TArrayBuilder<TContentPayload>;

  TContentHelper = record Helper for TContent
    /// <summary>
    /// Appends a content payload containing the specified text.
    /// </summary>
    /// <param name="Value">
    /// The text to include in the appended content payload.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TContentPayload</c> created via <c>TContentPayload.Add(Value)</c>.
    /// </para>
    /// <para>
    /// • The appended payload does not explicitly set a role; use <c>User</c>, <c>Assistant</c>, or <c>Model</c>
    /// when you need a role-specific message.
    /// </para>
    /// </remarks>
    function AddText(const Value: string): TContent; overload;

    /// <summary>
    /// Appends a content payload built from a preconstructed array of parts.
    /// </summary>
    /// <param name="Value">
    /// The array of <c>TPartParams</c> instances to include as the parts of the appended content payload.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TContentPayload</c> created via <c>TContentPayload.Add(Value)</c>.
    /// </para>
    /// <para>
    /// • The appended payload does not explicitly set a role; use <c>User</c>, <c>Assistant</c>, or <c>Model</c>
    /// when you need a role-specific message.
    /// </para>
    /// </remarks>
    function AddParts(const Value: TArray<TPartParams>): TContent;

    /// <summary>
    /// Appends a user message built from the specified parts builder.
    /// </summary>
    /// <param name="Parts">
    /// The <c>TParts</c> builder containing the parts that make up the user message.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • The parts accumulated in <paramref name="Parts"/> are converted to a
    /// <c>TArray&lt;TPartParams&gt;</c> and attached to a new <c>TContentPayload</c>
    /// with the role set to <c>user</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you need fine-grained control over the structure
    /// of the user message, such as mixing text, media, or function-related parts.
    /// </para>
    /// </remarks>
    function User(const Parts: TParts): TContent; overload;

    /// <summary>
    /// Appends a user message containing the specified text and optional attachments.
    /// </summary>
    /// <param name="Value">
    /// The text content of the user message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of file paths or URIs to attach as additional parts.
    /// Local paths are embedded as <c>inlineData</c>; URIs are referenced as <c>fileData</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TContentPayload</c> created via <c>TContentPayload.User(Value, Attached)</c>.
    /// </para>
    /// <para>
    /// • Attachments are converted into parts using <c>TAttachedManager.ToJson</c>, which selects <c>inlineData</c>
    /// or <c>fileData</c> depending on whether an item is a URI.
    /// </para>
    /// </remarks>
    function User(const Value: string; const Attached: TArray<string> = []): TContent; overload;

    /// <summary>
    /// Appends a user message consisting only of attachments.
    /// </summary>
    /// <param name="Attached">
    /// An array of file paths or URIs to attach as parts.
    /// Local paths are embedded as <c>inlineData</c>; URIs are referenced as <c>fileData</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TContentPayload</c> created via <c>TContentPayload.User(Attached)</c>.
    /// </para>
    /// <para>
    /// • Attachments are converted into parts using <c>TAttachedManager.ToJson</c>, which selects <c>inlineData</c>
    /// or <c>fileData</c> depending on whether an item is a URI.
    /// </para>
    /// </remarks>
    function User(const Attached: TArray<string>): TContent; overload;

    /// <summary>
    /// Appends an assistant (model) message built from the specified parts builder.
    /// </summary>
    /// <param name="Parts">
    /// The <c>TParts</c> builder containing the parts that make up the assistant/model message.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • The parts accumulated in <paramref name="Parts"/> are converted to a
    /// <c>TArray&lt;TPartParams&gt;</c> and attached to a new <c>TContentPayload</c>
    /// with the role set to <c>model</c>.
    /// </para>
    /// <para>
    /// • This method is functionally equivalent to <c>Model(const Parts: TParts)</c>. It is provided as an
    /// ergonomic alias since many APIs and developers use “assistant” to refer to what the Gemini API names “model”.
    /// </para>
    /// </remarks>
    function Assistant(const Parts: TParts): TContent; overload;

    /// <summary>
    /// Appends an assistant (model) message containing the specified text and optional attachments.
    /// </summary>
    /// <param name="Value">
    /// The text content of the assistant/model message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of file paths or URIs to attach as additional parts.
    /// Local paths are embedded as <c>inlineData</c>; URIs are referenced as <c>fileData</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TContentPayload</c> created via <c>TContentPayload.Assistant(Value, Attached)</c>.
    /// </para>
    /// <para>
    /// • Attachments are converted into parts using <c>TAttachedManager.ToJson</c>, which selects <c>inlineData</c>
    /// or <c>fileData</c> depending on whether an item is a URI.
    /// </para>
    /// <para>
    /// • This method is functionally equivalent to <c>Model(const Value: string; const Attached: TArray&lt;string&gt;)</c>.
    /// It is provided as an ergonomic alias since many APIs and developers use “assistant” to refer to what the
    /// Gemini API names “model”.
    /// </para>
    /// </remarks>
    function Assistant(const Value: string; const Attached: TArray<string> = []): TContent; overload;

    /// <summary>
    /// Appends a model message built from the specified parts builder.
    /// </summary>
    /// <param name="Parts">
    /// The <c>TParts</c> builder containing the parts that make up the model message.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • The parts accumulated in <paramref name="Parts"/> are converted to a
    /// <c>TArray&lt;TPartParams&gt;</c> and attached to a new <c>TContentPayload</c>
    /// with the role set to <c>model</c>.
    /// </para>
    /// <para>
    /// • This method is functionally equivalent to <c>Assistant(const Parts: TParts)</c>. It is provided to match
    /// the Gemini API role naming, where responses are attributed to the <c>model</c>.
    /// </para>
    /// </remarks>
    function Model(const Parts: TParts): TContent; overload;

    /// <summary>
    /// Appends a model message containing the specified text and optional attachments.
    /// </summary>
    /// <param name="Value">
    /// The text content of the model message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of file paths or URIs to attach as additional parts.
    /// Local paths are embedded as <c>inlineData</c>; URIs are referenced as <c>fileData</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TContent</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TContentPayload</c> created via <c>TContentPayload.Assistant(Value, Attached)</c>,
    /// which sets the role to <c>model</c>.
    /// </para>
    /// <para>
    /// • Attachments are converted into parts using <c>TAttachedManager.ToJson</c>, which selects <c>inlineData</c>
    /// or <c>fileData</c> depending on whether an item is a URI.
    /// </para>
    /// <para>
    /// • This method is functionally equivalent to <c>Assistant(const Value: string; const Attached: TArray&lt;string&gt;)</c>.
    /// It is provided to match the Gemini API role naming, where responses are attributed to the <c>model</c>.
    /// </para>
    /// </remarks>
    function Model(const Value: string; const Attached: TArray<string> = []): TContent; overload;
  end;

  /// <summary>
  /// Provides factory helpers for creating builders used to assemble generation request content.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • <c>TGenerationContent</c> groups constructors for the two primary builders used when composing chat payloads:
  /// <c>TContent</c> (messages) and <c>TParts</c> (message parts).
  /// </para>
  /// <para>
  /// • Use <c>Contents</c> to create a builder for <c>TContentPayload</c> messages, and <c>Parts</c> to create a builder
  /// for <c>TPartParams</c> items that can be attached to a message.
  /// </para>
  /// <para>
  /// • These helpers centralize builder creation to keep calling code compact and consistent.
  /// </para>
  /// </remarks>
  TGenerationContent = record
    /// <summary>
    /// Creates a new content builder for assembling generation request contents.
    /// </summary>
    /// <returns>
    /// A new <c>TContent</c> builder instance, ready to receive <c>TContentPayload</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TContent</c> builder (internally a <c>TArrayBuilder&lt;TContentPayload&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to append messages (user/model) and then pass the resulting
    /// <c>TArray&lt;TContentPayload&gt;</c> to <c>TChatParams.Contents(...)</c>.
    /// </para>
    /// </remarks>
    class function Contents: TContent; static;

    /// <summary>
    /// Creates a new parts builder for assembling message parts used in generation request contents.
    /// </summary>
    /// <returns>
    /// A new <c>TParts</c> builder instance, ready to receive <c>TPartParams</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TParts</c> builder (internally a <c>TArrayBuilder&lt;TPartParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to append parts (text, media, function calls, etc.) and then pass the resulting
    /// <c>TArray&lt;TPartParams&gt;</c> into content payload builders such as <c>TContentHelper.User(...)</c> or
    /// <c>TContentHelper.Model(...)</c>.
    /// </para>
    /// </remarks>
    class function Parts: TParts; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.GenerationConfig'}

  TSpeakerVoice = TArrayBuilder<TSpeakerVoiceConfig>;

  TSpeakerVoiceHelper = record Helper for TSpeakerVoice
    /// <summary>
    /// Appends a speaker voice configuration entry to the builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TSpeakerVoiceConfig</c> instance to append. A copy of its configuration is added to the builder.
    /// </param>
    /// <returns>
    /// The updated <c>TSpeakerVoice</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new item created via <c>TSpeakerVoiceConfig.New(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you already have a configured <c>TSpeakerVoiceConfig</c> instance.
    /// </para>
    /// </remarks>
    function AddItem(const Value: TSpeakerVoiceConfig): TSpeakerVoice; overload;

    /// <summary>
    /// Appends a speaker-to-voice mapping entry to the builder.
    /// </summary>
    /// <param name="Speaker">
    /// The speaker identifier used to label this voice in a multi-speaker context.
    /// </param>
    /// <param name="VoiceName">
    /// The identifier of the voice to associate with <paramref name="Speaker"/> (for example, a provider-specific voice name).
    /// </param>
    /// <returns>
    /// The updated <c>TSpeakerVoice</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new item created via <c>TSpeakerVoiceConfig.NewSpeakerVoiceConfig(Speaker, VoiceName)</c>.
    /// </para>
    /// <para>
    /// • Use this overload for concise construction when you only need to specify the speaker label and voice name.
    /// </para>
    /// </remarks>
    function AddItem(const Speaker: string; const VoiceName: string): TSpeakerVoice; overload;
  end;

  /// <summary>
  /// Provides factory helpers for creating speaker and voice configuration objects used in speech output.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • <c>TGenerationSpeaker</c> groups constructors for speech-related configuration blocks such as
  /// <c>TSpeakerVoiceConfig</c>, <c>TMultiSpeakerVoiceConfig</c>, and <c>TVoiceConfig</c>.
  /// </para>
  /// <para>
  /// • Use <c>Voices</c> to create a builder for speaker-to-voice mappings, and use the <c>AddXXX</c> methods
  /// to instantiate the corresponding configuration objects for single-voice or multi-speaker scenarios.
  /// </para>
  /// <para>
  /// • These helpers centralize object creation to keep calling code compact and consistent.
  /// </para>
  /// </remarks>
  TGenerationSpeaker = record
    /// <summary>
    /// Creates a new speaker voice builder for assembling multi-speaker voice mappings.
    /// </summary>
    /// <returns>
    /// A new <c>TSpeakerVoice</c> builder instance, ready to receive <c>TSpeakerVoiceConfig</c> items
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TSpeakerVoice</c> builder (internally a
    /// <c>TArrayBuilder&lt;TSpeakerVoiceConfig&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to append speaker/voice pairs and then pass the resulting
    /// array to the appropriate speech configuration (for example, a multi-speaker voice config).
    /// </para>
    /// </remarks>
    class function Voices: TSpeakerVoice; static;

    /// <summary>
    /// Creates a new <c>TSpeakerVoiceConfig</c> instance for mapping a speaker identifier to a voice.
    /// </summary>
    /// <returns>
    /// A new <c>TSpeakerVoiceConfig</c> instance, ready to be configured via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TSpeakerVoiceConfig.Create</c>.
    /// </para>
    /// <para>
    /// • Use this when you need to configure a speaker/voice entry explicitly before adding it to a
    /// <c>TSpeakerVoice</c> builder.
    /// </para>
    /// </remarks>
    class function AddSpeakerVoiceConfig: TSpeakerVoiceConfig; overload; static;

    /// <summary>
    /// Creates a new multi-speaker voice configuration instance.
    /// </summary>
    /// <returns>
    /// A new <c>TMultiSpeakerVoiceConfig</c> instance, ready to be configured via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TMultiSpeakerVoiceConfig.Create</c>.
    /// </para>
    /// <para>
    /// • Use this configuration to associate multiple speakers with their respective voices,
    /// typically in conjunction with a <c>TSpeakerVoice</c> builder created via <c>Voices</c>.
    /// </para>
    /// </remarks>
    class function AddMultiSpeakerVoiceConfig: TMultiSpeakerVoiceConfig; overload; static;

    /// <summary>
    /// Creates a new voice configuration for a single voice.
    /// </summary>
    /// <param name="VoiceName">
    /// The identifier of the voice to use (for example, a provider-specific voice name).
    /// </param>
    /// <returns>
    /// A new <c>TVoiceConfig</c> instance configured with the specified voice name.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that creates a <c>TVoiceConfig</c> via
    /// <c>TVoiceConfig.NewVoiceConfig(VoiceName)</c>.
    /// </para>
    /// <para>
    /// • Use this when configuring speech output that requires a single, global voice
    /// rather than per-speaker mappings.
    /// </para>
    /// </remarks>
    class function AddVoiceConfig(const VoiceName: string): TVoiceConfig; overload; static;
  end;

  /// <summary>
  /// Provides factory helpers for creating configuration objects used in generation requests.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • <c>TGenerationConfiguration</c> groups constructors for configuration blocks such as
  /// <c>TGenerationConfig</c>, <c>TImageConfig</c>, <c>TSpeechConfig</c>, and <c>TThinkingConfig</c>.
  /// </para>
  /// <para>
  /// • Each <c>AddXXX</c> method returns a newly created configuration instance that can be customized
  /// through the fluent API and then attached to a request (for example via <c>TChatParams.GenerationConfig(...)</c>).
  /// </para>
  /// <para>
  /// • These helpers centralize object creation to keep calling code consistent and readable.
  /// </para>
  /// </remarks>
  TGenerationConfiguration = record
    /// <summary>
    /// Creates a new <c>TGenerationConfig</c> instance for configuring model generation options.
    /// </summary>
    /// <returns>
    /// A new <c>TGenerationConfig</c> instance, ready to be configured via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TGenerationConfig.Create</c>.
    /// </para>
    /// <para>
    /// • Use this configuration to set generation parameters such as token limits, sampling controls,
    /// output constraints, and other model-specific options.
    /// </para>
    /// </remarks>
    class function AddGenerationConfig:TGenerationConfig; static;

    /// <summary>
    /// Creates a new <c>TImageConfig</c> instance for configuring image generation options.
    /// </summary>
    /// <returns>
    /// A new <c>TImageConfig</c> instance, ready to be configured via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TImageConfig.Create</c>.
    /// </para>
    /// <para>
    /// • Use this configuration to control image-specific generation parameters such as size,
    /// quality, style, or other image-related options supported by the model.
    /// </para>
    /// </remarks>
    class function AddImageConfig:TImageConfig; static;

    /// <summary>
    /// Creates a new <c>TSpeechConfig</c> instance for configuring speech synthesis options.
    /// </summary>
    /// <returns>
    /// A new <c>TSpeechConfig</c> instance, ready to be configured via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TSpeechConfig.Create</c>.
    /// </para>
    /// <para>
    /// • Use this configuration to control speech-related parameters such as voice selection,
    /// audio format, speaking rate, pitch, and other speech synthesis options supported by the model.
    /// </para>
    /// </remarks>
    class function AddSpeechConfig: TSpeechConfig; overload; static;

    /// <summary>
    /// Creates a new <c>TThinkingConfig</c> instance for configuring model thinking behavior.
    /// </summary>
    /// <returns>
    /// A new <c>TThinkingConfig</c> instance, ready to be configured via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TThinkingConfig.Create</c>.
    /// </para>
    /// <para>
    /// • Use this configuration to control thinking-related options (for example, thinking level),
    /// when supported by the selected model.
    /// </para>
    /// </remarks>
    class function AddThinkingConfig: TThinkingConfig; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.ToolConfig'}

  /// <summary>
  /// Provides factory helpers for creating tool configuration objects used in chat requests.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • <c>TGenerationToolConfig</c> groups constructors for tool configuration blocks such as
  /// <c>TToolConfig</c>, <c>TRetrievalConfig</c>, <c>TLatLng</c>, and <c>TFunctionCallingConfig</c>.
  /// </para>
  /// <para>
  /// • Use these helpers to build the <c>toolConfig</c> section of a request, including function calling behavior
  /// (mode and allowed functions) and retrieval settings (language and optional user location).
  /// </para>
  /// <para>
  /// • These helpers centralize object creation to keep calling code compact and consistent.
  /// </para>
  /// </remarks>
  TGenerationToolConfig = record
    /// <summary>
    /// Creates a new <c>TToolConfig</c> instance for configuring tool-related behavior in a chat request.
    /// </summary>
    /// <returns>
    /// A new <c>TToolConfig</c> instance, ready to be configured and attached to a generation request.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to configure global tool settings such as function calling behavior
    /// (<c>FunctionCallingConfig</c>) and retrieval options (<c>RetrievalConfig</c>).
    /// </para>
    /// <para>
    /// • The returned instance is empty by default and must be populated explicitly.
    /// </para>
    /// <para>
    /// • This method is typically used in conjunction with <c>TChatParams.ToolConfig</c>.
    /// </para>
    /// </remarks>
    class function AddToolConfig: TToolConfig; static;

    /// <summary>
    /// Creates a new <c>TRetrievalConfig</c> instance for configuring retrieval-related settings.
    /// </summary>
    /// <returns>
    /// A new <c>TRetrievalConfig</c> instance, ready to be configured and attached to a tool configuration.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to specify retrieval context such as the user's language
    /// (<c>LanguageCode</c>) and optional geographic location (<c>LatLng</c>).
    /// </para>
    /// <para>
    /// • The returned instance is empty by default and must be populated explicitly.
    /// </para>
    /// <para>
    /// • This method is typically used as part of a <c>TToolConfig</c> via
    /// <c>TGenerationToolConfig.AddToolConfig</c>.
    /// </para>
    /// </remarks>
    class function AddRetrievalConfig: TRetrievalConfig; static;

    /// <summary>
    /// Creates a new <c>TLatLng</c> instance representing a geographic coordinate.
    /// </summary>
    /// <param name="Latitude">
    /// The latitude in degrees. Valid range is from <c>-90.0</c> to <c>+90.0</c>.
    /// </param>
    /// <param name="Longitude">
    /// The longitude in degrees. Valid range is from <c>-180.0</c> to <c>+180.0</c>.
    /// </param>
    /// <returns>
    /// A new <c>TLatLng</c> instance initialized with the specified latitude and longitude.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to conveniently create a location object for retrieval or tool configuration.
    /// </para>
    /// <para>
    /// • The returned instance can be attached to a <c>TRetrievalConfig</c> via <c>LatLng(...)</c>.
    /// </para>
    /// </remarks>
    class function AddLatLng(const Latitude, Longitude: Double): TLatLng; static;

    /// <summary>
    /// Creates a new <c>TFunctionCallingConfig</c> instance for configuring function calling behavior.
    /// </summary>
    /// <returns>
    /// A new <c>TFunctionCallingConfig</c> instance, ready to be configured and attached to a tool configuration.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to control how the model performs function calling, such as selecting the calling mode
    /// (<c>AUTO</c>, <c>ANY</c>, or <c>VALIDATED</c>) and restricting callable functions.
    /// </para>
    /// <para>
    /// • The returned instance is empty by default and must be populated explicitly using
    /// <c>Mode</c> and/or <c>AllowedFunctionNames</c>.
    /// </para>
    /// <para>
    /// • This method is typically attached to a <c>TToolConfig</c> via <c>FunctionCallingConfig(...)</c>.
    /// </para>
    /// </remarks>
    class function AddFunctionCallingConfig: TFunctionCallingConfig; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.Tools'}

  TFunction = TArrayBuilder<TFunctionDeclarations>;

  TFunctionHelper = record Helper for TFunction
    /// <summary>
    /// Appends a function declaration to the builder.
    /// </summary>
    /// <param name="Name">
    /// The name of the function to declare. The name must be composed of
    /// <c>a-z</c>, <c>A-Z</c>, <c>0-9</c>, underscores, or dashes, with a maximum
    /// length of 64 characters.
    /// </param>
    /// <param name="Description">
    /// A human-readable description of the function’s purpose and behavior.
    /// This text is used by the model to decide when and how to call the function.
    /// </param>
    /// <returns>
    /// The updated <c>TFunction</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TFunctionDeclarations</c> instance created via
    /// <c>TFunctionDeclarations.NewFunction(Name, Description)</c>.
    /// </para>
    /// <para>
    /// • Use this helper to register functions that the model may invoke through
    /// function calling.
    /// </para>
    /// <para>
    /// • The declared function should later be associated with a tool configuration
    /// and included in the request via <c>TChatParams.Tools(...)</c>.
    /// </para>
    /// </remarks>
    function AddFunction(const Name: string; const Description: string): TFunction;
  end;

  TTools = TArrayBuilder<TToolParams>;

  TToolsHelper = record Helper for TTools
    /// <summary>
    /// Creates a tools builder initialized with the specified function declarations.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TFunctionDeclarations</c> describing the functions that can be called by the model.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the provided function declarations.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps the given <paramref name="Value"/> into a <c>functionDeclarations</c> tool entry
    /// using <c>TToolParams.NewFunctionDeclarations</c>.
    /// </para>
    /// <para>
    /// • Use this method when you already have a complete set of function declarations and want to
    /// attach them directly to the <c>tools</c> section of a generation request.
    /// </para>
    /// <para>
    /// • The resulting builder is typically passed to <c>TChatParams.Tools(...)</c>.
    /// </para>
    /// </remarks>
    function AddFunctionDeclarations(const Value: TArray<TFunctionDeclarations>): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a Google Search Retrieval tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TGoogleSearchRetrieval</c> configuration instance describing how web search
    /// retrieval should be performed.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the Google Search Retrieval tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>googleSearchRetrieval</c> tool entry
    /// using <c>TToolParams.NewGoogleSearchRetrieval</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable retrieval-augmented generation based on Google Search results.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    function AddGoogleSearchRetrieval(const Value: TGoogleSearchRetrieval): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a code execution tool configuration.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TCodeExecution</c> configuration instance describing how code execution
    /// should be performed. If <c>nil</c>, a default code execution configuration is used.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the code execution tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> (or a default instance when <c>nil</c>) into
    /// a <c>codeExecution</c> tool entry using <c>TToolParams.NewCodeExecution</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable model-driven code execution during generation.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    function AddCodeExecution(const Value: TCodeExecution = nil): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a Google Search tool configuration.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TGoogleSearch</c> configuration instance describing how Google Search
    /// should be performed. If <c>nil</c>, a default Google Search configuration is used.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the Google Search tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> (or a default instance when <c>nil</c>) into
    /// a <c>googleSearch</c> tool entry using <c>TToolParams.NewGoogleSearch</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable direct Google Search access for the model during generation.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    function AddGoogleSearch(const Value: TGoogleSearch = nil): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a URL context tool configuration.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TUrlContext</c> configuration instance describing how
    /// external URL context should be provided to the model. If <c>nil</c>,
    /// a default URL context configuration is used.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the URL context tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> (or a default instance when <c>nil</c>)
    /// into a <c>urlContext</c> tool entry using <c>TToolParams.NewUrlContext</c>.
    /// </para>
    /// <para>
    /// • Use this method to provide the model with additional context fetched
    /// from external URLs during generation.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c>
    /// as part of a generation request.
    /// </para>
    /// </remarks>
    function AddUrlContext(const Value: TUrlContext = nil): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a computer use tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TComputerUse</c> configuration instance describing how the model
    /// can interact with a virtual computer environment.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the computer use tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>computerUse</c> tool entry
    /// using <c>TToolParams.NewComputerUse</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable computer interaction capabilities, such as UI automation
    /// or environment control, when supported by the selected model.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    function AddComputerUse(const Value: TComputerUse): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a file search tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TFileSearch</c> configuration instance describing how file search
    /// should be performed.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the file search tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>fileSearch</c> tool entry
    /// using <c>TToolParams.NewFileSearch</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable searching over indexed or provided files
    /// as part of a generation request.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c>
    /// to activate file search capabilities.
    /// </para>
    /// </remarks>
    function AddFileSearch(const Value: TFileSearch): TTools;

    /// <summary>
    /// Creates a tools builder initialized with a Google Maps tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TGoogleMaps</c> configuration instance describing how Google Maps
    /// functionality should be used by the model.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the Google Maps tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>googleMaps</c> tool entry
    /// using <c>TToolParams.NewGoogleMaps</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable map-related capabilities such as geocoding,
    /// routing, or place lookup when supported by the model.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c>
    /// to activate Google Maps integration for the request.
    /// </para>
    /// </remarks>
    function AddGoogleMaps(const Value: TGoogleMaps = nil): TTools;
  end;

  /// <summary>
  /// Provides factory helpers for creating and assembling tool declarations
  /// used in Gemini generation and chat requests.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • <c>TGenerationTool</c> centralizes entry points for building the <c>tools</c>
  /// section of a request, which enables the model to call user-defined functions
  /// or invoke built-in tools such as search, code execution, file search, maps,
  /// URL context, or computer use.
  /// </para>
  /// <para>
  /// • The record exposes builder creators for aggregating tool declarations
  /// (<c>Tools</c>) and function declarations (<c>Functions</c>), as well as a set
  /// of convenience factory methods (<c>AddXXX</c>) that directly append specific
  /// tool configurations.
  /// </para>
  /// <para>
  /// • These helpers are designed to minimize boilerplate by returning fluent
  /// builders or freshly created configuration objects that can be chained
  /// declaratively.
  /// </para>
  /// <para>
  /// • Most methods return lightweight helper records (via <c>Default(...)</c>)
  /// and do not allocate objects, except for methods that explicitly create
  /// concrete tool configuration instances.
  /// </para>
  /// <para>
  /// • Typical usage is to start from <c>TGeneration.Tools</c>, add one or more
  /// tool entries using the provided helpers, and then pass the resulting
  /// <c>TArray&lt;TToolParams&gt;</c> to <c>TChatParams.Tools(...)</c>.
  /// </para>
  /// </remarks>
  TGenerationTool = record
    /// <summary>
    /// Creates a new tools builder for assembling the <c>tools</c> section of a generation request.
    /// </summary>
    /// <returns>
    /// A new <c>TTools</c> builder instance, ready to receive <c>TToolParams</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TTools</c> builder (internally a
    /// <c>TArrayBuilder&lt;TToolParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to declare tools such as function declarations,
    /// Google Search, code execution, URL context, file search, or other built-in tools
    /// supported by the Gemini API.
    /// </para>
    /// <para>
    /// • The resulting array is typically passed to <c>TChatParams.Tools(...)</c>
    /// to enable tool usage during generation.
    /// </para>
    /// </remarks>
    class function Tools: TTools; static;

    /// <summary>
    /// Creates a new function declarations builder for assembling callable functions.
    /// </summary>
    /// <returns>
    /// A new <c>TFunction</c> builder instance, ready to receive <c>TFunctionDeclarations</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TFunction</c> builder (internally a
    /// <c>TArrayBuilder&lt;TFunctionDeclarations&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to declare functions that the model is allowed to call,
    /// including their names, descriptions, and parameter schemas.
    /// </para>
    /// <para>
    /// • The resulting array is typically passed to <c>TToolParams.NewFunctionDeclarations(...)</c>
    /// or attached to a <c>TTools</c> builder to enable function calling during generation.
    /// </para>
    /// </remarks>
    class function Functions: TFunction; static;

    /// <summary>
    /// Creates a tools builder initialized with the specified function declarations.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TFunctionDeclarations</c> describing the functions that can be called by the model.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the provided function declarations.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps the given <paramref name="Value"/> into a <c>functionDeclarations</c> tool entry
    /// using <c>TToolParams.NewFunctionDeclarations</c>.
    /// </para>
    /// <para>
    /// • Use this method when you already have a complete set of function declarations and want to
    /// attach them directly to the <c>tools</c> section of a generation request.
    /// </para>
    /// <para>
    /// • The resulting builder is typically passed to <c>TChatParams.Tools(...)</c>.
    /// </para>
    /// </remarks>
    class function AddFunctionDeclarations(const Value: TArray<TFunctionDeclarations>): TTools; static;
    class function AddFunction: TFunctionDeclarations; static;

    /// <summary>
    /// Creates a tools builder initialized with a Google Search Retrieval tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TGoogleSearchRetrieval</c> configuration instance describing how web search
    /// retrieval should be performed.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the Google Search Retrieval tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>googleSearchRetrieval</c> tool entry
    /// using <c>TToolParams.NewGoogleSearchRetrieval</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable retrieval-augmented generation based on Google Search results.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    class function AddGoogleSearchRetrieval(const Value: TGoogleSearchRetrieval): TTools; static;
    class function GoogleSearchRetrieval: TGoogleSearchRetrieval; static;

    /// <summary>
    /// Creates a tools builder initialized with a Google Search tool configuration.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TGoogleSearch</c> configuration instance describing how Google Search
    /// should be performed. If <c>nil</c>, a default Google Search configuration is used.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the Google Search tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> (or a default instance when <c>nil</c>) into
    /// a <c>googleSearch</c> tool entry using <c>TToolParams.NewGoogleSearch</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable direct Google Search access for the model during generation.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    class function AddGoogleSearch(const Value: TGoogleSearch = nil): TTools; static;
    class function GoogleSearch: TGoogleSearch; static;

    /// <summary>
    /// Creates a tools builder initialized with a code execution tool configuration.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TCodeExecution</c> configuration instance describing how code execution
    /// should be performed. If <c>nil</c>, a default code execution configuration is used.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the code execution tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> (or a default instance when <c>nil</c>) into
    /// a <c>codeExecution</c> tool entry using <c>TToolParams.NewCodeExecution</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable model-driven code execution during generation.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    class function AddCodeExecution(const Value: TCodeExecution = nil): TTools; static;
    class function CodeExecution: TCodeExecution; static;

    /// <summary>
    /// Creates a tools builder initialized with a computer use tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TComputerUse</c> configuration instance describing how the model
    /// can interact with a virtual computer environment.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the computer use tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>computerUse</c> tool entry
    /// using <c>TToolParams.NewComputerUse</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable computer interaction capabilities, such as UI automation
    /// or environment control, when supported by the selected model.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c> as part of a
    /// generation request.
    /// </para>
    /// </remarks>
    class function AddComputerUse(const Value: TComputerUse): TTools; static;
    class function ComputerUse: TComputerUse; static;

    /// <summary>
    /// Creates a tools builder initialized with a URL context tool configuration.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TUrlContext</c> configuration instance describing how
    /// external URL context should be provided to the model. If <c>nil</c>,
    /// a default URL context configuration is used.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the URL context tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> (or a default instance when <c>nil</c>)
    /// into a <c>urlContext</c> tool entry using <c>TToolParams.NewUrlContext</c>.
    /// </para>
    /// <para>
    /// • Use this method to provide the model with additional context fetched
    /// from external URLs during generation.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c>
    /// as part of a generation request.
    /// </para>
    /// </remarks>
    class function AddUrlContext(const Value: TUrlContext = nil): TTools; static;
    class function UrlContext: TUrlContext; static;

    /// <summary>
    /// Creates a tools builder initialized with a file search tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TFileSearch</c> configuration instance describing how file search
    /// should be performed.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the file search tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>fileSearch</c> tool entry
    /// using <c>TToolParams.NewFileSearch</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable searching over indexed or provided files
    /// as part of a generation request.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c>
    /// to activate file search capabilities.
    /// </para>
    /// </remarks>
    class function AddFileSearch(const Value: TFileSearch): TTools; static;
    class function FileSearch: TFileSearch; static;

    /// <summary>
    /// Creates a tools builder initialized with a Google Maps tool configuration.
    /// </summary>
    /// <param name="Value">
    /// The <c>TGoogleMaps</c> configuration instance describing how Google Maps
    /// functionality should be used by the model.
    /// </param>
    /// <returns>
    /// A new <c>TTools</c> builder instance containing the Google Maps tool.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper wraps <paramref name="Value"/> into a <c>googleMaps</c> tool entry
    /// using <c>TToolParams.NewGoogleMaps</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable map-related capabilities such as geocoding,
    /// routing, or place lookup when supported by the model.
    /// </para>
    /// <para>
    /// • The returned builder is typically passed to <c>TChatParams.Tools(...)</c>
    /// to activate Google Maps integration for the request.
    /// </para>
    /// </remarks>
    class function AddGoogleMaps(const Value: TGoogleMaps = nil): TTools; static;
    class function GoogleMaps: TGoogleMaps; static;

    class function DynamicRetrievalConfig: TDynamicRetrievalConfig; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Embeddings'}
  TBatchEmbeddings = TArrayBuilder<TEmbedContentParams>;

  TBatchEmbeddingsHelper = record Helper for TBatchEmbeddings
    function AddItem(const Model: string; const Content: TArray<string>): TBatchEmbeddings; overload;
    function AddItem(const Model: string; const Content: TContentPayload): TBatchEmbeddings; overload;
  end;

  TEmbeddingsBatch = record
    class function Contents: TBatchEmbeddings; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Batch'}

  TInlineRequest = TArrayBuilder<TInlinedRequestParams>;

  TInlineRequestHelper = record Helper for TInlineRequest
    function AddItem(const Value: TGenerateContentRequestParams): TInlineRequest; overload;
    function AddItem(const Key: string; const Value: TGenerateContentRequestParams): TInlineRequest; overload;
  end;

  TBatchContent = record
    class function Requests: TInlineRequest; static;
    class function AddInputConfig: TInputConfigParams; static;
    class function AddRequest: TInlinedRequestsParams; static;
    class function AddRequestContent: TGenerateContentRequestParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Content'}

  TThoughtSummary = TArrayBuilder<TThoughtSummaryIxParams>;

  TThoughtSummaryHelper = record Helper for TThoughtSummary
    function AddText(const Value: string): TThoughtSummary;
  end;

  TInteractionThought = record
    class function Summaries: TThoughtSummary; static;
  end;

  TGoogleSearchResult = TArrayBuilder<TGoogleSearchResultIxParams>;

  TGoogleSearchResultHelper = record Helper for TGoogleSearchResult
    function AddItem: TGoogleSearchResult;
  end;

  TInteractionGoogleSearch = record
    class function Results: TGoogleSearchResult; static;
  end;

  TFileSearchResult = TArrayBuilder<TFileSearchResultIxParams>;

  TFileSearchResultHelper = record Helper for TFileSearchResult
    function AddItem(const Value: TFileSearchResultIxParams): TFileSearchResult; overload;
  end;

  TInteractionFileSearch = record
    class function Results: TFileSearchResult; static;
    class function AddSearchResult: TFileSearchResultIxParams; static;
  end;

  TUrlContextResult = TArrayBuilder<TUrlContextResultIxParams>;

  TUrlContextResultHelper = record Helper for TUrlContextResult
    function AddItem(const Value: TUrlContextResultIxParams): TUrlContextResult;
  end;

  TInteractionUrlContext = record
    class function Results: TUrlContextResult; static;
    class function AddUrlContext: TUrlContextResultIxParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Tools'}

  TToolIx = TArrayBuilder<TToolIxParams>;

  TToolIxHelper = record Helper for TToolIx
    function AddFunction(const Value: TFunctionIxParams): TToolIx;
    function AddGoogleSearch(const Value: TGoogleSearchIxParams = nil): TToolIx;
    function AddCodeExecution(const Value: TCodeExecutionIxParams = nil): TToolIx;
    function AddUrlContext(const Value: TUrlContextIxParams = nil): TToolIx;
    function AddComputerUse(const Value: TComputerUseIxParams): TToolIx;
    function AddMcpServer(const Value: TMcpServerIxParams): TToolIx;
    function AddFileSearch(const Value: TFileSearchIxParams): TToolIx;
  end;

  TInteractionTool = record
    class function Tools: TToolIx; static;
    class function AddFunction: TFunctionIxParams; static;
    class function AddGoogleSearch: TGoogleSearchIxParams; static;
    class function AddCodeExecution: TCodeExecutionIxParams; static;
    class function AddUrlContext: TUrlContextIxParams; static;
    class function AddComputerUse: TComputerUseIxParams; static;
    class function AddMcpServer: TMcpServerIxParams; static;
    class function AddFileSearch: TFileSearchIxParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Content'}

  TTurn = TArrayBuilder<TTurnParams>;

  TInputContentHelper = record Helper for TTurn
    function AddUser(const Value: string): TTurn; overload;
    function AddUser(const Content: TArray<TInputParams>): TTurn; overload;
    function AddAssistant(const Value: string): TTurn;
    function AddModel(const Value: string): TTurn;
  end;

  TInteractionTurn = record
    class function Turns: TTurn; static;
  end;

  TInput = TArrayBuilder<TInputParams>;

  TInputHelper = record Helper for TInput
    function AddText(const Value: string): TInput;
    function AddAudio(const Data64: string; const MimeType: string): TInput; overload;
    function AddAudio(const Uri: string): TInput; overload;
    function AddAudio(const Value: TAudioContentIxParams): TInput; overload;

    function AddDocument(const Data64: string; const MimeType: string): TInput; overload;
    function AddDocument(const Uri: string): TInput; overload;
    function AddDocument(const Value: TDocumentContentIxParams): TInput; overload;

    function AddImage(const Data64: string; const MimeType: string): TInput; overload;
    function AddImage(const Uri: string): TInput; overload;
    function AddImage(const Value: TImageContentIxParams): TInput; overload;

    function AddVideo(const Data64: string; const MimeType: string): TInput; overload;
    function AddVideo(const Uri: string): TInput; overload;
    function AddVideo(const Value: TVideoContentIxParams): TInput; overload;

    function AddFileSearchResult(const Value: TFileSearchResultContentIxParams): TInput; overload;
    function AddFileSearchResult(const AResult: TArray<TFileSearchResultIxParams>): TInput; overload;

    function AddFunctionCall(const Name, Id: string; const Arguments: TJSONObject): TInput; overload;
    function AddFunctionCall(const Name, Id: string; const Arguments: string): TInput; overload;

    function AddFunctionResult(const AResult: string; const Name, CallId: string): TInput; overload;
    function AddFunctionResult(const AResult: TJSONObject; const Name, CallId: string): TInput; overload;

    function AddRaw(const Value: TContentIxParams): TInput;
  end;

  TInteractionInput = record
    class function Inputs: TInput; static;
    class function AddInput: TInputParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Video'}

  TVideoInstance = TArrayBuilder<TVideoInstanceParams>;

  TInstanceHelper = record Helper for TVideoInstance
    function AddItem(const Value: TVideoInstanceParams): TVideoInstance;
  end;

  TReference = TArrayBuilder<TReferenceImages>;

  TReferenceHelper = record Helper for TReference
    function AddItem(const Image: TImageInstanceParams; ReferenceType: string = ''): TReference;
  end;

  TVideoMedia = record
    class function Instances: TVideoInstance; static;
    class function AddInstance: TVideoInstanceParams; static;
    class function References: TReference; static;
    class function Base64(const Value64: string; const MimeType: string): TImageInstanceParams; static;
    class function Uri(const Uri: string; const MimeType: string): TImageInstanceParams; static;
    class function MaskBase64(const Value64: string; const MimeType: string; const MaskMode: string): TImageInstanceParams; static;
    class function MaskUri(const Uri: string; const MimeType: string; const MaskMode: string): TImageInstanceParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.ImageGen'}

  TImageGenInstance = TArrayBuilder<TImageGenInstanceParams>;

  TImageGenInstanceHelper = record Helper for TImageGenInstance
    function AddItem(const Value: TImageGenInstanceParams): TImageGenInstance;
  end;

  TImageGenMedia = record
    class function Instances: TImageGenInstance; static;
    class function Prompt(const Value: string): TImageGenInstanceParams; static;
  end;

{$ENDREGION}

  /// <summary>
  /// Provides a consolidated set of fluent factory helpers for constructing Gemini request payloads.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • <c>TGeneration</c> is an entry point that groups builders and configuration helpers used to assemble
  /// chat/generation requests (contents, parts, tools, tool configuration, and speaker/voice configuration).
  /// </para>
  /// <para>
  /// • The helpers are designed to keep calling code declarative and compact by returning builder records
  /// (for example <c>TContent</c> and <c>TParts</c>) and configuration objects (for example <c>TGenerationConfig</c>)
  /// that can be chained fluently.
  /// </para>
  /// <para>
  /// • Most methods return lightweight helper records (via <c>Default(...)</c>) and do not allocate objects,
  /// except for methods explicitly creating configuration instances (for example <c>AddConfig</c>).
  /// </para>
  /// <para>
  /// • Typical usage is to start from <c>TGeneration</c> to create builders, populate them with <c>AddXXX</c>
  /// methods, and then pass the resulting arrays/configurations into request parameter objects such as
  /// <c>TChatParams</c>.
  /// </para>
  /// </remarks>
  TGeneration = record
    /// <summary>
    /// Creates a new <c>TGenerationConfig</c> instance to configure generation parameters for a request.
    /// </summary>
    /// <returns>
    /// A new <c>TGenerationConfig</c> instance, ready to be configured via the fluent API
    /// (for example: max output tokens, temperature, thinking configuration, and related options).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TGenerationConfig.Create</c>.
    /// </para>
    /// <para>
    /// • The returned instance can be passed to <c>TChatParams.GenerationConfig(...)</c> (or equivalent)
    /// to apply generation settings to the request.
    /// </para>
    /// </remarks>
    class function AddConfig: TGenerationConfig; static;

    /// <summary>
    /// Provides access to generation configuration helper methods.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationConfiguration</c> helper record exposing factory methods for
    /// creating generation-related configuration objects.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method returns a default <c>TGenerationConfiguration</c> value and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use the returned helper to create configuration blocks such as generation, image, speech,
    /// or thinking configurations via its <c>AddXXX</c> methods.
    /// </para>
    /// </remarks>
    class function Config: TGenerationConfiguration; static;

    /// <summary>
    /// Provides access to content helper methods for building generation payloads.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationContent</c> helper record exposing factory methods for
    /// creating content and parts builders used in generation requests.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method returns a default <c>TGenerationContent</c> value and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use the returned helper to create content builders via <c>Contents</c> and
    /// part builders via <c>Parts</c>, enabling fluent construction of request payloads.
    /// </para>
    /// </remarks>
    class function Content: TGenerationContent; static;

    /// <summary>
    /// Creates a new content builder for assembling generation request contents.
    /// </summary>
    /// <returns>
    /// A new <c>TContent</c> builder instance, ready to receive content payloads
    /// (user, assistant, or model messages) via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience shortcut for <c>TGeneration.Content.Contents</c>.
    /// </para>
    /// <para>
    /// • The returned builder can be populated using methods such as <c>AddText</c>,
    /// <c>User</c>, <c>Assistant</c>, or <c>Model</c>, and is typically passed to
    /// <c>TChatParams.Contents(...)</c>.
    /// </para>
    /// </remarks>
    class function Contents: TContent; static;

    /// <summary>
    /// Creates a new parts builder for assembling content parts used in generation requests.
    /// </summary>
    /// <returns>
    /// A new <c>TParts</c> builder instance, ready to receive <c>TPartParams</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience shortcut for <c>TGeneration.Content.Parts</c>.
    /// </para>
    /// <para>
    /// • The returned builder can be populated using methods such as <c>AddText</c>,
    /// <c>AddInlineData</c>, <c>AddFileData</c>, <c>AddFunctionCall</c>, and related helpers.
    /// </para>
    /// </remarks>
    class function Parts: TParts; static;

    /// <summary>
    /// Provides access to tool helper methods for building the <c>tools</c> section of a request.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationTool</c> helper record exposing factory methods for creating tool builders
    /// and tool-related configuration objects (for example, function declarations and built-in tools).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method returns a default <c>TGenerationTool</c> value and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use the returned helper to create tool arrays via <c>Tools</c> / <c>Functions</c> and to instantiate
    /// individual tool configurations via its <c>AddXXX</c> methods.
    /// </para>
    /// </remarks>
    class function Tools: TGenerationTool; static;

    /// <summary>
    /// Provides access to speaker/voice helper methods for building speech-related configuration.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationSpeaker</c> helper record exposing factory methods for creating speaker and voice
    /// configuration objects (for example, voice configs and multi-speaker mappings).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method returns a default <c>TGenerationSpeaker</c> value and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use the returned helper to create speaker voice arrays via <c>Voices</c> and to instantiate
    /// voice configuration blocks via its <c>AddXXX</c> methods.
    /// </para>
    /// </remarks>
    class function Speaker: TGenerationSpeaker; static;

    /// <summary>
    /// Provides access to tool configuration helper methods for building <c>TToolConfig</c> payloads.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationToolConfig</c> helper record exposing factory methods for creating tool configuration
    /// objects (for example, function calling and retrieval configuration blocks).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method returns a default <c>TGenerationToolConfig</c> value and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use the returned helper to instantiate configuration objects such as <c>TToolConfig</c>,
    /// <c>TRetrievalConfig</c>, <c>TLatLng</c>, and <c>TFunctionCallingConfig</c> via its <c>AddXXX</c> methods.
    /// </para>
    /// </remarks>
    class function ToolConfig: TGenerationToolConfig; static;
  end;

implementation

{$REGION 'dev note'}

(*

  The Gemini.Helpers unit provides fluent helper records around TArrayBuilder<T>
  to streamline the construction of chat request payloads. The goal is to let
  callers assemble complex, JSON-ready structures (parts, content messages,
  speaker configurations, tool declarations, etc.) using a natural chained
  syntax without manually managing dynamic array growth or dealing with the
  underlying JSON representation.

  Each helper wraps specific payload types (TPartParams, TContentPayload,
  TSpeakerVoiceConfig, TFunctionDeclarations, TToolParams) and exposes
  expressive AddXXX() methods that append elements via TArrayBuilder<T>.
  This allows developers to focus on the semantic structure they want to build
  rather than on the container mechanics.

  The result is a higher-level, declarative API that keeps user code compact,
  readable, and less error-prone, especially when producing nested arrays that
  map directly to the final JSON structures consumed by the API.

*)

{$ENDREGION}

{ TContentHelper }

function TContentHelper.Assistant(const Parts: TParts): TContent;
begin
  Result := Self.Add(TContentPayload.Assistant(TArray<TPartParams>(Parts)));
end;

function TContentHelper.AddParts(const Value: TArray<TPartParams>): TContent;
begin
  Result := Self.Add(TContentPayload.Add(Value));
end;

function TContentHelper.AddText(const Value: string): TContent;
begin
  Result := Self.Add(TContentPayload.Add(Value));
end;

function TContentHelper.Assistant(const Value: string;
  const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.Assistant(Value, Attached));
end;

function TContentHelper.Model(const Value: string;
  const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.Assistant(Value, Attached));
end;

function TContentHelper.Model(const Parts: TParts): TContent;
begin
  Result := Self.Add(TContentPayload.Assistant(TArray<TPartParams>(Parts)));
end;

function TContentHelper.User(const Parts: TParts): TContent;
begin
  Result := Self.Add(TContentPayload.User(TArray<TPartParams>(Parts)));
end;

function TContentHelper.User(const Value: string;
  const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.User(Value, Attached));
end;

function TContentHelper.User(const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.User(Attached));
end;

{ TPartsHelper }

function TPartsHelper.AddInlineData(const Base64, MimeType: string): TParts;
begin
  Result := Self.Add(TPartParams.NewInlineData(Base64, MimeType));
end;

function TPartsHelper.AddCodeExecutionResult(
  const Outcome: TOutcomeType;
  const Output: string): TParts;
begin
  Result := Self.Add(TPartParams.NewCodeExecutionResult(Outcome, Output));
end;

function TPartsHelper.AddCodeExecutionResult(const Outcome,
  Output: string): TParts;
begin
  Result := Self.AddCodeExecutionResult(TOutcomeType.Parse(Outcome), Output);
end;

function TPartsHelper.AddExecutableCode(const Language, Code: string): TParts;
begin
  Result := Self.AddExecutableCode(TLanguageType.Parse(Language), Code);
end;

function TPartsHelper.AddExecutableCode(const Language: TLanguageType;
  const Code: string): TParts;
begin
  Result := Self.Add(TPartParams.NewExecutableCode(Language, Code));
end;

function TPartsHelper.AddFileData(const Uri: string; const MimeType: string): TParts;
begin
  Result := Self.Add(TPartParams.NewFileData(Uri, MimeTYpe));
end;

function TPartsHelper.AddFunctionCall(const Name: string): TParts;
begin
  Result := Self.Add(TPartParams.NewFunctionCall(Name));
end;

function TPartsHelper.AddFunctionResponse(const Name: string;
  const Response: TJSONObject): TParts;
begin
  Result := Self.Add(TPartParams.NewFunctionResponse(Name, Response));
end;

function TPartsHelper.AddText(const Text: string; Thought: Boolean): TParts;
begin
  Result := Self.Add(TPartParams.NewText(Text, Thought));
end;

{ TSpeakerVoiceHelper }

function TSpeakerVoiceHelper.AddItem(const Speaker,
  VoiceName: string): TSpeakerVoice;
begin
  Result := Self.Add(TSpeakerVoiceConfig.NewSpeakerVoiceConfig(Speaker, VoiceName));
end;

function TSpeakerVoiceHelper.AddItem(
  const Value: TSpeakerVoiceConfig): TSpeakerVoice;
begin
  Result := Self.Add(TSpeakerVoiceConfig.New(Value));
end;

{ TFunctionHelper }

function TFunctionHelper.AddFunction(const Name,
  Description: string): TFunction;
begin
  Result := Self.Add(TFunctionDeclarations.NewFunction(Name, Description));
end;

{ TToolsHelper }

function TToolsHelper.AddCodeExecution(const Value: TCodeExecution): TTools;
begin
  Result := Self.Add(TToolParams.NewCodeExecution(Value));
end;

function TToolsHelper.AddComputerUse(const Value: TComputerUse): TTools;
begin
  Result := Self.Add(TToolParams.NewComputerUse(Value));
end;

function TToolsHelper.AddFileSearch(const Value: TFileSearch): TTools;
begin
  Result := Self.Add(TToolParams.NewFileSearch(Value));
end;

function TToolsHelper.AddFunctionDeclarations(
  const Value: TArray<TFunctionDeclarations>): TTools;
begin
  Result := Self.Add(TToolParams.NewFunctionDeclarations(Value));
end;

function TToolsHelper.AddGoogleSearchRetrieval(
  const Value: TGoogleSearchRetrieval): TTools;
begin
  Result := Self.Add(TToolParams.NewGoogleSearchRetrieval(Value));
end;

function TToolsHelper.AddUrlContext(const Value: TUrlContext): TTools;
begin
  Result := Self.Add(TToolParams.NewUrlContext(Value));
end;

function TToolsHelper.AddGoogleMaps(const Value: TGoogleMaps): TTools;
begin
  Result := Self.Add(TToolParams.NewGoogleMaps(Value));
end;

function TToolsHelper.AddGoogleSearch(const Value: TGoogleSearch): TTools;
begin
  Result := Self.Add(TToolParams.NewGoogleSearch(Value));
end;

{ TBatchEmbeddingsHelper }

function TBatchEmbeddingsHelper.AddItem(const Model: string;
  const Content: TArray<string>): TBatchEmbeddings;
begin
  Result := Self.Add(TEmbedContentParams.NewEmbedContentParams(Model, Content));
end;

function TBatchEmbeddingsHelper.AddItem(const Model: string;
  const Content: TContentPayload): TBatchEmbeddings;
begin
  Result := Self.Add(TEmbedContentParams.NewEmbedContentParams(Model, Content));
end;


{ TInlineRequestHelper }

function TInlineRequestHelper.AddItem(
  const Value: TGenerateContentRequestParams): TInlineRequest;
begin
  Result := Self.Add(TInlinedRequestParams.NewRequest(Value));
end;

function TInlineRequestHelper.AddItem(const Key: string;
  const Value: TGenerateContentRequestParams): TInlineRequest;
begin
  Result := Self.Add(TInlinedRequestParams.NewRequest(Key, Value));
end;

{ TThoughtSummaryHelper }

function TThoughtSummaryHelper.AddText(
  const Value: string): TThoughtSummary;
begin
  Result := Self.Add(TThoughtSummaryIxParams.New(Value));
end;

{ TGoogleSearchResultHelper }

function TGoogleSearchResultHelper.AddItem: TGoogleSearchResult;
begin
  Result := Self.Add(TGoogleSearchResultIxParams.New);
end;

{ TFileSearchResultHelper }

function TFileSearchResultHelper.AddItem(const Value: TFileSearchResultIxParams): TFileSearchResult;
begin
  Result := Self.Add(TFileSearchResultIxParams.New(Value));
end;

{ TUrlContextResultHelper }

function TUrlContextResultHelper.AddItem(const Value: TUrlContextResultIxParams): TUrlContextResult;
begin
  Result := Self.Add(TUrlContextResultIxParams.New(Value));
end;

{ TToolIxHelper }

function TToolIxHelper.AddCodeExecution(
  const Value: TCodeExecutionIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddCodeExecution(Value));
end;

function TToolIxHelper.AddComputerUse(
  const Value: TComputerUseIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddComputerUse(Value));
end;

function TToolIxHelper.AddFileSearch(const Value: TFileSearchIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddFileSearch(Value));
end;

function TToolIxHelper.AddFunction(const Value: TFunctionIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddFunction(Value));
end;

function TToolIxHelper.AddGoogleSearch(
  const Value: TGoogleSearchIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddGoogleSearch(Value));
end;

function TToolIxHelper.AddMcpServer(
  const Value: TMcpServerIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddMcpServer(Value));
end;

function TToolIxHelper.AddUrlContext(const Value: TUrlContextIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddUrlContext(Value));
end;

{ TInputContentHelper }

function TInputContentHelper.AddAssistant(const Value: string): TTurn;
begin
  Result := Self.Add(TTurnParams.AddAssistant(Value));
end;

function TInputContentHelper.AddUser(const Value: string): TTurn;
begin
  Result := Self.Add(TTurnParams.AddUser(Value));
end;

function TInputContentHelper.AddModel(const Value: string): TTurn;
begin
  Result := Self.Add(TTurnParams.AddAssistant(Value));
end;

function TInputContentHelper.AddUser(
  const Content: TArray<TInputParams>): TTurn;
begin
  Result := Self.Add(TTurnParams.AddUser(Content));
end;

{ TInputHelper }

function TInputHelper.AddAudio(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddAudio(Uri));
end;

function TInputHelper.AddAudio(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddAudio(Data64, MimeType));
end;

function TInputHelper.AddAudio(const Value: TAudioContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddAudio(Value));
end;


function TInputHelper.AddDocument(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddDocument(Data64, MimeType));
end;

function TInputHelper.AddDocument(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddDocument(Uri));
end;

function TInputHelper.AddDocument(
  const Value: TDocumentContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddDocument(Value));
end;

function TInputHelper.AddFileSearchResult(
  const AResult: TArray<TFileSearchResultIxParams>): TInput;
begin
  Result := Self.Add(TInputParams.AddFileSearchResult(AResult));
end;

function TInputHelper.AddFileSearchResult(
  const Value: TFileSearchResultContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddFileSearchResult(Value));
end;

function TInputHelper.AddFunctionCall(const Name, Id,
  Arguments: string): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionCall(Name, Id, Arguments));
end;

function TInputHelper.AddFunctionCall(const Name, Id: string;
  const Arguments: TJSONObject): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionCall(Name, Id, Arguments));
end;

function TInputHelper.AddFunctionResult(const AResult: TJSONObject;
  const Name, CallId: string): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionResult(AResult, Name, CallId));
end;

function TInputHelper.AddFunctionResult(const AResult, Name, CallId: string): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionResult(AResult, Name, CallId));
end;

function TInputHelper.AddImage(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddImage(Uri));
end;

function TInputHelper.AddImage(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddImage(Data64, MimeType));
end;

function TInputHelper.AddImage(const Value: TImageContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddImage(Value));
end;

function TInputHelper.AddRaw(const Value: TContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddRaw(Value));
end;

function TInputHelper.AddText(const Value: string): TInput;
begin
  Result := Self.Add(TInputParams.AddText(Value));
end;

function TInputHelper.AddVideo(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddVideo(Data64, MimeType));
end;

function TInputHelper.AddVideo(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddVideo(Uri));
end;

function TInputHelper.AddVideo(const Value: TVideoContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddVideo(Value));
end;

{ TInstanceHelper }

function TInstanceHelper.AddItem(const Value: TVideoInstanceParams): TVideoInstance;
begin
  Result := Self.Add(TVideoInstanceParams.New(Value));
end;

{ TReferenceHelper }

function TReferenceHelper.AddItem(const Image: TImageInstanceParams;
  ReferenceType: string): TReference;
begin
  Result := Self.Add(TReferenceImages.NewReference(Image, ReferenceType));
end;

{ TVideoMedia }

class function TVideoMedia.Instances: TVideoInstance;
begin
  Result := TVideoInstance.Create();
end;

class function TVideoMedia.AddInstance: TVideoInstanceParams;
begin
  Result := TVideoInstanceParams.Create;
end;

class function TVideoMedia.References: TReference;
begin
  Result := TReference.Create();
end;

class function TVideoMedia.Base64(const Value64,
  MimeType: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
    .BytesBase64Encoded(Value64)
    .MimeType(MimeType)
end;

class function TVideoMedia.Uri(const Uri,
  MimeType: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
    .GcsUri(Uri)
    .MimeType(MimeType)
end;

class function TVideoMedia.MaskBase64(const Value64,
  MimeType: string;
  const MaskMode: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
     .BytesBase64Encoded(Value64)
     .MimeType(MimeType);

  if not MaskMode.IsEmpty then
    Result.MaskMode(MaskMode);
end;

class function TVideoMedia.MaskUri(const Uri, MimeType,
  MaskMode: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
     .BytesBase64Encoded(Uri)
     .MimeType(MimeType);

  if not MaskMode.IsEmpty then
    Result.MaskMode(MaskMode);
end;

{ TImageGenInstanceHelper }

function TImageGenInstanceHelper.AddItem(
  const Value: TImageGenInstanceParams): TImageGenInstance;
begin
  Result := Self.Add(TImageGenInstanceParams.New(Value));
end;

{ TImageGenMedia }

class function TImageGenMedia.Instances: TImageGenInstance;
begin
  Result := TImageGenInstance.Create;
end;

class function TImageGenMedia.Prompt(
  const Value: string): TImageGenInstanceParams;
begin
  Result := TImageGenInstanceParams.Create
    .Prompt(Value);
end;

{ TInteractionTurn }

class function TInteractionTurn.Turns: TTurn;
begin
  Result := TTurn.Create();
end;

{ TInteractionInput }

class function TInteractionInput.AddInput: TInputParams;
begin
  Result := TInputParams.Create;
end;

class function TInteractionInput.Inputs: TInput;
begin
  Result := TInput.Create();
end;

{ TInteractionTool }

class function TInteractionTool.AddCodeExecution: TCodeExecutionIxParams;
begin
  Result := TCodeExecutionIxParams.New;
end;

class function TInteractionTool.AddComputerUse: TComputerUseIxParams;
begin
  Result := TComputerUseIxParams.New;
end;

class function TInteractionTool.AddFileSearch: TFileSearchIxParams;
begin
  Result := TFileSearchIxParams.New;
end;

class function TInteractionTool.AddFunction: TFunctionIxParams;
begin
  Result := TFunctionIxParams.New;
end;

class function TInteractionTool.AddGoogleSearch: TGoogleSearchIxParams;
begin
  Result := TGoogleSearchIxParams.New;
end;

class function TInteractionTool.AddMcpServer: TMcpServerIxParams;
begin
  Result := TMcpServerIxParams.New;
end;

class function TInteractionTool.AddUrlContext: TUrlContextIxParams;
begin
  Result := TUrlContextIxParams.New;
end;

class function TInteractionTool.Tools: TToolIx;
begin
  Result := TToolIx.Create();
end;

{ TInteractionThought }

class function TInteractionThought.Summaries: TThoughtSummary;
begin
  Result := TThoughtSummary.Create();
end;

{ TInteractionGoogleSearch }

class function TInteractionGoogleSearch.Results: TGoogleSearchResult;
begin
  Result := TGoogleSearchResult.Create();
end;

{ TInteractionFileSearch }

class function TInteractionFileSearch.AddSearchResult: TFileSearchResultIxParams;
begin
  Result := TFileSearchResultIxParams.Create;
end;

class function TInteractionFileSearch.Results: TFileSearchResult;
begin
  Result := TFileSearchResult.Create();
end;

{ TInteractionUrlContext }

class function TInteractionUrlContext.AddUrlContext: TUrlContextResultIxParams;
begin
  Result := TUrlContextResultIxParams.Create;
end;

class function TInteractionUrlContext.Results: TUrlContextResult;
begin
  Result := TUrlContextResult.Create();
end;

{ TBatchContent }

class function TBatchContent.AddRequestContent: TGenerateContentRequestParams;
begin
  Result := TGenerateContentRequestParams.Create;
end;

class function TBatchContent.AddRequest: TInlinedRequestsParams;
begin
  Result := TInlinedRequestsParams.Create();
end;

class function TBatchContent.AddInputConfig: TInputConfigParams;
begin
  Result := TInputConfigParams.Create;
end;

class function TBatchContent.Requests: TInlineRequest;
begin
  Result := TInlineRequest.Create();
end;

{ TGenerationContent }

class function TGenerationContent.Parts: TParts;
begin
  Result := TParts.Create();
end;

class function TGenerationContent.Contents: TContent;
begin
  Result := TContent.Create();
end;

{ TGenerationPart }

class function TGenerationPart.Parts: TParts;
begin
  Result := TParts.Create();
end;

{ TEmbeddingsBatch }

class function TEmbeddingsBatch.Contents: TBatchEmbeddings;
begin
  Result := TBatchEmbeddings.Create();
end;

{ TGenerationTool }

class function TGenerationTool.CodeExecution: TCodeExecution;
begin
  Result := TCodeExecution.Create;
end;

class function TGenerationTool.ComputerUse: TComputerUse;
begin
  Result := TComputerUse.Create;
end;

class function TGenerationTool.DynamicRetrievalConfig: TDynamicRetrievalConfig;
begin
  Result := TDynamicRetrievalConfig.Create;
end;

class function TGenerationTool.FileSearch: TFileSearch;
begin
  Result := TFileSearch.Create;
end;

class function TGenerationTool.AddCodeExecution(
  const Value: TCodeExecution): TTools;
begin
  Result := Default(TTools).AddCodeExecution(Value);
end;

class function TGenerationTool.AddComputerUse(
  const Value: TComputerUse): TTools;
begin
  Result := Default(TTools).AddComputerUse(Value);
end;

class function TGenerationTool.AddFileSearch(const Value: TFileSearch): TTools;
begin
  Result := Default(TTools).AddFileSearch(Value);
end;

class function TGenerationTool.AddFunction: TFunctionDeclarations;
begin
  Result := TFunctionDeclarations.Create;
end;

class function TGenerationTool.AddFunctionDeclarations(
  const Value: TArray<TFunctionDeclarations>): TTools;
begin
  Result := Default(TTools).AddFunctionDeclarations(Value);
end;

class function TGenerationTool.GoogleMaps: TGoogleMaps;
begin
  Result := TGoogleMaps.Create;
end;

class function TGenerationTool.GoogleSearch: TGoogleSearch;
begin
  Result := TGoogleSearch.Create;
end;

class function TGenerationTool.AddGoogleMaps(const Value: TGoogleMaps): TTools;
begin
  Result := Default(TTools).AddGoogleMaps(Value);
end;

class function TGenerationTool.AddGoogleSearch(
  const Value: TGoogleSearch): TTools;
begin
  Result := Default(TTools).AddGoogleSearch(Value);
end;

class function TGenerationTool.AddGoogleSearchRetrieval(
  const Value: TGoogleSearchRetrieval): TTools;
begin
  Result := Default(TTools).AddGoogleSearchRetrieval(Value);
end;

class function TGenerationTool.AddUrlContext(const Value: TUrlContext): TTools;
begin
  Result := Default(TTools).AddUrlContext(Value);
end;

class function TGenerationTool.GoogleSearchRetrieval: TGoogleSearchRetrieval;
begin
  Result := TGoogleSearchRetrieval.Create;
end;

class function TGenerationTool.UrlContext: TUrlContext;
begin
  Result := TUrlContext.Create;
end;

class function TGenerationTool.Functions: TFunction;
begin
  Result := TFunction.Create();
end;

class function TGenerationTool.Tools: TTools;
begin
  Result := TTools.Create();
end;

{ TGenerationSpeaker }

class function TGenerationSpeaker.AddMultiSpeakerVoiceConfig: TMultiSpeakerVoiceConfig;
begin
  Result := TMultiSpeakerVoiceConfig.Create;
end;

class function TGenerationSpeaker.AddSpeakerVoiceConfig: TSpeakerVoiceConfig;
begin
  Result := TSpeakerVoiceConfig.Create;
end;

class function TGenerationSpeaker.AddVoiceConfig(const VoiceName: string): TVoiceConfig;
begin
  Result := TVoiceConfig.NewVoiceConfig(VoiceName);
end;

class function TGenerationSpeaker.Voices: TSpeakerVoice;
begin
  Result := TSpeakerVoice.Create();
end;

{ TGeneration }

class function TGeneration.AddConfig: TGenerationConfig;
begin
  Result := TGenerationConfig.Create;
end;

class function TGeneration.Config: TGenerationConfiguration;
begin
  Result := Default(TGenerationConfiguration);
end;

class function TGeneration.Content: TGenerationContent;
begin
  Result := Default(TGenerationContent);
end;

class function TGeneration.Contents: TContent;
begin
  Result := TGeneration.Content.Contents;
end;

class function TGeneration.Parts: TParts;
begin
  Result := TGeneration.Content.Parts;
end;

class function TGeneration.Speaker: TGenerationSpeaker;
begin
  Result := Default(TGenerationSpeaker);
end;

class function TGeneration.ToolConfig: TGenerationToolConfig;
begin
  Result := Default(TGenerationToolConfig);
end;

class function TGeneration.Tools: TGenerationTool;
begin
  Result := Default(TGenerationTool);
end;

{ TGenerationConfiguration }

class function TGenerationConfiguration.AddGenerationConfig: TGenerationConfig;
begin
  Result := TGenerationConfig.Create;
end;

class function TGenerationConfiguration.AddImageConfig: TImageConfig;
begin
  Result := TImageConfig.Create;
end;

class function TGenerationConfiguration.AddSpeechConfig: TSpeechConfig;
begin
  Result := TSpeechConfig.Create;
end;

class function TGenerationConfiguration.AddThinkingConfig: TThinkingConfig;
begin
  Result := TThinkingConfig.Create;
end;

{ TGenerationToolConfig }

class function TGenerationToolConfig.AddFunctionCallingConfig: TFunctionCallingConfig;
begin
  Result := TFunctionCallingConfig.Create;
end;

class function TGenerationToolConfig.AddLatLng(const Latitude,
  Longitude: Double): TLatLng;
begin
  Result := TLatLng.Create
    .Latitude(Latitude)
    .Longitude(Longitude);
end;

class function TGenerationToolConfig.AddRetrievalConfig: TRetrievalConfig;
begin
  Result := TRetrievalConfig.Create;
end;

class function TGenerationToolConfig.AddToolConfig: TToolConfig;
begin
  Result := TToolConfig.Create;
end;

end.
