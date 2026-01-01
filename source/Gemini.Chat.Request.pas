unit Gemini.Chat.Request;

interface

uses
  System.SysUtils, System.JSON,
  Gemini.API.Params, Gemini.API, Gemini.Types, Gemini.Safety, Gemini.Schema,
  Gemini.Functions.Core, Gemini.Tools, Gemini.Chat.Request.Content, Gemini.GoogleSearch,
  Gemini.Chat.Request.GenerationConfig, Gemini.Chat.Request.Tools, Gemini.Chat.Request.ToolConfig,
  Gemini.Exceptions;

type
  /// <summary>
  /// Represents the content payload of a chat message, including the message sender's role and its content parts.
  /// </summary>
  /// <remarks>
  /// The <c>TContentPayload</c> class allows you to construct messages with various content parts, specify the role of the message sender (user or assistant), and attach any additional data such as files or media.
  /// This class is essential for building messages in a chat application, particularly when interacting with AI models that require structured message input.
  /// </remarks>
  TContentPayload = class(TJSONParam)
    /// <summary>
    /// Sets the role of the message sender.
    /// </summary>
    /// <param name="Value">
    /// The role of the message sender, specified as a <c>TMessageRole</c> enumeration value (either <c>user</c> or <c>model</c>).
    /// </param>
    /// <returns>
    /// Returns the updated <c>TContentPayload</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Setting the role is useful for multi-turn conversations to distinguish between messages from the user and responses from the model.
    /// If not set, the role can be left blank or unset for single-turn conversations.
    /// </remarks>
    function Role(const Value: TMessageRole): TContentPayload;

    /// <summary>
    /// Adds content parts to the message with specified text and attachments.
    /// </summary>
    /// <param name="Value">
    /// The text content of the message to be included as a part.
    /// </param>
    /// <param name="Attached">
    /// An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TContentPayload</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Each part of the message may have different MIME types.
    /// This method allows combining text and attachments into a single message payload.
    /// </remarks>
    function Parts(const Value: string; const Attached: TArray<string>): TContentPayload; overload;

    /// <summary>
    /// Adds content parts to the message with specified attachments.
    /// </summary>
    /// <param name="Attached">
    /// An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TContentPayload</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Each part of the message may have different MIME types.
    /// This method is useful when the message consists only of attachments without any text content.
    /// </remarks>
    function Parts(const Attached: TArray<string>): TContentPayload; overload;

    /// <summary>
    /// Adds content parts to the message from an array of <c>TPartParams</c>.
    /// </summary>
    /// <param name="Value">
    /// The array of <c>TPartParams</c> instances representing the parts to include
    /// in this message.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TContentPayload</c> instance, allowing for method
    /// chaining.
    /// </returns>
    /// <remarks>
    /// Use this overload when you need fine-grained control over each part,
    /// such as mixing text, inline data, file data, function calls, or code
    /// execution results in a single message.
    /// </remarks>
    function Parts(const Value: TArray<TPartParams>): TContentPayload; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance with specified text content and optional attachments.
    /// </summary>
    /// <param name="Text">
    /// The text content of the message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance containing the specified text and attachments.
    /// </returns>
    class function Add(const Text: string; const Attached: TArray<string> = []): TContentPayload; reintroduce; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance with a specified role and optional attachments.
    /// </summary>
    /// <param name="Role">
    /// The role of the message sender, specified as a <c>TMessageRole</c> enumeration value (either <c>user</c> or <c>model</c>).
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance with the specified role and attachments.
    /// </returns>
    class function Add(const Role: TMessageRole;
      const Attached: TArray<string> = []): TContentPayload; reintroduce; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance with specified role, text content, and optional attachments.
    /// </summary>
    /// <param name="Role">
    /// The role of the message sender, specified as a <c>TMessageRole</c> enumeration value (either <c>user</c> or <c>model</c>).
    /// </param>
    /// <param name="Text">
    /// The text content of the message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance containing the specified role, text, and attachments.
    /// </returns>
    class function Add(const Role: TMessageRole; const Text: string;
      const Attached: TArray<string> = []): TContentPayload; reintroduce; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance from an array of
    /// <c>TPartParams</c>.
    /// </summary>
    /// <param name="Value">
    /// The array of <c>TPartParams</c> instances to use as the message parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance containing the specified
    /// parts.
    /// </returns>
    /// <remarks>
    /// Use this overload when you already have fully constructed parts and
    /// want to build a payload directly from them. The role is not set by
    /// default and can be specified later if needed.
    /// </remarks>
    class function Add(const Value: TArray<TPartParams>): TContentPayload; reintroduce; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance representing the assistant's message with specified text content and optional attachments.
    /// </summary>
    /// <param name="Value">
    /// The text content of the assistant's message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance representing the assistant's message.
    /// </returns>
    class function Assistant(const Value: string; const Attached: TArray<string> = []): TContentPayload; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance representing the assistant's message with specified attachments.
    /// </summary>
    /// <param name="Attached">
    /// An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance representing the assistant's message with attachments.
    /// </returns>
    class function Assistant(const Attached: TArray<string>): TContentPayload; overload;

    /// <summary>
    /// Creates a new assistant message from an array of <c>TPartParams</c>.
    /// </summary>
    /// <param name="Parts">
    /// The array of <c>TPartParams</c> instances representing the assistant
    /// message parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance with the role set to
    /// <c>model</c> and containing the specified parts.
    /// </returns>
    /// <remarks>
    /// Use this overload when you already have structured parts for the
    /// assistant response and want to build the payload in a single call.
    /// </remarks>
    class function Assistant(const Parts: TArray<TPartParams>): TContentPayload; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance representing the user's message with specified text content and optional attachments.
    /// </summary>
    /// <param name="Value">
    /// The text content of the user's message.
    /// </param>
    /// <param name="Attached">
    /// Optional. An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance representing the user's message.
    /// </returns>
    class function User(const Value: string; const Attached: TArray<string> = []): TContentPayload; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance representing the user's message with specified attachments.
    /// </summary>
    /// <param name="Attached">
    /// An array of strings representing attached data or file URIs to be included as parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance representing the user's message with attachments.
    /// </returns>
    class function User(const Attached: TArray<string>): TContentPayload; overload;

    /// <summary>
    /// Creates a new user message from an array of <c>TPartParams</c>.
    /// </summary>
    /// <param name="Parts">
    /// The array of <c>TPartParams</c> instances representing the user
    /// message parts.
    /// </param>
    /// <returns>
    /// Returns a new <c>TContentPayload</c> instance with the role set to
    /// <c>user</c> and containing the specified parts.
    /// </returns>
    /// <remarks>
    /// Use this overload when you already have structured parts for the
    /// user request and want to build the payload in a single call.
    /// </remarks>
    class function User(const Parts: TArray<TPartParams>): TContentPayload; overload;

    /// <summary>
    /// Creates a new <c>TContentPayload</c> instance and allows configuration through a procedure reference.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure reference that receives a <c>TContentPayload</c> instance to configure its properties.
    /// </param>
    /// <returns>
    /// Returns a new configured <c>TContentPayload</c> instance.
    /// </returns>
    class function New(const ParamProc: TProcRef<TContentPayload>): TContentPayload; static; deprecated;
  end;

  /// <summary>
  /// Represents the content payload of a chat message, including the message sender's role and its content parts.
  /// </summary>
  /// <remarks>
  /// The <c>TPayLoad</c> class allows you to construct messages with various content parts, specify the role of the message sender (user or assistant), and attach any additional data such as files or media.
  /// This class is essential for building messages in a chat application, particularly when interacting with AI models that require structured message input.
  /// </remarks>
  TPayLoad = TContentPayload;

  TUsageMetadataParams = class(TJSONParam)
    function TotalTokenCount(const Value: Integer): TUsageMetadataParams;
  end;

  /// <summary>
  /// Represents the set of parameters used to configure a chat interaction with an AI model.
  /// </summary>
  /// <remarks>
  /// The <c>TChatParams</c> class allows you to define various settings that control how the AI model behaves during a chat session.
  /// You can specify the messages to send, tools the model can use, safety settings, system instructions, and generation configurations.
  /// By customizing these parameters, you can fine-tune the AI's responses to better suit your application's needs.
  /// </remarks>
  TChatParams = class(TJSONParam)
    /// <summary>
    /// Sets the content of the current conversation with the model.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TContentPayload</c> instances representing the messages exchanged in the conversation, including both user and assistant messages.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// For single-turn queries, this array contains a single message. For multi-turn conversations, include the entire conversation history and the latest message.
    /// </remarks>
    function Contents(const Value: TArray<TContentPayload>): TChatParams; overload;

    /// <summary>
    /// Sets the content of the current conversation with the model.
    /// </summary>
    /// <param name="Value">
    /// A JSONArray  string
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// For single-turn queries, this array contains a single message. For multi-turn conversations, include the entire conversation history and the latest message.
    /// </remarks>
    function Contents(const Value: string): TChatParams; overload;

    /// <summary>
    /// Specifies a list of tools that the model may use to generate the next response.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>IFunctionCore</c> instances representing the tools available to the model.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// A tool is a piece of code that allows the model to interact with external systems or perform actions outside its knowledge base.
    /// Supported tools include functions and code execution capabilities. Refer to the Function Calling and Code Execution guides for more information.
    /// </remarks>
    function Tools(const Value: TArray<IFunctionCore>): TChatParams; overload;

    /// <summary>
    /// Optional. Input only. Immutable. A list of Tools the model may use to generate the next response
    /// </summary>
    function Tools(const Value: TArray<TToolParams>): TChatParams; overload;

    /// <summary>
    /// Optional. Input only. Immutable. A list of Tools the model may use to generate the next response
    /// </summary>
    /// <param name="Value">
    /// A JSONArray  string
    /// </param>
    function Tools(const Value: string): TChatParams; overload;

    /// <summary>
    /// Optional. Tool configuration for any Tool specified in the request.
    /// </summary>
    /// <remarks>
    /// Refer to the Function calling guide for a usage example.
    /// <para>
    /// https://ai.google.dev/gemini-api/docs/function-calling?example=meeting#function_calling_mode
    /// </para>
    /// </remarks>
    function ToolConfig(const Value: TToolConfig): TChatParams;

    /// <summary>
    /// Specifies safety settings to block unsafe content.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TSafety</c> instances representing safety settings for different harm categories.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// These settings are enforced on both the request and the response.
    /// There should not be more than one setting for each safety category.
    /// The API will block any content that fails to meet the thresholds set by these settings.
    /// This list overrides the default settings for each specified category.
    /// If a category is not specified, the API uses the default safety setting for that category.
    /// Supported harm categories include <c>HARM_CATEGORY_HATE_SPEECH</c>, <c>HARM_CATEGORY_SEXUALLY_EXPLICIT</c>, <c>HARM_CATEGORY_DANGEROUS_CONTENT</c>, and <c>HARM_CATEGORY_HARASSMENT</c>.
    /// Refer to the documentation for detailed information on available safety settings and how to incorporate safety considerations into your application.
    /// </remarks>
    function SafetySettings(const Value: TArray<TSafety>): TChatParams; overload;

    /// <summary>
    /// Specifies safety settings to block unsafe content.
    /// </summary>
    /// <param name="Value">
    /// A JSONArray string
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// These settings are enforced on both the request and the response.
    /// There should not be more than one setting for each safety category.
    /// The API will block any content that fails to meet the thresholds set by these settings.
    /// This list overrides the default settings for each specified category.
    /// If a category is not specified, the API uses the default safety setting for that category.
    /// Supported harm categories include <c>HARM_CATEGORY_HATE_SPEECH</c>, <c>HARM_CATEGORY_SEXUALLY_EXPLICIT</c>, <c>HARM_CATEGORY_DANGEROUS_CONTENT</c>, and <c>HARM_CATEGORY_HARASSMENT</c>.
    /// Refer to the documentation for detailed information on available safety settings and how to incorporate safety considerations into your application.
    /// </remarks>
    function SafetySettings(const Value: string): TChatParams; overload;

    /// <summary>
    /// Sets developer-defined system instructions for the model.
    /// </summary>
    /// <param name="Value">
    /// A string containing the system instruction text.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Use this to provide guidelines or constraints for the model's behavior during the chat session.
    /// </remarks>
    function SystemInstruction(const Value: string): TChatParams;

    /// <summary>
    /// Configures generation options for the model's outputs.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure reference that receives a <c>TGenerationConfig</c> instance to configure various generation settings.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TChatParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Use this method to specify parameters such as temperature, maximum tokens, response format, and other generation options.
    /// Not all parameters are configurable for every model.
    /// </remarks>
    function GenerationConfig(const ParamProc: TProcRef<TGenerationConfig>): TChatParams; overload; deprecated;

    /// <summary>
    /// Optional. Configuration options for model generation and outputs.
    /// </summary>
    function GenerationConfig(const Value: TGenerationConfig): TChatParams; overload;

    /// <summary>
    /// Optional. Configuration options for model generation and outputs.
    /// </summary>
    /// <param name="paramname">
    /// A JSONArray string
    /// </param>
    function GenerationConfig(const Value: string): TChatParams; overload;

    /// <summary>
    /// Optional. The name of the content cached to use as context to serve the prediction.
    /// Format: cachedContents/{cachedContent}
    /// </summary>
    function CachedContent(const Value: string): TChatParams;

    /// <summary>
    /// Creates a new <c>TChatParams</c> instance and allows configuration through a procedure reference.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure reference that receives a <c>TChatParams</c> instance to configure its properties.
    /// </param>
    /// <returns>
    /// Returns a new configured <c>TChatParams</c> instance.
    /// </returns>
    class function New(const ParamProc: TProcRef<TChatParams>): TChatParams; overload; deprecated;
  end;

implementation

uses
  Rest.Json;

{ TContentPayload }

class function TContentPayload.Add(const Role: TMessageRole;
  const Text: string; const Attached: TArray<string>): TContentPayload;
begin
  Result := TContentPayload.Create.Role(Role).Parts(Text, Attached);
end;

class function TContentPayload.Assistant(
  const Attached: TArray<string>): TContentPayload;
begin
  Result := Add(TMessageRole.model, Attached);
end;

class function TContentPayload.Assistant(const Value: string;
  const Attached: TArray<string>): TContentPayload;
begin
  Result := Add(Value, Attached).Role(TMessageRole.model);
end;

class function TContentPayload.Add(const Role: TMessageRole;
  const Attached: TArray<string>): TContentPayload;
begin
  Result := TContentPayload.Create.Role(Role).Parts(Attached);
end;

class function TContentPayload.New(
  const ParamProc: TProcRef<TContentPayload>): TContentPayload;
begin
  Result := TContentPayload.Create;
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end;
end;

function TContentPayload.Parts(
  const Value: TArray<TPartParams>): TContentPayload;
begin
  Result := TContentPayload(Add('parts',
    TJSONHelper.ToJsonArray<TPartParams>(Value)));
end;

function TContentPayload.Parts(const Attached: TArray<string>): TContentPayload;
begin
  var JSONParts := TJSONArray.Create;
  for var Item in Attached do
    JSONParts.Add(TAttachedManager.ToJson(Item));
  Result := TContentPayload(Add('parts', JSONParts));
end;

class function TContentPayload.Add(const Text: string;
  const Attached: TArray<string>): TContentPayload;
begin
  Result := TContentPayload.Create.Parts(Text, Attached);
end;

class function TContentPayload.Add(const Value: TArray<TPartParams>): TContentPayload;
begin
  Result := TContentPayload.Create.Parts(Value);
end;

class function TContentPayload.Assistant(
  const Parts: TArray<TPartParams>): TContentPayload;
begin
  Result := TContentPayload.Create.Role(TMessageRole.model).Parts(Parts);
end;

function TContentPayload.Role(const Value: TMessageRole): TContentPayload;
begin
  Result := TContentPayload(Add('role', Value.ToString));
end;

class function TContentPayload.User(
  const Parts: TArray<TPartParams>): TContentPayload;
begin
  Result := TContentPayload.Create.Role(TMessageRole.user).Parts(Parts);
end;

class function TContentPayload.User(
  const Attached: TArray<string>): TContentPayload;
begin
  Result := Add(TMessageRole.user, Attached);
end;

class function TContentPayload.User(const Value: string;
  const Attached: TArray<string>): TContentPayload;
begin
  Result := Add(Value, Attached).Role(TMessageRole.user);
end;

function TContentPayload.Parts(const Value: string;
  const Attached: TArray<string>): TContentPayload;
begin
  var JSONParts := TJSONArray.Create;
  if not Value.IsEmpty then
    JSONParts.Add(TPartParams.Create.Text(Value).Detach);
  for var Item in Attached do
    JSONParts.Add(TAttachedManager.ToJson(Item));
  Result := TContentPayload(Add('parts', JSONParts));
end;

{ TChatParams }

function TChatParams.CachedContent(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('cachedContent', Value));
end;

function TChatParams.Contents(
  const Value: TArray<TContentPayload>): TChatParams;
begin
  Result := TChatParams(Add('contents',
    TJSONHelper.ToJsonArray<TContentPayload>(Value)));
end;

function TChatParams.Contents(const Value: string): TChatParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TChatParams(Add('contents', JSONArray)));

  raise EGeminiException.Create('Invalid JSON Array');
end;

function TChatParams.GenerationConfig(
  const Value: TGenerationConfig): TChatParams;
begin
  Result := TChatParams(Add('generationConfig', Value.Detach));
end;

function TChatParams.GenerationConfig(const Value: string): TChatParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TChatParams(Add('generationConfig', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TChatParams.GenerationConfig(const ParamProc: TProcRef<TGenerationConfig>): TChatParams;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TGenerationConfig.Create;
      ParamProc(Value);
      Result := TChatParams(Add('generationConfig', Value.Detach));
    end
  else Result := Self;
end;

class function TChatParams.New(
  const ParamProc: TProcRef<TChatParams>): TChatParams;
begin
  Result := TChatParams.Create;
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end;
end;

function TChatParams.SafetySettings(
  const Value: TArray<TSafety>): TChatParams;
begin
  var JSONSafetySettings := TJSONArray.Create;
  for var Item in Value do
    JSONSafetySettings.Add(Item.ToJson);
  Result := TChatParams(Add('safetySettings', JSONSafetySettings));
end;

function TChatParams.SafetySettings(const Value: string): TChatParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TChatParams(Add('safetySettings', JSONArray)));

  raise EGeminiException.Create('Invalid JSON Array');
end;

function TChatParams.SystemInstruction(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('systemInstruction', TContentPayload.Add(Value).Detach));
end;

function TChatParams.ToolConfig(const Value: TToolConfig): TChatParams;
begin
  Result := TChatParams(Add('toolConfig', Value.Detach));
end;

function TChatParams.Tools(const Value: TArray<TToolParams>): TChatParams;
begin
  Result := TChatParams(Add('tools',
    TJSONHelper.ToJsonArray<TToolParams>(Value)));
end;

function TChatParams.Tools(const Value: TArray<IFunctionCore>): TChatParams;
begin
  var JSONFuncs := TJSONArray.Create;
  for var Item in value do
    JSONFuncs.Add(TToolPluginParams.Add(Item).ToJson);

  var JSONDeclaration := TJSONObject.Create.AddPair('functionDeclarations', JSONFuncs);

  Result := TChatParams(Add('tools', TJSONArray.Create.Add(JSONDeclaration)));
end;

function TChatParams.Tools(const Value: string): TChatParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TChatParams(Add('tools', JSONArray)));

  raise EGeminiException.Create('Invalid JSON Array');
end;



{ TUsageMetadataParams }

function TUsageMetadataParams.TotalTokenCount(const Value: Integer): TUsageMetadataParams;
begin
  Result := TUsageMetadataParams(Add('totalTokenCount', Value));
end;

end.
