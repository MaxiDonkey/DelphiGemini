unit Gemini.Helpers;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Gemini.API.Params, Gemini.Types, Gemini.API.ArrayBuilder,
  Gemini.Chat.Request, Gemini.Chat.Request.Content, Gemini.Chat.Request.ToolConfig,
  Gemini.Chat.Request.GenerationConfig, Gemini.Chat.Request.Tools,
  Gemini.Embeddings, Gemini.Batch, Gemini.Interactions, Gemini.Interactions.Content,
  Gemini.Interactions.Tools, Gemini.Video, Gemini.ImageGen, Gemini.Interactions.GenerationConfig,
  Gemini.Interactions.Common;

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
    /// <summary>
    /// Appends a thought summary text entry to the builder.
    /// </summary>
    /// <param name="Value">
    /// The summary text to include as a new <c>TThoughtSummaryIxParams</c> item.
    /// </param>
    /// <returns>
    /// The updated <c>TThoughtSummary</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TThoughtSummaryIxParams</c> created via <c>TThoughtSummaryIxParams.New(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this helper to build the <c>summary</c> array consumed by <c>TThoughtContentIxParams.Summary(...)</c>,
    /// typically to provide a human-readable summary of a model “thought” block.
    /// </para>
    /// <para>
    /// • No validation is performed here; callers should ensure <paramref name="Value"/> is suitable for
    /// serialization and any downstream constraints (length, format) imposed by the backend.
    /// </para>
    /// </remarks>
    function AddText(const Value: string): TThoughtSummary;
  end;

  TInteractionThought = record
    class function Summaries: TThoughtSummary; static;
  end;

  TGoogleSearchResult = TArrayBuilder<TGoogleSearchResultIxParams>;

  TGoogleSearchResultHelper = record Helper for TGoogleSearchResult
    /// <summary>
    /// Appends a Google Search result tool-output item to the current <c>TGoogleSearchResult</c> builder.
    /// </summary>
    /// <param name="Value">
    /// The Google Search result parameters to add (typically including the tool call identifier and the
    /// search response payload returned by the tool).
    /// </param>
    /// <returns>
    /// The same <c>TGoogleSearchResult</c> instance, allowing fluent chaining of successive
    /// <c>AddResult</c> calls.
    /// </returns>
    /// <remarks>
    /// <para>
    /// Use this helper when you need to include a Google Search tool result in the interaction output so it
    /// can be referenced by subsequent turns.
    /// </para>
    /// <para>
    /// This method does not validate the contents of <paramref name="Value"/>; it simply stores the
    /// provided parameters in the underlying array/collection managed by the builder.
    /// </para>
    /// </remarks>
    function AddResult(const Value: TGoogleSearchResultIxParams): TGoogleSearchResult;
  end;

  TInteractionGoogleSearch = record
    class function Results: TGoogleSearchResult; static;
  end;

  TFileSearchResult = TArrayBuilder<TFileSearchResultIxParams>;

  TFileSearchResultHelper = record Helper for TFileSearchResult
    /// <summary>
    /// Appends a file search result entry to the builder from an existing result object.
    /// </summary>
    /// <param name="Value">
    /// The <c>TFileSearchResultIxParams</c> instance to append. A copy/wrapped value is added to the builder.
    /// </param>
    /// <returns>
    /// The updated <c>TFileSearchResult</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload appends a new <c>TFileSearchResultIxParams</c> created via <c>TFileSearchResultIxParams.New(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this when you already have a fully populated file-search result (e.g., produced elsewhere or returned by an API)
    /// and want to aggregate multiple entries into the array passed to
    /// <c>TFileSearchResultContentIxParams.Result(...)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> contains the expected fields
    /// (typically <c>Title</c>, <c>Text</c>, and <c>FileSearchStore</c>) before appending.
    /// </para>
    /// </remarks>
    function AddResult(const Value: TFileSearchResultIxParams): TFileSearchResult; overload;
  end;

  TInteractionFileSearch = record
    class function Results: TFileSearchResult; static;
    class function AddSearchResult: TFileSearchResultIxParams; static;
  end;

  TUrlContextResult = TArrayBuilder<TUrlContextResultIxParams>;

  TUrlContextResultHelper = record Helper for TUrlContextResult
    /// <summary>
    /// Appends a URL context result entry to the builder from an existing result object.
    /// </summary>
    /// <param name="Value">
    /// The <c>TUrlContextResultIxParams</c> instance to append. A copy/wrapped value is added to the builder.
    /// </param>
    /// <returns>
    /// The updated <c>TUrlContextResult</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TUrlContextResultIxParams</c> created via <c>TUrlContextResultIxParams.New(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this when you already have a populated URL context result (for example, a fetched URL plus its status)
    /// and want to aggregate multiple entries into the array passed to
    /// <c>TUrlContextResultContentIxParams.Result(...)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> contains the expected fields
    /// (typically <c>Url</c> and <c>Status</c>) before appending.
    /// </para>
    /// </remarks>
    function AddResult(const Value: TUrlContextResultIxParams): TUrlContextResult;
  end;

  TInteractionUrlContext = record
    class function Results: TUrlContextResult; static;
    class function AddUrlContext: TUrlContextResultIxParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Tools'}

  TToolIx = TArrayBuilder<TToolIxParams>;

  TToolIxHelper = record Helper for TToolIx
    /// <summary>
    /// Appends a function tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TFunctionIxParams</c> instance describing the function tool configuration to add.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddFunction(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you already have a fully configured <c>TFunctionIxParams</c> (for example,
    /// with function declarations / schemas) and want to include it in the interaction toolset as-is.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> matches the expected schema
    /// and contains the declarations/configuration required by your target endpoint.
    /// </para>
    /// </remarks>
    function AddFunction(const Value: TFunctionIxParams): TToolIx;

    /// <summary>
    /// Appends a Google Search tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TGoogleSearchIxParams</c> instance configuring Google Search behavior for the
    /// interaction. When <c>nil</c>, a default Google Search configuration is used.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddGoogleSearch(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable the built-in Google Search tool for interactions so the model can
    /// retrieve web results when generating a response.
    /// </para>
    /// <para>
    /// • When <paramref name="Value"/> is <c>nil</c>, the underlying factory is expected to create a
    /// default configuration. The exact defaults depend on <c>TToolIxParams.AddGoogleSearch</c>.
    /// </para>
    /// </remarks>
    function AddGoogleSearch(const Value: TGoogleSearchIxParams = nil): TToolIx;

    /// <summary>
    /// Appends a code execution tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TCodeExecutionIxParams</c> instance configuring code execution behavior for the
    /// interaction. When <c>nil</c>, a default code execution configuration is used.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddCodeExecution(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable the built-in code execution tool for interactions so the model can
    /// request execution of generated code and incorporate the results.
    /// </para>
    /// <para>
    /// • When <paramref name="Value"/> is <c>nil</c>, the underlying factory is expected to create a
    /// default configuration. The exact defaults depend on <c>TToolIxParams.AddCodeExecution</c>.
    /// </para>
    /// </remarks>
    function AddCodeExecution(const Value: TCodeExecutionIxParams = nil): TToolIx;

    /// <summary>
    /// Appends a URL context tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// Optional. The <c>TUrlContextIxParams</c> instance configuring how external URL-based
    /// context should be retrieved and provided to the model during the interaction.
    /// When <c>nil</c>, a default URL context configuration is used.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddUrlContext(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable URL context retrieval so the model can request and consume
    /// content fetched from external URLs as part of its reasoning or response generation.
    /// </para>
    /// <para>
    /// • When <paramref name="Value"/> is <c>nil</c>, the underlying factory is expected to create
    /// a default configuration. The exact defaults depend on <c>TToolIxParams.AddUrlContext</c>.
    /// </para>
    /// <para>
    /// • Ensure that any URLs referenced by the resulting configuration are accessible and
    /// permitted by the target runtime/environment.
    /// </para>
    /// </remarks>
    function AddUrlContext(const Value: TUrlContextIxParams = nil): TToolIx;

    /// <summary>
    /// Appends a computer use tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TComputerUseIxParams</c> instance configuring how the model may interact with a
    /// virtual computer environment (for example, UI actions, navigation, or environment control),
    /// as supported by the selected endpoint/runtime.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddComputerUse(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method to enable “computer use” capabilities for an interaction, allowing the
    /// model to request actions against a controlled computer environment when supported.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is properly configured
    /// (e.g., permissions, allowed actions, environment identifiers) before appending.
    /// </para>
    /// </remarks>
    function AddComputerUse(const Value: TComputerUseIxParams): TToolIx;

    /// <summary>
    /// Appends an MCP server tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TMcpServerIxParams</c> instance describing the MCP server configuration
    /// (for example, server identity/endpoint and any protocol-specific settings) that the
    /// model may use during the interaction.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddMcpServer(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method when your interaction needs to expose an MCP server as an available tool,
    /// enabling the model to route requests through that server when supported by the runtime.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is properly configured
    /// (e.g., endpoint, capabilities, authentication hints if applicable) before appending.
    /// </para>
    /// </remarks>
    function AddMcpServer(const Value: TMcpServerIxParams): TToolIx;

    /// <summary>
    /// Appends a file search tool declaration to the tools builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TFileSearchIxParams</c> instance describing the file search configuration
    /// (for example, index/scope identifiers and any retrieval options) that the model
    /// may use during the interaction.
    /// </param>
    /// <returns>
    /// The updated <c>TToolIx</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new tool entry created via <c>TToolIxParams.AddFileSearch(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method to expose file search capabilities to the model in an interactions-style
    /// payload, enabling the model to request retrieval from configured file sources when supported.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is fully configured
    /// (e.g., scope, filters, limits) according to your file search backend and schema expectations.
    /// </para>
    /// </remarks>
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
    /// <summary>
    /// Appends a <c>user</c> turn containing a single text input to the turns builder.
    /// </summary>
    /// <param name="Value">
    /// The text message to include in the appended user turn.
    /// </param>
    /// <returns>
    /// The updated <c>TTurn</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload is a convenience for the common case where the user turn contains only text.
    /// Internally it appends <c>TTurnParams.AddUser(Value)</c>, which sets <c>role = user</c> and wraps the
    /// provided string into a single <c>text</c> input item.
    /// </para>
    /// <para>
    /// • If you need a user turn composed of multiple inputs (for example image/audio/document/function call),
    /// use <c>AddUser(const Content: TArray&lt;TInputParams&gt;)</c> instead.
    /// </para>
    /// </remarks>
    function AddUser(const Value: string): TTurn; overload;

    /// <summary>
    /// Appends a <c>user</c> turn containing the specified input items to the turns builder.
    /// </summary>
    /// <param name="Content">
    /// The array of <c>TInputParams</c> items that make up the user turn. Each item represents one input
    /// modality or payload element (for example: text, image, audio, document, function call/result, etc.).
    /// </param>
    /// <returns>
    /// The updated <c>TTurn</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload is intended for multi-part or multi-modal user turns. Internally it appends
    /// <c>TTurnParams.AddUser(Content)</c>, which sets <c>role = user</c> and attaches the provided inputs as-is.
    /// </para>
    /// <para>
    /// • The <paramref name="Content"/> array is not validated here; ensure each <c>TInputParams</c> instance is
    /// properly constructed (e.g., using <c>TInteractionInput.Inputs</c> / <c>TInputHelper</c> fluent builders)
    /// before calling this method.
    /// </para>
    /// <para>
    /// • For the common “single text message” case, prefer <c>AddUser(const Value: string)</c>.
    /// </para>
    /// </remarks>
    function AddUser(const Content: TArray<TInputParams>): TTurn; overload;

    /// <summary>
    /// Appends an <c>assistant</c> turn containing a single text message to the turns builder.
    /// </summary>
    /// <param name="Value">
    /// The text message to include in the appended assistant turn.
    /// </param>
    /// <returns>
    /// The updated <c>TTurn</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends <c>TTurnParams.AddAssistant(Value)</c>, which creates a new turn with
    /// <c>role = assistant</c> and wraps the provided string into the turn content.
    /// </para>
    /// <para>
    /// • Use this method when you need to include prior assistant output in an interaction history
    /// (for example, to provide conversational context to the model).
    /// </para>
    /// </remarks>
    function AddAssistant(const Value: string): TTurn; overload;

    /// <summary>
    /// Appends an <c>assistant</c> turn containing the specified input items to the turns builder.
    /// </summary>
    /// <param name="Content">
    /// The array of <c>TInputParams</c> items that make up the assistant turn. Each item represents one input
    /// element (for example: text, image, audio, document, function call/result, file search result, etc.).
    /// </param>
    /// <returns>
    /// The updated <c>TTurn</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload is intended for multi-part or multi-modal assistant turns. Internally it appends
    /// <c>TTurnParams.AddAssistant(Content)</c>, which sets <c>role = assistant</c> and attaches the provided inputs as-is.
    /// </para>
    /// <para>
    /// • The <paramref name="Content"/> array is not validated here; ensure each <c>TInputParams</c> instance is
    /// properly constructed (for example, using <c>TInteractionInput.Inputs</c> / <c>TInputHelper</c> fluent builders)
    /// before calling this method.
    /// </para>
    /// <para>
    /// • If you only need a simple “assistant text message”, prefer <c>AddAssistant(const Value: string)</c>.
    /// </para>
    /// </remarks>
    function AddAssistant(const Content: TArray<TInputParams>): TTurn; overload;

    /// <summary>
    /// Appends a <c>model</c> turn containing a single text message to the turns builder.
    /// </summary>
    /// <param name="Value">
    /// The text message to include in the appended model turn.
    /// </param>
    /// <returns>
    /// The updated <c>TTurn</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends <c>TTurnParams.AddAssistant(Value)</c>. In this codebase, “model” and “assistant”
    /// are treated as synonyms for turn construction, so the underlying builder call uses the assistant helper.
    /// </para>
    /// <para>
    /// • Use this method when you want your calling code to reflect Gemini’s API terminology (<c>model</c>)
    /// while preserving the same behavior as <c>AddAssistant</c>.
    /// </para>
    /// <para>
    /// • If your upstream serialization distinguishes strictly between <c>assistant</c> and <c>model</c> roles,
    /// ensure that <c>TTurnParams.AddAssistant</c> produces the intended role value for your target endpoint.
    /// </para>
    /// </remarks>
    function AddModel(const Value: string): TTurn; overload;

    /// <summary>
    /// Appends a <c>model</c> turn containing the specified input items to the turns builder.
    /// </summary>
    /// <param name="Content">
    /// The array of <c>TInputParams</c> items that make up the model turn. Each item represents one input
    /// element (for example: text, image, audio, document, function call/result, file search result, etc.).
    /// </param>
    /// <returns>
    /// The updated <c>TTurn</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload is intended for multi-part or multi-modal model turns. In this unit, “model” is treated as
    /// an ergonomic alias of “assistant” for turn construction: the implementation delegates to
    /// <c>AddAssistant(Content)</c> (and ultimately <c>TTurnParams.AddAssistant(Content)</c>).
    /// </para>
    /// <para>
    /// • The <paramref name="Content"/> array is attached as-is; no validation is performed here. Ensure each
    /// <c>TInputParams</c> instance is properly constructed (for example, using
    /// <c>TInteractionInput.Inputs</c> / <c>TInputHelper</c> fluent builders) before calling this method.
    /// </para>
    /// <para>
    /// • If your upstream serialization distinguishes strictly between <c>assistant</c> and <c>model</c> roles,
    /// verify that <c>TTurnParams.AddAssistant</c> produces the intended role value for your target endpoint.
    /// </para>
    /// </remarks>
    function AddModel(const Content: TArray<TInputParams>): TTurn; overload;
  end;

  TInteractionTurn = record
    /// <summary>
    /// Creates a new turns builder for assembling an interaction history.
    /// </summary>
    /// <returns>
    /// A new <c>TTurn</c> builder instance, ready to receive <c>TTurnParams</c> items
    /// via the fluent API (for example: <c>AddUser</c>, <c>AddAssistant</c>, <c>AddModel</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TTurn</c> builder (internally a <c>TArrayBuilder&lt;TTurnParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to append turns in chronological order and then pass the resulting
    /// <c>TArray&lt;TTurnParams&gt;</c> to the appropriate interactions/request payload (for example, an
    /// interactions history parameter).
    /// </para>
    /// <para>
    /// • This is a convenience factory equivalent to calling <c>TTurn.Create()</c>.
    /// </para>
    /// </remarks>
    class function Turns: TTurn; static;
  end;

  TInput = TArrayBuilder<TInputParams>;

  TInputHelper = record Helper for TInput
    /// <summary>
    /// Appends a text input item to the inputs builder.
    /// </summary>
    /// <param name="Value">
    /// The text content to add as a new input item.
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddText(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this method to represent a plain text input within a multi-modal interaction turn.
    /// </para>
    /// </remarks>
    function AddText(const Value: string): TInput;

    /// <summary>
    /// Appends an inline audio input item to the inputs builder using Base64-encoded bytes and a MIME type.
    /// </summary>
    /// <param name="Data64">
    /// The audio payload encoded as a Base64 string (raw bytes of the audio file).
    /// </param>
    /// <param name="MimeType">
    /// The IANA MIME type of the audio (for example: <c>audio/wav</c>, <c>audio/mpeg</c>, <c>audio/ogg</c>).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddAudio(Data64, MimeType)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on the Base64 payload; ensure it is valid and matches <paramref name="MimeType"/>.
    /// </para>
    /// <para>
    /// • Use this overload when the audio bytes are available locally/in-memory; if you only have a URI,
    /// prefer <c>AddAudio(const Uri: string)</c>.
    /// </para>
    /// </remarks>
    function AddAudio(const Data64: string; const MimeType: string): TInput; overload;

    /// <summary>
    /// Appends a URI-based audio input item to the inputs builder.
    /// </summary>
    /// <param name="Uri">
    /// The URI of the audio resource to attach (for example, a remote URL or a provider-specific storage URI).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddAudio(Uri)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when the audio is already hosted and accessible by URI; if you have the raw bytes,
    /// prefer <c>AddAudio(const Data64: string; const MimeType: string)</c>.
    /// </para>
    /// <para>
    /// • The URI is attached as-is; ensure it is reachable and that the referenced content is a supported audio type
    /// to avoid request-time errors.
    /// </para>
    /// </remarks>
    function AddAudio(const Uri: string): TInput; overload;

    /// <summary>
    /// Appends a preconstructed audio content payload to the inputs builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TAudioContentIxParams</c> instance describing the audio content to attach
    /// (for example, a URI-based reference or an inline Base64 payload, depending on how
    /// <c>Value</c> was constructed).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddAudio(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you already built the audio descriptor explicitly (e.g., with
    /// audio-specific factories/builders) and want to attach it without losing any metadata.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is fully configured and
    /// matches what the target endpoint expects (mime type, encoding/URI scheme, etc.).
    /// </para>
    /// </remarks>
    function AddAudio(const Value: TAudioContentIxParams): TInput; overload;

    /// <summary>
    /// Appends a document input item to the inputs builder using Base64-encoded bytes and a MIME type.
    /// </summary>
    /// <param name="Data64">
    /// The document content encoded as a Base64 string (raw bytes of the document).
    /// </param>
    /// <param name="MimeType">
    /// The IANA MIME type of the document (for example: <c>application/pdf</c>, <c>text/plain</c>,
    /// <c>application/vnd.openxmlformats-officedocument.wordprocessingml.document</c>).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload appends a new item created via <c>TInputParams.AddDocument(Data64, MimeType)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on the Base64 payload; ensure it is valid and matches <paramref name="MimeType"/>.
    /// </para>
    /// <para>
    /// • Use this overload when you already have the document bytes available in-memory (encoded as Base64).
    /// To reference an existing remote resource instead, use <c>AddDocument(const Uri: string)</c>.
    /// </para>
    /// </remarks>
    function AddDocument(const Data64: string; const MimeType: string): TInput; overload;

    /// <summary>
    /// Appends a document input item to the inputs builder by referencing the document via a URI.
    /// </summary>
    /// <param name="Uri">
    /// The URI of the document resource to attach (for example, an HTTPS URL or a provider-specific storage URI).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload appends a new item created via <c>TInputParams.AddDocument(Uri)</c>.
    /// </para>
    /// <para>
    /// • The URI is attached as a reference; the content is not embedded in the request payload.
    /// Ensure the referenced resource is accessible to the target endpoint/runtime.
    /// </para>
    /// <para>
    /// • Use this overload when the document already exists in external storage.
    /// To embed document bytes directly, use <c>AddDocument(const Data64: string; const MimeType: string)</c>.
    /// </para>
    /// </remarks>
    function AddDocument(const Uri: string): TInput; overload;

    /// <summary>
    /// Appends a document input item to the inputs builder from a preconstructed document content payload.
    /// </summary>
    /// <param name="Value">
    /// The <c>TDocumentContentIxParams</c> instance describing the document content to attach
    /// (for example: embedded bytes + MIME type, or a URI-based reference, depending on how the instance was built).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload appends a new item created via <c>TInputParams.AddDocument(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you already have a fully configured <c>TDocumentContentIxParams</c> (e.g., built
    /// via your interaction/content factories) and want to attach it without re-specifying encoding or location.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is complete and consistent
    /// (e.g., MIME type matches the payload, URI is valid/reachable) to avoid API-side errors.
    /// </para>
    /// </remarks>
    function AddDocument(const Value: TDocumentContentIxParams): TInput; overload;

    /// <summary>
    /// Appends an inline image input to the inputs builder using Base64-encoded bytes and a MIME type.
    /// </summary>
    /// <param name="Data64">
    /// The image bytes encoded as a Base64 string (raw bytes of the image file).
    /// </param>
    /// <param name="MimeType">
    /// The IANA MIME type of the image (for example: <c>image/png</c>, <c>image/jpeg</c>, <c>image/webp</c>).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddImage(Data64, MimeType)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on the Base64 payload; ensure it is valid and matches
    /// <paramref name="MimeType"/> to avoid downstream API errors.
    /// </para>
    /// <para>
    /// • Use the URI-based overload (<c>AddImage(const Uri: string)</c>) when you prefer referencing
    /// an existing remote object rather than embedding bytes inline.
    /// </para>
    /// </remarks>
    function AddImage(const Data64: string; const MimeType: string): TInput; overload;

    /// <summary>
    /// Appends a URI-based image input to the inputs builder by referencing the image resource.
    /// </summary>
    /// <param name="Uri">
    /// The URI of the image resource to attach (for example, a remote URL or a provider-specific URI such as a GCS URI).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddImage(Uri)</c>.
    /// </para>
    /// <para>
    /// • Prefer this overload when the image is already hosted and can be referenced directly, to avoid
    /// embedding large Base64 payloads in the request.
    /// </para>
    /// <para>
    /// • Use the inline overload (<c>AddImage(const Data64: string; const MimeType: string)</c>) when you need to
    /// send raw bytes (for example, when the image is only available locally or must be embedded).
    /// </para>
    /// </remarks>
    function AddImage(const Uri: string): TInput; overload;

    /// <summary>
    /// Appends a preconstructed image content payload to the inputs builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TImageContentIxParams</c> instance describing the image input to attach (for example,
    /// as inline Base64 bytes or as a URI-based reference, depending on how <c>Value</c> was built).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddImage(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you have already assembled a fully configured image payload
    /// (for example, via image-specific factories/helpers) and want to attach it without further
    /// transformation.
    /// </para>
    /// <para>
    /// • This helper does not validate the content of <paramref name="Value"/>; ensure it is correctly
    /// configured (URI vs inline data, MIME type, etc.) for the target endpoint.
    /// </para>
    /// </remarks>
    function AddImage(const Value: TImageContentIxParams): TInput; overload;

    /// <summary>
    /// Appends a video input to the inputs builder using Base64-encoded bytes and a MIME type.
    /// </summary>
    /// <param name="Data64">
    /// The raw video content encoded as a Base64 string.
    /// </param>
    /// <param name="MimeType">
    /// The IANA MIME type of the video (for example: <c>video/mp4</c>, <c>video/webm</c>).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddVideo(Data64, MimeType)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on the Base64 payload; ensure it is valid and matches
    /// <paramref name="MimeType"/> to avoid request/serialization errors.
    /// </para>
    /// <para>
    /// • Prefer the URI overload (<c>AddVideo(const Uri: string)</c>) when the content is already hosted
    /// and the API supports referencing it, to reduce request size.
    /// </para>
    /// </remarks>
    function AddVideo(const Data64: string; const MimeType: string): TInput; overload;

    /// <summary>
    /// Appends a video input to the inputs builder by referencing the video via a URI.
    /// </summary>
    /// <param name="Uri">
    /// The URI of the video resource to attach (for example, a remote URL or a provider-specific storage URI).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddVideo(Uri)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when the video is already hosted and can be referenced by the API, to avoid
    /// embedding large payloads in the request.
    /// </para>
    /// <para>
    /// • Ensure the referenced URI is accessible to the backend and points to a supported video format;
    /// otherwise the request may fail at ingestion time.
    /// </para>
    /// </remarks>
    function AddVideo(const Uri: string): TInput; overload;

    /// <summary>
    /// Appends a preconstructed video content payload to the inputs builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TVideoContentIxParams</c> instance describing the video content to attach
    /// (for example, a Base64-encoded payload and MIME type, or a URI-based reference),
    /// already configured by the caller.
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddVideo(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you need full control over the video payload structure (e.g. supplying
    /// additional fields supported by <c>TVideoContentIxParams</c>) rather than using the simpler Base64/URI overloads.
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is fully populated and consistent
    /// (e.g. MIME type matches the content, and any referenced URI is accessible) to avoid API ingestion errors.
    /// </para>
    /// </remarks>
    function AddVideo(const Value: TVideoContentIxParams): TInput; overload;

    /// <summary>
    /// Appends a file search result content payload to the inputs builder.
    /// </summary>
    /// <param name="Value">
    /// The <c>TFileSearchResultContentIxParams</c> instance describing the file search result content to attach.
    /// This typically encapsulates one or more search result entries returned by a file search tool invocation.
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddFileSearchResult(Value)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you already have a fully constructed file-search-result content object and want to
    /// attach it as a single input item (as opposed to passing an array of individual result entries).
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure <paramref name="Value"/> is consistent with the expected schema
    /// for file search results (e.g., required fields populated) to avoid downstream serialization or API errors.
    /// </para>
    /// </remarks>
    function AddFileSearchResult(const Value: TFileSearchResultContentIxParams): TInput; overload;

    /// <summary>
    /// Appends a file search result input built from an array of individual result entries.
    /// </summary>
    /// <param name="AResult">
    /// The array of <c>TFileSearchResultIxParams</c> entries to include in the appended file search result payload.
    /// Each entry typically represents one match (document/chunk/metadata) returned by a file search operation.
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddFileSearchResult(AResult)</c>.
    /// </para>
    /// <para>
    /// • Prefer this overload when you are assembling file search results programmatically and already have the
    /// individual result items as an array, without wrapping them in a <c>TFileSearchResultContentIxParams</c>.
    /// </para>
    /// <para>
    /// • The <paramref name="AResult"/> array is attached as-is; no validation or normalization is performed here.
    /// Ensure entries are properly constructed (required identifiers, titles/URIs, snippets, and any tool-specific
    /// metadata) to avoid downstream serialization or API errors.
    /// </para>
    /// <para>
    /// • If you already have a prebuilt container object, use
    /// <c>AddFileSearchResult(const Value: TFileSearchResultContentIxParams)</c> instead.
    /// </para>
    /// </remarks>
    function AddFileSearchResult(const AResult: TArray<TFileSearchResultIxParams>): TInput; overload;

    /// <summary>
    /// Appends a function call input to the builder using a function name, call id, and JSON arguments.
    /// </summary>
    /// <param name="Name">
    /// The name of the function being invoked. It should match a declared tool/function name expected by the model/tooling layer.
    /// </param>
    /// <param name="Id">
    /// The unique identifier for this function call instance. This id is typically echoed back when providing the
    /// corresponding function result so the call/response pair can be correlated.
    /// </param>
    /// <param name="Arguments">
    /// The function call arguments encoded as a JSON object. The object should conform to the function’s declared
    /// parameter schema (property names, types, required fields, etc.).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddFunctionCall(Name, Id, Arguments)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when you already have the arguments as a <c>TJSONObject</c>. If your arguments are already
    /// serialized as a JSON string, use <c>AddFunctionCall(const Name, Id: string; const Arguments: string)</c>.
    /// </para>
    /// <para>
    /// • No schema validation is performed here; ensure <paramref name="Arguments"/> matches the function declaration
    /// to avoid tool execution or API validation errors.
    /// </para>
    /// <para>
    /// • The <paramref name="Id"/> should be stable and unique within the surrounding interaction/turn sequence so that
    /// a later <c>AddFunctionResult(..., Name, CallId)</c> can unambiguously target this call.
    /// </para>
    /// </remarks>
    function AddFunctionCall(const Name, Id: string; const Arguments: TJSONObject): TInput; overload;

    /// <summary>
    /// Appends a function call input to the builder using a function name, call id, and a JSON-encoded argument string.
    /// </summary>
    /// <param name="Name">
    /// The name of the function being invoked. It should match a declared tool/function name expected by the model/tooling layer.
    /// </param>
    /// <param name="Id">
    /// The unique identifier for this function call instance. This id is typically echoed back when providing the
    /// corresponding function result so the call/response pair can be correlated.
    /// </param>
    /// <param name="Arguments">
    /// The function call arguments encoded as a JSON string. The string should represent a JSON object that conforms
    /// to the function’s declared parameter schema (property names, types, required fields, etc.).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddFunctionCall(Name, Id, Arguments)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when your arguments are already serialized (for example, produced by a JSON writer) and you
    /// want to avoid constructing a <c>TJSONObject</c> instance. If you have a <c>TJSONObject</c>, prefer
    /// <c>AddFunctionCall(const Name, Id: string; const Arguments: TJSONObject)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on <paramref name="Arguments"/>. Ensure it is valid JSON and matches the function
    /// declaration; otherwise tool execution or API validation may fail.
    /// </para>
    /// <para>
    /// • The <paramref name="Id"/> should be stable and unique within the surrounding interaction/turn sequence so that
    /// a later <c>AddFunctionResult(..., Name, CallId)</c> can unambiguously target this call.
    /// </para>
    /// </remarks>
    function AddFunctionCall(const Name, Id: string; const Arguments: string): TInput; overload;

    /// <summary>
    /// Appends a function result input to the builder using a JSON-encoded result string.
    /// </summary>
    /// <param name="AResult">
    /// The function execution result encoded as a JSON string. The string should represent a JSON object (or other JSON
    /// value, depending on your tool contract) that matches what the caller/tool declares as its output.
    /// </param>
    /// <param name="Name">
    /// The name of the function this result corresponds to. It should match the function name used in the originating
    /// <c>AddFunctionCall(...)</c>.
    /// </param>
    /// <param name="CallId">
    /// The identifier of the function call this result answers. This must match the <c>Id</c> used when the call was
    /// appended via <c>AddFunctionCall</c>, so the call/result pair can be correlated.
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddFunctionResult(AResult, Name, CallId)</c>.
    /// </para>
    /// <para>
    /// • Use this overload when your function output is already serialized as JSON (for example, produced by a JSON writer)
    /// and you want to avoid constructing a <c>TJSONObject</c>. If you already have a <c>TJSONObject</c>, prefer
    /// <c>AddFunctionResult(const AResult: TJSONObject; const Name, CallId: string)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed on <paramref name="AResult"/>. Ensure it is valid JSON and matches the expected output
    /// schema for the function; otherwise downstream processing or API validation may fail.
    /// </para>
    /// <para>
    /// • If execution failed, you may encode an error payload (for example including an <c>"error"</c> field) as dictated
    /// by your tool/function contract.
    /// </para>
    /// </remarks>
    function AddFunctionResult(const AResult: string; const Name, CallId: string): TInput; overload;

    /// <summary>
    /// Appends a function result input to the builder using a JSON object as the result payload.
    /// </summary>
    /// <param name="AResult">
    /// The function execution result as a JSON object. The object should follow the function/tool output schema
    /// declared for the corresponding function (for example keys like <c>"output"</c>, <c>"result"</c>, or
    /// <c>"error"</c>, depending on your contract).
    /// </param>
    /// <param name="Name">
    /// The name of the function this result corresponds to. It should match the function name used in the originating
    /// <c>AddFunctionCall(...)</c>.
    /// </param>
    /// <param name="CallId">
    /// The identifier of the function call this result answers. This must match the <c>Id</c> used when the call was
    /// appended via <c>AddFunctionCall</c>, so the call/result pair can be correlated.
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddFunctionResult(AResult, Name, CallId)</c>.
    /// </para>
    /// <para>
    /// • The <paramref name="AResult"/> object is attached as-is; no validation is performed here. Ensure it conforms to
    /// the function's declared output schema to avoid downstream validation errors.
    /// </para>
    /// <para>
    /// • Use this overload when you already have a structured <c>TJSONObject</c>. If your result is already serialized as
    /// JSON text, prefer <c>AddFunctionResult(const AResult: string; const Name, CallId: string)</c>.
    /// </para>
    /// <para>
    /// • Ownership/lifetime: this helper does not document whether <c>TInputParams.AddFunctionResult</c> clones or takes
    /// ownership of <paramref name="AResult"/>. Ensure <paramref name="AResult"/> remains valid for as long as the
    /// generated payload needs it, or pass a cloned object if required by your memory management conventions.
    /// </para>
    /// </remarks>
    function AddFunctionResult(const AResult: TJSONObject; const Name, CallId: string): TInput; overload;

    /// <summary>
    /// Appends a raw, preconstructed interaction content payload to the inputs builder.
    /// </summary>
    /// <param name="Value">
    /// The already-built <c>TContentIxParams</c> payload to wrap as an input item. This is a low-level escape hatch
    /// that lets you inject an interaction content structure directly, without using the higher-level typed helpers
    /// (<c>AddText</c>, <c>AddImage</c>, <c>AddAudio</c>, <c>AddDocument</c>, <c>AddFunctionCall</c>, etc.).
    /// </param>
    /// <returns>
    /// The updated <c>TInput</c> builder instance, allowing fluent chaining.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method appends a new <c>TInputParams</c> created via <c>TInputParams.AddRaw(Value)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here; the caller is responsible for ensuring that <paramref name="Value"/> is
    /// well-formed and compatible with the target endpoint/schema.
    /// </para>
    /// <para>
    /// • Prefer the dedicated <c>AddXXX</c> helpers for type safety and readability. Use <c>AddRaw</c> when you need
    /// to attach an input type not yet covered by the fluent API, or when you already have a fully assembled
    /// <c>TContentIxParams</c>.
    /// </para>
    /// <para>
    /// • Ownership/lifetime: this helper does not state whether <c>TInputParams.AddRaw</c> clones or takes ownership of
    /// <paramref name="Value"/>. Ensure <paramref name="Value"/> remains valid for as long as the generated payload
    /// needs it, or pass a copy if your conventions require it.
    /// </para>
    /// </remarks>
    function AddRaw(const Value: TContentIxParams): TInput;
  end;

  TInteractionInput = record
    /// <summary>
    /// Creates a new inputs builder for assembling interaction input items.
    /// </summary>
    /// <returns>
    /// A new <c>TInput</c> builder instance, ready to receive <c>TInputParams</c> elements
    /// via the fluent API.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TInput</c> builder (internally a <c>TArrayBuilder&lt;TInputParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to append input items (text, audio, image, video, documents, function calls/results,
    /// file search results, or raw payloads) using <c>TInputHelper</c> methods such as <c>AddText</c>, <c>AddAudio</c>,
    /// <c>AddImage</c>, <c>AddVideo</c>, <c>AddDocument</c>, <c>AddFunctionCall</c>, <c>AddFunctionResult</c>,
    /// <c>AddFileSearchResult</c>, or <c>AddRaw</c>.
    /// </para>
    /// <para>
    /// • The resulting <c>TArray&lt;TInputParams&gt;</c> is typically passed to turn builders such as
    /// <c>TTurnParams.AddUser(...)</c>, <c>TTurnParams.AddAssistant(...)</c>, or <c>TTurnParams.AddModel(...)</c>
    /// (depending on your role conventions), or to helper methods like <c>TInputContentHelper.AddUser(Content)</c>.
    /// </para>
    /// </remarks>
    class function Inputs: TInput; static;

    /// <summary>
    /// Creates a new <c>TInputParams</c> instance for configuring a single interaction input item.
    /// </summary>
    /// <returns>
    /// A new <c>TInputParams</c> instance, ready to be populated via its fluent API
    /// (for example by setting <c>text</c>, <c>audio</c>, <c>image</c>, <c>video</c>, <c>document</c>,
    /// function call/result payloads, file search result payloads, or other supported content fields).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TInputParams.Create</c>.
    /// </para>
    /// <para>
    /// • Use this method when you want to manually construct a single input item before adding it to an inputs builder.
    /// For fluent accumulation of multiple inputs, prefer <c>Inputs</c> and the <c>TInputHelper.AddXXX</c> methods.
    /// </para>
    /// <para>
    /// • A constructed <c>TInputParams</c> is typically appended to a <c>TInput</c> builder and later attached to a
    /// turn (user/assistant/model) via the turn helpers.
    /// </para>
    /// </remarks>
    class function AddInputParams: TInputParams; static;
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
  private
    class var FConfig: TGenerationConfiguration;
    class var FContent: TGenerationContent;
    class var FTools: TGenerationTool;
    class var FSpeaker: TGenerationSpeaker;
    class var FToolConfig: TGenerationToolConfig;

  public
    class function Empty: TGeneration; static; inline;

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
    /// Provides access to generation-configuration factory helpers.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationConfiguration</c> helper record exposing factory methods for creating
    /// generation-related configuration objects (for example: <c>TGenerationConfig</c>,
    /// <c>TImageConfig</c>, <c>TSpeechConfig</c>, and <c>TThinkingConfig</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This property returns the internal <c>FConfig</c> field and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use it as an entry point to create configuration blocks via <c>Config.AddGenerationConfig</c>,
    /// <c>Config.AddImageConfig</c>, <c>Config.AddSpeechConfig</c>, or <c>Config.AddThinkingConfig</c>,
    /// then attach the resulting instances to a request (for example, through
    /// <c>TChatParams.GenerationConfig(...)</c>).
    /// </para>
    /// <para>
    /// • This property is an ergonomic alias to centralize configuration construction under
    /// <c>TGeneration</c>, keeping calling code compact and consistent.
    /// </para>
    /// </remarks>
    class property Config: TGenerationConfiguration read FConfig;

    /// <summary>
    /// Provides access to generation-content factory helpers.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationContent</c> helper record exposing factory methods for creating
    /// generation-related content objects (for example: text parts, image parts,
    /// audio parts, and other modality-specific generation payloads).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This property returns the internal <c>FContent</c> field and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use it as a centralized entry point to build generation content blocks that are later
    /// attached to generation or interaction requests, keeping content construction separate
    /// from request wiring.
    /// </para>
    /// <para>
    /// • This property is an ergonomic alias that mirrors <c>Config</c>, grouping content-related
    /// factories under <c>TGeneration</c> for consistency and discoverability.
    /// </para>
    /// </remarks>
    class property Content: TGenerationContent read FContent;

    /// <summary>
    /// Provides access to generation-tool factory helpers.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationTool</c> helper record exposing factory methods for creating
    /// generation-related tool declarations (for example: function tools, search tools,
    /// code execution tools, or other tool descriptors supported by the generation APIs).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This property returns the internal <c>FTools</c> field and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use it as a centralized entry point to declare and configure tools that may be
    /// invoked by the model during generation, then attach those declarations to the
    /// appropriate request payload.
    /// </para>
    /// <para>
    /// • This property complements <c>Config</c> and <c>Content</c>, grouping tool-related
    /// factories under <c>TGeneration</c> for a coherent, discoverable API surface.
    /// </para>
    /// </remarks>
    class property Tools: TGenerationTool read FTools;

    /// <summary>
    /// Provides access to speaker/voice factory helpers used for speech generation.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationSpeaker</c> helper record exposing factory methods for creating
    /// speaker- and voice-related configuration objects (for example: selecting a voice,
    /// language/locale, gender, or other speaker attributes supported by the speech pipeline).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This property returns the internal <c>FSpeaker</c> field and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use this property when configuring speech output in generation or interaction requests,
    /// typically in conjunction with <c>Config.AddSpeechConfig</c> or similar speech-related
    /// configuration helpers.
    /// </para>
    /// <para>
    /// • This property complements <c>Content</c> (what is generated) and <c>Tools</c>/<c>ToolConfig</c>
    /// (how tools are used), grouping speaker-specific concerns under <c>TGeneration</c> for
    /// a consistent and discoverable API surface.
    /// </para>
    /// </remarks>
    class property Speaker: TGenerationSpeaker read FSpeaker;

    /// <summary>
    /// Provides access to tool-configuration factory helpers used to control tool behavior in requests.
    /// </summary>
    /// <returns>
    /// A <c>TGenerationToolConfig</c> helper record exposing factory methods for creating tool
    /// configuration objects (for example: <c>TToolConfig</c>, <c>TFunctionCallingConfig</c>,
    /// <c>TRetrievalConfig</c>, and related helper payloads such as <c>TLatLng</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This property returns the internal <c>FToolConfig</c> field and does not allocate objects.
    /// </para>
    /// <para>
    /// • Use this property to build the <c>toolConfig</c> section of generation/chat requests,
    /// configuring function calling modes (AUTO/ANY/VALIDATED), restricting allowed functions,
    /// and tuning retrieval context (language and optional geographic coordinates).
    /// </para>
    /// <para>
    /// • This property is typically used together with <c>Tools</c> (declaring available tools)
    /// and then attached to the request parameters (for example via <c>TChatParams.ToolConfig(...)</c>).
    /// </para>
    /// </remarks>
    class property ToolConfig: TGenerationToolConfig read FToolConfig;

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
  end;

  TRaw = record
    class function Empty: TRaw; static; inline;

    /// <summary>
    /// Creates a new raw <c>image</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TImageContentIxParams</c> instance with <c>type = "image"</c> already set,
    /// ready to be further configured (for example via <c>Data(...)</c>/<c>Uri(...)</c>,
    /// <c>MimeType(...)</c>, and optional <c>Resolution(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is intended for “raw” content construction when you want to build a
    /// fully-typed Interactions content block directly, rather than using convenience wrappers
    /// (such as <c>TInputParams.AddImage(...)</c> or <c>TInputHelper.AddImage(...)</c>).
    /// </para>
    /// <para>
    /// • Typical usage is to build the content with this function, then inject it into an input
    /// via <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here beyond what <c>TImageContentIxParams</c> enforces; ensure
    /// the MIME type and payload (Base64 or URI) match the Interactions API expectations.
    /// </para>
    /// </remarks>
    class function ImageContent: TImageContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>audio</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TAudioContentIxParams</c> instance with <c>type = "audio"</c> already set,
    /// ready to be further configured (for example via <c>Data(...)</c>/<c>Uri(...)</c> and
    /// <c>MimeType(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is intended for “raw” content construction when you want to assemble a
    /// fully-typed Interactions content block directly, rather than using convenience wrappers
    /// (such as <c>TInputParams.AddAudio(...)</c> or <c>TInputHelper.AddAudio(...)</c>).
    /// </para>
    /// <para>
    /// • Typical usage is to build the content with this function, then inject it into an input
    /// via <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here beyond what <c>TAudioContentIxParams</c> enforces; ensure
    /// the MIME type and payload (Base64 or URI) match the Interactions API expectations.
    /// </para>
    /// </remarks>
    class function TAudioContent: TAudioContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>document</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TDocumentContentIxParams</c> instance with <c>type = "document"</c> already set,
    /// ready to be further configured (for example via <c>Data(...)</c>/<c>Uri(...)</c> and
    /// <c>MimeType(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is intended for “raw” content construction when you want to assemble a
    /// fully-typed Interactions content block directly, rather than using higher-level
    /// convenience wrappers such as <c>TInputParams.AddDocument(...)</c> or
    /// <c>TInputHelper.AddDocument(...)</c>.
    /// </para>
    /// <para>
    /// • Typical usage is to build the content with this function, then inject it into an input
    /// via <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here beyond what <c>TDocumentContentIxParams</c> enforces;
    /// ensure the MIME type and payload (Base64 or URI) comply with the Interactions API
    /// expectations (currently <c>application/pdf</c> only).
    /// </para>
    /// </remarks>
    class function DocumentContent: TDocumentContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>video</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TVideoContentIxParams</c> instance with <c>type = "video"</c> already set,
    /// ready to be further configured (for example via <c>Data(...)</c>/<c>Uri(...)</c>,
    /// <c>MimeType(...)</c>, and optional <c>Resolution(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is intended for “raw” content construction when you want to assemble a
    /// fully-typed Interactions content block directly, rather than using higher-level
    /// convenience wrappers such as <c>TInputParams.AddVideo(...)</c> or
    /// <c>TInputHelper.AddVideo(...)</c>.
    /// </para>
    /// <para>
    /// • Typical usage is to build the content with this function, then inject it into an input
    /// via <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • No validation is performed here beyond what <c>TVideoContentIxParams</c> enforces;
    /// ensure the MIME type and payload (Base64 or URI) comply with the Interactions API
    /// expectations.
    /// </para>
    /// </remarks>
    class function VideoContent: TVideoContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>thought</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TThoughtContentIxParams</c> instance with <c>type = "thought"</c> already set,
    /// ready to be further configured (for example via <c>Signature(...)</c> and
    /// <c>Summary(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is intended for advanced or low-level usage where a <c>thought</c> content
    /// block must be constructed explicitly, rather than relying on higher-level helpers that
    /// abstract away internal model reasoning structures.
    /// </para>
    /// <para>
    /// • A <c>thought</c> content block is typically used to carry model thinking metadata,
    /// including a backend signature and a summarized representation of the thought process,
    /// as defined by the Interactions API.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>, allowing precise
    /// control over the generated JSON structure.
    /// </para>
    /// <para>
    /// • No additional validation is performed by this factory; callers are responsible for
    /// ensuring that the constructed content complies with the Interactions schema and any
    /// backend requirements regarding signatures or summaries.
    /// </para>
    /// </remarks>
    class function ThoughtContent: TThoughtContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>function_call</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TFunctionCallContentIxParams</c> instance with <c>type = "function_call"</c> already set,
    /// ready to be further configured (for example via <c>Name(...)</c>, <c>Id(...)</c> and
    /// <c>Arguments(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is intended for advanced or low-level usage where a tool invocation block must be
    /// authored explicitly (for example when replaying a tool trace, mirroring server-provided calls,
    /// or constructing structured interaction histories).
    /// </para>
    /// <para>
    /// • The typical minimum fields for a valid function call content are:
    /// <c>Name</c> (tool name), <c>Id</c> (unique call identifier), and <c>Arguments</c> (JSON object or
    /// JSON string that parses to an object). Ensure these are set before sending the payload.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • When using the <c>Arguments(const Value: string)</c> overload, the string is expected to be a valid
    /// JSON object representation; invalid JSON will raise an exception in the underlying builder.
    /// </para>
    /// </remarks>
    class function FunctionCallContent: TFunctionCallContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>function_result</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TFunctionResultContentIxParams</c> instance with <c>type = "function_result"</c> already set,
    /// ready to be further configured (for example via <c>Name(...)</c>, <c>CallId(...)</c>,
    /// <c>IsError(...)</c> and <c>Result(...)</c> / <c>ResultText(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper when you need to inject an explicit tool/function output block into an Interactions
    /// history (for example to replay tool traces, provide structured context, or mirror server-produced results).
    /// </para>
    /// <para>
    /// • A function result content should usually include:
    /// <c>Name</c> (tool name) and <c>CallId</c> (the id from the corresponding <c>function_call</c> block),
    /// plus the actual result via <c>Result(...)</c> (JSON object or JSON string) or <c>ResultText(...)</c>.
    /// </para>
    /// <para>
    /// • If the tool execution failed, set <c>IsError(True)</c> and include error details in the result payload
    /// (for example an <c>{"error": ...}</c> object or a descriptive string).
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • When using the <c>Result(const Value: string)</c> overload, the string is expected to be a valid
    /// JSON object representation; invalid JSON will raise an exception in the underlying builder.
    /// If you need to pass plain text without JSON parsing, prefer <c>ResultText(...)</c>.
    /// </para>
    /// </remarks>
    class function FunctionResultContent: TFunctionResultContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>code_execution_call</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TCodeExecutionCallContentIxParams</c> instance with <c>type = "code_execution_call"</c> already set,
    /// ready to be further configured (for example via <c>Arguments(...)</c> and <c>Id(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject a code execution tool call block into an Interactions history
    /// (for example, when replaying tool traces or providing a fully-specified call/result pair).
    /// </para>
    /// <para>
    /// • The call content typically includes:
    /// <c>Arguments</c> (either a <c>TCodeExecutionCallArgumentsIxParams</c> instance, a <c>TJSONObject</c>,
    /// or a JSON string representing an object), and an <c>Id</c> used to correlate with the
    /// corresponding <c>code_execution_result</c> via <c>CallId</c>.
    /// </para>
    /// <para>
    /// • When using the <c>Arguments(const Value: string)</c> overload, the string must represent a valid
    /// JSON object; invalid JSON will raise an exception in the underlying builder.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • For the common case, build arguments with:
    /// <c>TCodeExecutionCallArgumentsIxParams.New.Language(...).Code(...)</c>.
    /// </para>
    /// </remarks>
    class function CodeExecutionCallContent: TCodeExecutionCallContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>code_execution_result</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TCodeExecutionResultContentIxParams</c> instance with <c>type = "code_execution_result"</c> already set,
    /// ready to be further configured (for example via <c>Result(...)</c>, <c>IsError(...)</c>, <c>Signature(...)</c>,
    /// and <c>CallId(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject a code execution tool result block into an Interactions history,
    /// typically paired with a preceding <c>code_execution_call</c> block.
    /// </para>
    /// <para>
    /// • Correlation: set <c>CallId</c> to the same identifier used by the corresponding
    /// <c>TCodeExecutionCallContentIxParams.Id(...)</c> so the backend (and clients) can match call ↔ result.
    /// </para>
    /// <para>
    /// • The <c>Result</c> field carries the output (stdout/stderr or a textual summary, depending on your integration).
    /// If execution failed, set <c>IsError(True)</c> and include an error description in <c>Result</c>.
    /// </para>
    /// <para>
    /// • <c>Signature</c> may be required when replaying server-signed tool outputs; it is used for backend validation.
    /// Omit it unless you are copying a value provided by the service.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function CodeExecutionResultContent: TCodeExecutionResultContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>url_context_call</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TUrlContextCallContentIxParams</c> instance with <c>type = "url_context_call"</c> already set,
    /// ready to be further configured (for example via <c>Arguments(...)</c> and <c>Id(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject a URL Context tool call block into an Interactions history,
    /// typically followed by a matching <c>url_context_result</c> block.
    /// </para>
    /// <para>
    /// • Provide the call payload using <c>Arguments</c>:
    /// either build strongly-typed arguments via <c>TUrlContextCallArgumentsIxParams.New(...)</c>
    /// or pass a <c>TJSONObject</c>/<c>string</c> containing a valid JSON object.
    /// </para>
    /// <para>
    /// • Correlation: set <c>Id</c> to a unique identifier for this tool call, and set the corresponding
    /// result block’s <c>CallId</c> to the same value so the backend (and clients) can match call ↔ result.
    /// </para>
    /// <para>
    /// • When passing JSON as a string to <c>Arguments(const Value: string)</c>, the implementation validates/parses
    /// it and raises an exception if it is not a valid JSON object.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function UrlContextCallContent: TUrlContextCallContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>url_context_result</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TUrlContextResultContentIxParams</c> instance with <c>type = "url_context_result"</c> already set,
    /// ready to be further configured (for example via <c>Result(...)</c>, <c>IsError(...)</c>, and <c>CallId(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject the result of a URL Context tool call into an Interactions history.
    /// This block typically follows a matching <c>url_context_call</c> block.
    /// </para>
    /// <para>
    /// • Populate the fetched URL list using <c>Result(const Value: TArray&lt;TUrlContextResultIxParams&gt;)</c>.
    /// Each item usually includes the fetched <c>Url</c> and a retrieval <c>Status</c>.
    /// </para>
    /// <para>
    /// • Correlation: set <c>CallId</c> to the same identifier used by the corresponding
    /// <c>url_context_call</c> block’s <c>Id</c> so the backend (and clients) can match call ↔ result.
    /// </para>
    /// <para>
    /// • Error signalling: when the URL context execution failed as a whole, set <c>IsError(True)</c>.
    /// You may still include partial results depending on the upstream provider behavior.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function UrlContextResultContent: TUrlContextResultContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>google_search_call</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TGoogleSearchCallContentIxParams</c> instance with <c>type = "google_search_call"</c> already set,
    /// ready to be further configured (for example via <c>Arguments(...)</c> and <c>Id(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to explicitly inject a Google Search tool call block into an
    /// Interactions history, typically followed by a matching
    /// <c>google_search_result</c> block.
    /// </para>
    /// <para>
    /// • The call payload is provided via <c>Arguments</c>, which may be constructed using
    /// <c>TGoogleSearchCallArgumentsIxParams.NewQueries(...)</c> or supplied directly as a
    /// <c>TJSONObject</c> / JSON string representing a valid object.
    /// </para>
    /// <para>
    /// • Correlation: assign a unique identifier with <c>Id(...)</c> and reuse the same value
    /// in the corresponding result block’s <c>CallId</c> so the backend (and clients) can
    /// associate call and result.
    /// </para>
    /// <para>
    /// • When passing JSON as a string to <c>Arguments(const Value: string)</c>, the underlying
    /// builder validates and parses it; invalid JSON will raise an exception.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function GoogleSearchCallContent: TGoogleSearchCallContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>google_search_result</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TGoogleSearchResultContentIxParams</c> instance with <c>type = "google_search_result"</c> already set,
    /// ready to be populated (for example via <c>Signature(...)</c>, <c>Result(...)</c>, <c>IsError(...)</c>,
    /// and <c>CallId(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject Google Search tool results into an Interactions history, typically as the
    /// structured counterpart of a preceding <c>google_search_call</c> block.
    /// </para>
    /// <para>
    /// • Correlation: set <c>CallId(...)</c> to the same identifier used in the corresponding call block’s
    /// <c>Id(...)</c> so the backend (and clients) can match call and result.
    /// </para>
    /// <para>
    /// • Populate the actual search output using <c>Result(const Value: TArray&lt;TGoogleSearchResultIxParams&gt;)</c>.
    /// Each entry can be built with <c>TGoogleSearchResultIxParams.New</c> and then configured (e.g. <c>Url</c>,
    /// <c>Title</c>, <c>RenderedContent</c>).
    /// </para>
    /// <para>
    /// • If the retrieval failed, mark <c>IsError(True)</c>. You may still include partial/diagnostic entries in
    /// <c>Result</c> depending on what you want to replay upstream.
    /// </para>
    /// <para>
    /// • When replaying backend-provided results, include <c>Signature(...)</c> if available so the backend can
    /// validate the provenance of the result block.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function GoogleSearchResultContent: TGoogleSearchResultContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>mcp_server_tool_call</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TMcpServerToolCallContentIxParams</c> instance with <c>type = "mcp_server_tool_call"</c> already set,
    /// ready to be populated (for example via <c>Name(...)</c>, <c>ServerName(...)</c>, <c>Arguments(...)</c>,
    /// and <c>Id(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject an MCP server tool invocation into an Interactions turn, typically when replaying
    /// tool traces or when you want the model to see the exact structured call that was (or should be) executed.
    /// </para>
    /// <para>
    /// • Correlation: set <c>Id(...)</c> to a unique identifier for this call so it can be matched with the
    /// corresponding <c>mcp_server_tool_result</c> block (via its <c>CallId(...)</c>).
    /// </para>
    /// <para>
    /// • Tool identity: set <c>Name(...)</c> to the tool/function name and <c>ServerName(...)</c> to the MCP server
    /// identifier that should handle the call.
    /// </para>
    /// <para>
    /// • Arguments may be provided either as a <c>TJSONObject</c> or as a JSON string. When provided as a string,
    /// it is parsed/validated by <c>TMcpServerToolCallContentIxParams.Arguments(const Value: string)</c> and will
    /// raise an exception if the JSON is invalid.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function McpServerToolCallContent: TMcpServerToolCallContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>mcp_server_tool_result</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TMcpServerToolResultContentIxParams</c> instance with <c>type = "mcp_server_tool_result"</c> already set,
    /// ready to be populated (for example via <c>Name(...)</c>, <c>ServerName(...)</c>, <c>Result(...)</c>,
    /// and <c>CallId(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject the structured result of an MCP server tool invocation into an Interactions turn,
    /// typically when replaying tool traces (tool call + tool result) as conversation context.
    /// </para>
    /// <para>
    /// • Correlation: set <c>CallId(...)</c> to the same identifier used by the corresponding
    /// <c>mcp_server_tool_call</c> block (<c>TMcpServerToolCallContentIxParams.Id(...)</c>) so consumers can match
    /// the result to the originating call.
    /// </para>
    /// <para>
    /// • Tool identity: set <c>Name(...)</c> to the tool/function name and <c>ServerName(...)</c> to the MCP server
    /// that produced the result.
    /// </para>
    /// <para>
    /// • Result payload: provide either a <c>TJSONObject</c> (preferred for already-built JSON) or a JSON string.
    /// This overload does not enforce schema; ensure it matches the tool’s expected contract.
    /// </para>
    /// <para>
    /// • The returned instance can be injected into an input payload using
    /// <c>TInputParams.AddRaw(...)</c> or <c>TInputHelper.AddRaw(...)</c>.
    /// </para>
    /// </remarks>
    class function McpServerToolResultContent: TMcpServerToolResultContentIxParams; static;

    /// <summary>
    /// Creates a new raw <c>file_search_result</c> content builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TFileSearchResultContentIxParams</c> instance with <c>type = "file_search_result"</c> already set,
    /// ready to be populated (typically via <c>Result(...)</c>) before being wrapped into an input item.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to inject retrieval output from a File Search tool into an Interactions turn,
    /// usually as context for subsequent model reasoning or as a replay of a prior tool trace.
    /// </para>
    /// <para>
    /// • Populate the returned instance with one or more result items using <c>Result(...)</c>, passing an array of
    /// <c>TFileSearchResultIxParams</c> built via their fluent setters (for example <c>Title(...)</c>, <c>Text(...)</c>,
    /// <c>FileSearchStore(...)</c>).
    /// </para>
    /// <para>
    /// • This builder represents the discriminated content block only; to include it in an interaction input array,
    /// wrap it using <c>TInputParams.AddRaw(...)</c> (or use higher-level helpers such as
    /// <c>TInputHelper.AddFileSearchResult(...)</c>).
    /// </para>
    /// <para>
    /// • No validation is performed here; ensure the payload matches the backend schema expected for
    /// <c>file_search_result</c>.
    /// </para>
    /// </remarks>
    class function FileSearchResultContent: TFileSearchResultContentIxParams; static;
  end;

  TRawItem = record
    class function Empty: TRawItem; static; inline;

    /// <summary>
    /// Creates a new <c>TAllowedToolsIxParams</c> instance for constraining or guiding
    /// tool selection during an interaction.
    /// </summary>
    /// <returns>
    /// A new <c>TAllowedToolsIxParams</c> instance, ready to be configured via its fluent API
    /// (for example, to restrict the model to a subset of tools, force a specific tool,
    /// or disable tool usage entirely, depending on what the type supports).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TAllowedToolsIxParams.Create</c>.
    /// </para>
    /// <para>
    /// • Use this when you want explicit control over tool choice behavior for the
    /// <c>/interactions</c> endpoint, instead of relying on the model’s automatic
    /// tool selection.
    /// </para>
    /// <para>
    /// • The returned instance is empty by default; callers must configure the desired
    /// constraints (allowed tool names, modes, or policies) before attaching it to the
    /// interaction request payload.
    /// </para>
    /// </remarks>
    class function AddToolChoice: TAllowedToolsIxParams; static;

    /// <summary>
    /// Creates a new <c>TSpeechConfigIxParams</c> instance for configuring speech synthesis
    /// in an interaction request.
    /// </summary>
    /// <returns>
    /// A new <c>TSpeechConfigIxParams</c> instance, ready to be configured via its fluent API
    /// (for example, audio format/encoding, voice selection, speaking rate, or other
    /// speech-related options supported by the Interactions schema).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TSpeechConfigIxParams.Create</c>.
    /// </para>
    /// <para>
    /// • Use this method when you want the <c>/interactions</c> endpoint to produce (or be able
    /// to produce) speech output, and you need to attach a speech configuration block to the
    /// request payload.
    /// </para>
    /// <para>
    /// • The returned instance is empty by default; configure the desired fields before
    /// attaching it to your interaction request parameters.
    /// </para>
    /// </remarks>
    class function AddSpeechConfig: TSpeechConfigIxParams; static;

    /// <summary>
    /// Creates a new Google Search result item builder for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A fresh <c>TGoogleSearchResultIxParams</c> instance, ready to be populated via the fluent API
    /// (for example <c>Url(...)</c>, <c>Title(...)</c>, <c>RenderedContent(...)</c>) before being added
    /// to a <c>google_search_result</c> content block.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use this helper to construct individual entries that will be placed inside
    /// <c>TGoogleSearchResultContentIxParams.Result(...)</c>.
    /// </para>
    /// <para>
    /// • This method creates only the item object (a single search result). To emit a full content block,
    /// wrap the array of items into <c>TGoogleSearchResultContentIxParams</c> (for example via
    /// <c>TRaw.GoogleSearchResultContent</c>) and then wrap that content into an input item using
    /// <c>TInputParams.AddRaw(...)</c> (or a higher-level helper).
    /// </para>
    /// <para>
    /// • No automatic validation is performed on the URL or the rendered snippet; ensure the values
    /// match what your backend/tooling expects.
    /// </para>
    /// </remarks>
    class function AddGoogleSearchResult: TGoogleSearchResultIxParams; static;
  end;

  TInteractions = record
  private
    class var FRaw: TRaw;
    class var FRawItem: TRawItem;
    class var FTool: TInteractionTool;
    class var FInput: TInteractionInput;
  public
    class function Empty: TInteractions; static; inline;

    /// <summary>
    /// Provides access to the low-level “raw” content builders used for Interactions payloads.
    /// </summary>
    /// <returns>
    /// A <c>TRaw</c> helper record exposing factory methods that create typed
    /// <c>*ContentIxParams</c> instances (for example image/audio/document/video/thought/function-call/result blocks),
    /// ready to be populated via their fluent setters and then injected through <c>AddRaw(...)</c>.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use <c>Raw</c> when you need to construct a specific Interactions content block explicitly
    /// (e.g., <c>function_call</c>, <c>function_result</c>, <c>url_context_result</c>) or when you need fields
    /// not covered by the higher-level convenience helpers.
    /// </para>
    /// <para>
    /// • Typical flow: build a typed content instance via <c>Raw</c>, configure it (e.g. <c>MimeType</c>,
    /// <c>Resolution</c>, <c>CallId</c>, <c>Signature</c>), then wrap it into an input item with
    /// <c>TInputParams.AddRaw(...)</c> (or via <c>TInputHelper.AddRaw(...)</c>), and finally add that input
    /// item to a turn.
    /// </para>
    /// <para>
    /// • <c>Raw</c> is a convenience façade only; it does not store state and simply returns a helper record
    /// that centralizes access to the underlying builders.
    /// </para>
    /// </remarks>
    class property Raw: TRaw read FRaw;

    /// <summary>
    /// Provides access to the low-level “raw item” builders used for Interactions result entries.
    /// </summary>
    /// <returns>
    /// A <c>TRawItem</c> helper record exposing factory methods that create typed result-item
    /// parameter instances (for example <c>TGoogleSearchResultIxParams</c>, <c>TFileSearchResultIxParams</c>,
    /// or <c>TUrlContextResultIxParams</c>), ready to be populated via their fluent setters and then
    /// inserted into their corresponding result content blocks.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use <c>RawItem</c> when you need to manually assemble arrays of result entries that are embedded
    /// inside higher-level Interactions content types, such as <c>google_search_result</c>,
    /// <c>file_search_result</c>, or <c>url_context_result</c>.
    /// </para>
    /// <para>
    /// • Typical flow: create one or more result items via <c>RawItem</c>, configure them (e.g. <c>Url</c>,
    /// <c>Title</c>, <c>RenderedContent</c>, <c>Status</c>, <c>FileSearchStore</c>), then attach the resulting
    /// array to the corresponding content builder (e.g. <c>Raw.GoogleSearchResultContent.Result(...)</c>),
    /// and finally inject the content into an input item/turn via <c>AddRaw(...)</c>.
    /// </para>
    /// <para>
    /// • <c>RawItem</c> is a convenience façade only; it does not store state and simply returns a helper record
    /// that centralizes access to the underlying item builders.
    /// </para>
    /// </remarks>
    class property RawItem: TRawItem read FRawItem;

    /// <summary>
    /// Provides access to factory helpers for building the <c>input</c> items used by the
    /// <c>/interactions</c> request payload.
    /// </summary>
    /// <returns>
    /// A <c>TInteractionInput</c> façade exposing input builders, including <c>Inputs</c> for
    /// assembling a <c>TArray&lt;TInputParams&gt;</c> and <c>AddInputParams</c> for creating a single
    /// <c>TInputParams</c> item.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use <c>Input.Inputs</c> when you want to build one or more input items via the fluent
    /// <c>TInputHelper.AddXXX</c> methods (text, audio, image, video, documents, function call/result,
    /// file search result, or raw blocks).
    /// </para>
    /// <para>
    /// • Use <c>Input.AddInputParams</c> when you need to manually configure a single input item before
    /// appending it to an inputs builder.
    /// </para>
    /// <para>
    /// • The resulting <c>TArray&lt;TInputParams&gt;</c> is typically attached to a turn using helpers
    /// such as <c>TTurnParams.AddUser(...)</c>, <c>TTurnParams.AddAssistant(...)</c>, or
    /// <c>TTurnParams.AddModel(...)</c>, depending on the role conventions of your request.
    /// </para>
    /// <para>
    /// • <c>Input</c> is a convenience façade only; it does not store state and simply returns
    /// helper builders.
    /// </para>
    /// </remarks>
    class property Input: TInteractionInput read FInput;

    /// <summary>
    /// Provides access to factory helpers for declaring the <c>tools</c> available to the
    /// <c>/interactions</c> request.
    /// </summary>
    /// <returns>
    /// A <c>TInteractionTool</c> façade exposing a <c>Tools</c> array builder (for assembling a
    /// <c>TArray&lt;TToolIxParams&gt;</c>) and convenience factories for common tool declarations such as
    /// function calling, Google Search, code execution, URL context, computer use, MCP servers, and file search.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Use <c>Tool.Tools</c> when you want to build a toolset fluently via the
    /// <c>TToolIxHelper.AddXXX</c> methods.
    /// </para>
    /// <para>
    /// • Use the <c>Tool.AddXXX</c> factories to create a single typed tool configuration
    /// (<c>TFunctionIxParams</c>, <c>TGoogleSearchIxParams</c>, <c>TCodeExecutionIxParams</c>,
    /// <c>TUrlContextIxParams</c>, <c>TComputerUseIxParams</c>, <c>TMcpServerIxParams</c>,
    /// <c>TFileSearchIxParams</c>) and then append it to a tools builder.
    /// </para>
    /// <para>
    /// • The resulting tool array is typically attached to the interaction payload so the model may invoke
    /// the declared tools during a turn.
    /// </para>
    /// <para>
    /// • <c>Tool</c> is a convenience façade only; it does not store state and simply returns helper builders.
    /// </para>
    /// </remarks>
    class property Tool: TInteractionTool read FTool;

    /// <summary>
    /// Creates a new <c>TGenerationConfigIxParams</c> instance for configuring generation options
    /// used by the <c>/interactions</c> endpoint.
    /// </summary>
    /// <returns>
    /// A new <c>TGenerationConfigIxParams</c> instance, ready to be configured via its fluent API
    /// (for example, token limits, sampling controls, modality-specific output options, etc.,
    /// depending on what your config type exposes).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience factory that returns <c>TGenerationConfigIxParams.Create</c>.
    /// </para>
    /// <para>
    /// • Use this when you need to attach a generation configuration block to an interactions request,
    /// rather than using the chat request configuration types (e.g. <c>TGenerationConfig</c>) used by
    /// other endpoints in this codebase.
    /// </para>
    /// <para>
    /// • The returned instance is empty by default; callers must set the desired options explicitly
    /// before attaching it to the request payload.
    /// </para>
    /// </remarks>
    class function AddConfig: TGenerationConfigIxParams; static;

    /// <summary>
    /// Creates a new inputs builder for assembling the <c>input[]</c> array used by the
    /// <c>/interactions</c> endpoint.
    /// </summary>
    /// <returns>
    /// A new <c>TInput</c> builder instance, ready to receive <c>TInputParams</c> items
    /// via the fluent API (for example <c>AddText</c>, <c>AddImage</c>, <c>AddAudio</c>, etc.).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper is a convenience alias that returns <c>TInteractionInput.Inputs</c>.
    /// </para>
    /// <para>
    /// • Use the returned builder to compose one or more input blocks (text, image, audio, document, video,
    /// function call/result, file search results, or raw content), then pass the resulting
    /// <c>TArray&lt;TInputParams&gt;</c> to the appropriate request parameter (for example the interactions input payload).
    /// </para>
    /// <para>
    /// • The builder itself does not validate the semantic correctness of individual items; each
    /// <c>TInputParams</c> must be constructed with the appropriate content type and required fields.
    /// </para>
    /// </remarks>
    class function Inputs: TInput; static;

    /// <summary>
    /// Creates a new turns builder for assembling the <c>turns[]</c> array used by the
    /// <c>/interactions</c> endpoint.
    /// </summary>
    /// <returns>
    /// A new <c>TTurn</c> builder instance, ready to receive <c>TTurnParams</c> items
    /// via the fluent API (for example <c>AddUser</c>, <c>AddAssistant</c>/<c>AddModel</c>, etc.).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TTurn</c> builder (internally a <c>TArrayBuilder&lt;TTurnParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to compose an interaction history as role-tagged turns.
    /// Each appended item typically wraps either a simple text message or a multi-input turn
    /// built from an array of <c>TInputParams</c> (text, media, tool traces, etc.).
    /// </para>
    /// <para>
    /// • The builder does not enforce role semantics; ensure you use the correct helper
    /// (<c>AddUser</c> vs <c>AddAssistant</c>/<c>AddModel</c>) for the intended turn origin.
    /// </para>
    /// </remarks>
    class function Turns: TTurn; static;

    /// <summary>
    /// Creates a new tools builder for assembling the <c>tools[]</c> array used by the
    /// <c>/interactions</c> endpoint.
    /// </summary>
    /// <returns>
    /// A new <c>TToolIx</c> builder instance, ready to receive <c>TToolIxParams</c> entries
    /// via the fluent API (for example <c>AddFunction</c>, <c>AddGoogleSearch</c>,
    /// <c>AddCodeExecution</c>, <c>AddUrlContext</c>, <c>AddFileSearch</c>, etc.).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TToolIx</c> builder (internally a <c>TArrayBuilder&lt;TToolIxParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to declare which tools are available to the model during an
    /// interaction, then pass the resulting array into the appropriate interactions request
    /// parameters (tool declarations / tool configuration payload, depending on your endpoint wrapper).
    /// </para>
    /// <para>
    /// • The builder only aggregates declarations; it does not execute tools. Tool execution
    /// is represented separately in the interaction content via function call/result blocks.
    /// </para>
    /// </remarks>
    class function Tools: TToolIx; static;

    /// <summary>
    /// Creates a new Google Search results builder for assembling
    /// <c>google_search_result</c> items in interaction content.
    /// </summary>
    /// <returns>
    /// A new <c>TGoogleSearchResult</c> builder instance, ready to receive
    /// <c>TGoogleSearchResultIxParams</c> entries via the fluent API (typically using
    /// <c>AddItem</c> and then configuring the returned params object with fields such as
    /// <c>Url</c>, <c>Title</c>, and <c>RenderedContent</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TGoogleSearchResult</c> builder (internally a
    /// <c>TArrayBuilder&lt;TGoogleSearchResultIxParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder when constructing a <c>google_search_result</c> content block
    /// (for example via <c>TGoogleSearchResultContentIxParams.Result(...)</c> or equivalent),
    /// in order to attach one or more search result entries to an interaction turn.
    /// </para>
    /// <para>
    /// • The builder only accumulates result items; it does not perform any retrieval.
    /// Retrieval/tool execution is represented elsewhere (e.g., by a
    /// <c>google_search_call</c> followed by a <c>google_search_result</c> in the turn content).
    /// </para>
    /// </remarks>
    class function GoogleSearchResults: TGoogleSearchResult; static;

    /// <summary>
    /// Creates a new thought summaries builder for assembling <c>thought</c> summary items
    /// in interaction content.
    /// </summary>
    /// <returns>
    /// A new <c>TThoughtSummary</c> builder instance, ready to receive
    /// <c>TThoughtSummaryIxParams</c> entries via the fluent API (typically using
    /// <c>AddText</c> to append summary text blocks).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TThoughtSummary</c> builder (internally a
    /// <c>TArrayBuilder&lt;TThoughtSummaryIxParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to build the array passed to
    /// <c>TThoughtContentIxParams.Summary(...)</c>, representing one or more summary segments
    /// for a <c>thought</c> content block.
    /// </para>
    /// <para>
    /// • This builder only constructs the JSON-ready summary payload; it does not influence
    /// model reasoning. Any “thought” data included here is meant for replaying or attaching
    /// server-provided thought summaries (and related signatures) in interaction histories.
    /// </para>
    /// </remarks>
    class function ThoughtSummaries: TThoughtSummary; static;

    /// <summary>
    /// Creates a new file search results builder for assembling <c>file_search_result</c>
    /// items in interaction content.
    /// </summary>
    /// <returns>
    /// A new <c>TFileSearchResult</c> builder instance, ready to receive
    /// <c>TFileSearchResultIxParams</c> entries via the fluent API (for example, with
    /// <c>AddItem(...)</c> overloads).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TFileSearchResult</c> builder (internally a
    /// <c>TArrayBuilder&lt;TFileSearchResultIxParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to build the array passed to
    /// <c>TFileSearchResultContentIxParams.Result(...)</c>, representing one or more chunks
    /// returned by a file search store.
    /// </para>
    /// <para>
    /// • This builder only prepares JSON-ready payloads for interaction history/replay; it
    /// does not perform any search itself and does not validate that chunks come from an
    /// existing store.
    /// </para>
    /// </remarks>
    class function FileSearchResults: TFileSearchResult; static;

    /// <summary>
    /// Creates a new URL context results builder for assembling <c>url_context_result</c>
    /// entries in interaction content.
    /// </summary>
    /// <returns>
    /// A new <c>TUrlContextResult</c> builder instance, ready to receive
    /// <c>TUrlContextResultIxParams</c> items via the fluent API (for example, with
    /// <c>AddItem(...)</c>).
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This helper returns a fresh <c>TUrlContextResult</c> builder (internally a
    /// <c>TArrayBuilder&lt;TUrlContextResultIxParams&gt;</c>).
    /// </para>
    /// <para>
    /// • Use the returned builder to build the array passed to
    /// <c>TUrlContextResultContentIxParams.Result(...)</c>, representing one or more fetched
    /// URLs and their associated status.
    /// </para>
    /// <para>
    /// • This builder only prepares JSON-ready payloads for interaction history/replay; it
    /// does not fetch URLs, validate reachability, or enforce status semantics.
    /// </para>
    /// </remarks>
    class function UrlContextResults: TUrlContextResult; static;
  end;

/// <summary>
/// Creates a new <c>TGeneration</c> facade exposing the fluent builders used to assemble
/// Gemini generation/chat payloads.
/// </summary>
/// <returns>
/// A <c>TGeneration</c> record providing entry points for building request content (<c>Contents</c>/<c>Parts</c>),
/// tools (<c>Tools</c>), tool configuration (<c>ToolConfig</c>), speaker/voice configuration (<c>Speaker</c>),
/// and generation configuration (<c>Config</c>), using the fluent helper API.
/// </returns>
/// <remarks>
/// <para>
/// • This helper is an ergonomic bridge between the Interactions-focused API surface and the
/// generation/chat builder surface, allowing callers to build request payload fragments with the
/// same fluent style.
/// </para>
/// <para>
/// • The returned <c>TGeneration</c> value is stateless and acts as a facade over factory helpers;
/// builders/config objects are created on demand by calling its methods (for example <c>TGeneration.Contents</c>,
/// <c>TGeneration.Parts</c>, <c>TGeneration.Tools</c>, <c>TGeneration.ToolConfig</c>, <c>TGeneration.Speaker</c>).
/// </para>
/// <para>
/// • Prefer this method when you want a single entry point that “names” the intent (generation) in code
/// while keeping call sites compact and consistent.
/// </para>
/// </remarks>
function Generation: TGeneration;

/// <summary>
/// Provides access to the Interactions fluent builder facade.
/// </summary>
/// <returns>
/// A <c>TInteractions</c> record exposing entry points for composing payloads targeting the
/// <c>/interactions</c> endpoint, including builders for inputs, turns, tools, and common
/// configuration blocks.
/// </returns>
/// <remarks>
/// <para>
/// • The returned <c>TInteractions</c> value is a lightweight, stateless facade: it does not retain
/// internal state and typically forwards to factory helpers that create builders/config objects on demand.
/// </para>
/// <para>
/// • Use it to build interaction history (<c>Turns</c>), per-turn input items (<c>Inputs</c>),
/// tool declarations (<c>Tools</c>), and additional interaction-specific blocks (for example tool choice,
/// speech config, or generation config) using the fluent API.
/// </para>
/// <para>
/// • This method is intended as a convenient, discoverable entry point so calling code can start from
/// a single root (for example <c>Gemini.Helpers</c> facade) and then drill down into Interactions-specific
/// builders without referencing low-level units directly.
/// </para>
/// </remarks>
function Interactions: TInteractions;

implementation

function Generation: TGeneration;
begin
  Result := TGeneration.Empty;
end;

function Interactions: TInteractions;
begin
  Result := TInteractions.Empty;
end;

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

function TGoogleSearchResultHelper.AddResult(const Value: TGoogleSearchResultIxParams): TGoogleSearchResult;
begin
  Result := Self.Add(TGoogleSearchResultIxParams.New(Value));
end;

{ TFileSearchResultHelper }

function TFileSearchResultHelper.AddResult(const Value: TFileSearchResultIxParams): TFileSearchResult;
begin
  Result := Self.Add(TFileSearchResultIxParams.New(Value));
end;

{ TUrlContextResultHelper }

function TUrlContextResultHelper.AddResult(const Value: TUrlContextResultIxParams): TUrlContextResult;
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

function TInputContentHelper.AddAssistant(
  const Content: TArray<TInputParams>): TTurn;
begin
  Result := Self.Add(TTurnParams.AddAssistant(Content));
end;

function TInputContentHelper.AddModel(
  const Content: TArray<TInputParams>): TTurn;
begin
  Result := Self.AddAssistant(Content);
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

class function TInteractionInput.AddInputParams: TInputParams;
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

class function TGeneration.AddGenerationConfig: TGenerationConfig;
begin
  Result := TGenerationConfig.Create;
end;

class function TGeneration.Contents: TContent;
begin
  Result := TGeneration.Content.Contents;
end;

class function TGeneration.Empty: TGeneration;
begin
  Result := Default(TGeneration);
  FConfig := Default(TGenerationConfiguration);
  FContent := Default(TGenerationContent);
  FTools := Default(TGenerationTool);
  FSpeaker := Default(TGenerationSpeaker);
  FToolConfig := Default(TGenerationToolConfig);
end;

class function TGeneration.Parts: TParts;
begin
  Result := TGeneration.Content.Parts;
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

{ TInteractions }

class function TInteractions.AddConfig: TGenerationConfigIxParams;
begin
  Result := TGenerationConfigIxParams.Create;
end;

class function TInteractions.Empty: TInteractions;
begin
  Result := Default(TInteractions);
  FRaw := TRaw.Empty;
  FRawItem := TRawItem.Empty;
  FTool := Default(TInteractionTool);
  FInput := Default(TInteractionInput);
end;

class function TInteractions.FileSearchResults: TFileSearchResult;
begin
  Result := TFileSearchResult.Create();
end;

class function TInteractions.GoogleSearchResults: TGoogleSearchResult;
begin
  Result := TGoogleSearchResult.Create();
end;

class function TInteractions.Inputs: TInput;
begin
  Result := TInteractionInput.Inputs;
end;

class function TInteractions.ThoughtSummaries: TThoughtSummary;
begin
  Result := TThoughtSummary.Create();
end;

class function TInteractions.Tools: TToolIx;
begin
  Result := TToolIx.Create();
end;

class function TInteractions.Turns: TTurn;
begin
  Result := TTurn.Create();
end;

class function TInteractions.UrlContextResults: TUrlContextResult;
begin
  Result := TUrlContextResult.Create();
end;

{ TRaw }

class function TRaw.CodeExecutionCallContent: TCodeExecutionCallContentIxParams;
begin
  Result := TCodeExecutionCallContentIxParams.New;
end;

class function TRaw.CodeExecutionResultContent: TCodeExecutionResultContentIxParams;
begin
  Result := TCodeExecutionResultContentIxParams.New;
end;

class function TRaw.DocumentContent: TDocumentContentIxParams;
begin
  Result := TDocumentContentIxParams.New;
end;

class function TRaw.Empty: TRaw;
begin
  Result := Default(TRaw);
end;

class function TRaw.FileSearchResultContent: TFileSearchResultContentIxParams;
begin
  Result := TFileSearchResultContentIxParams.New;
end;

class function TRaw.FunctionCallContent: TFunctionCallContentIxParams;
begin
  Result := TFunctionCallContentIxParams.New;
end;

class function TRaw.FunctionResultContent: TFunctionResultContentIxParams;
begin
  Result := TFunctionResultContentIxParams.New;
end;

class function TRaw.GoogleSearchCallContent: TGoogleSearchCallContentIxParams;
begin
  Result := TGoogleSearchCallContentIxParams.New;
end;

class function TRaw.GoogleSearchResultContent: TGoogleSearchResultContentIxParams;
begin
  Result := TGoogleSearchResultContentIxParams.New;
end;

class function TRaw.ImageContent: TImageContentIxParams;
begin
  Result := TImageContentIxParams.New;
end;

class function TRaw.McpServerToolCallContent: TMcpServerToolCallContentIxParams;
begin
  Result := TMcpServerToolCallContentIxParams.New;
end;

class function TRaw.McpServerToolResultContent: TMcpServerToolResultContentIxParams;
begin
  Result := TMcpServerToolResultContentIxParams.New;
end;

class function TRaw.TAudioContent: TAudioContentIxParams;
begin
  Result := TAudioContentIxParams.New;
end;

class function TRaw.ThoughtContent: TThoughtContentIxParams;
begin
  Result := TThoughtContentIxParams.New;
end;

class function TRaw.UrlContextCallContent: TUrlContextCallContentIxParams;
begin
  Result := TUrlContextCallContentIxParams.New;
end;

class function TRaw.UrlContextResultContent: TUrlContextResultContentIxParams;
begin
  Result := TUrlContextResultContentIxParams.New;
end;

class function TRaw.VideoContent: TVideoContentIxParams;
begin
  Result := TVideoContentIxParams.New;
end;

{ TRawItem }

class function TRawItem.AddGoogleSearchResult: TGoogleSearchResultIxParams;
begin
  Result := TGoogleSearchResultIxParams.Create;
end;

class function TRawItem.AddSpeechConfig: TSpeechConfigIxParams;
begin
  Result := TSpeechConfigIxParams.Create;
end;

class function TRawItem.AddToolChoice: TAllowedToolsIxParams;
begin
  Result := TAllowedToolsIxParams.Create;
end;

class function TRawItem.Empty: TRawItem;
begin
  Result := Default(TRawItem);
end;

end.
