unit Gemini.FineTunings;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON, REST.JsonReflect, REST.Json.Types,
  Gemini.API.Params, Gemini.API, Gemini.Async.Support, Gemini.Chat;

type
  /// <summary>
  /// The state of the tuned model.
  /// </summary>
  TModelState = (
    /// <summary>
    /// Default value. This value is not used.
    /// </summary>
    STATE_UNSPECIFIED,
    /// <summary>
    /// The model is being created.
    /// </summary>
    CREATING,
    /// <summary>
    /// The model is ready to use.
    /// </summary>
    ACTIVE,
    /// <summary>
    /// Failed to create model.
    /// </summary>
    FAILED
  );

  /// <summary>
  /// Helper record for the <c>TModelState</c> enumeration, providing utility methods for converting
  /// between <c>TModelState</c> values and their string representations.
  /// </summary>
  TModelStateHelper = record helper for TModelState
    /// <summary>
    /// Converts the current <c>TModelState</c> value to its corresponding string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TModelState</c> value.
    /// </returns>
    function ToString: string;
    /// <summary>
    /// Converts a string representation of a <c>TModelState</c> into its corresponding enumeration value.
    /// </summary>
    /// <param name="Value">
    /// The string representing a <c>TModelState</c>.
    /// </param>
    /// <returns>
    /// The <c>TModelState</c> enumeration value that corresponds to the provided string.
    /// </returns>
    class function Create(const Value: string): TModelState; static;
  end;

  /// <summary>
  /// Interceptor class for converting <c>TModelState</c> values to and from their string representations in JSON serialization and deserialization.
  /// </summary>
  /// <remarks>
  /// This class is used to facilitate the conversion between the <c>TModelState</c> enum and its string equivalents during JSON processing.
  /// It extends the <c>TJSONInterceptorStringToString</c> class to override the necessary methods for custom conversion logic.
  /// </remarks>
  TModelStateInterceptor = class(TJSONInterceptorStringToString)
    /// <summary>
    /// Converts the <c>TModelState</c> value of the specified field to a string during JSON serialization.
    /// </summary>
    /// <param name="Data">
    /// The object containing the field to be converted.
    /// </param>
    /// <param name="Field">
    /// The field name representing the <c>TModelState</c> value.
    /// </param>
    /// <returns>
    /// The string representation of the <c>TModelState</c> value.
    /// </returns>
    function StringConverter(Data: TObject; Field: string): string; override;
    /// <summary>
    /// Converts a string back to a <c>TModelState</c> value for the specified field during JSON deserialization.
    /// </summary>
    /// <param name="Data">
    /// The object containing the field to be set.
    /// </param>
    /// <param name="Field">
    /// The field name where the <c>TModelState</c> value will be set.
    /// </param>
    /// <param name="Arg">
    /// The string representation of the <c>TModelState</c> to be converted back.
    /// </param>
    /// <remarks>
    /// This method converts the string argument back to the corresponding <c>TModelState</c> value and assigns it to the specified field in the object.
    /// </remarks>
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// <c>THyperparametersParams</c> class controlling the tuning process.
  /// </summary>
  /// <remarks>
  /// Read more at https://ai.google.dev/docs/model_tuning_guidance
  /// </remarks>
  THyperparametersParams = class(TJSONParam)
  public
    /// <summary>
    /// Optional. Immutable. The learning rate hyperparameter for tuning.
    /// </summary>
    /// <remarks>
    /// If not set, a default of 0.001 or 0.0002 will be calculated based on the number of training examples.
    /// </remarks>
    function LearningRate(const Value: Double): THyperparametersParams;
    /// <summary>
    /// Optional. Immutable. The learning rate multiplier is used to calculate a final learningRate based on the default (recommended) value
    /// </summary>
    /// <remarks>
    /// Actual learning rate := learningRateMultiplier * default learning rate Default learning rate is dependent on base model and dataset size. If not set, a default of 1.0 will be used.
    /// </remarks>
    function LearningRateMultiplier(const Value: Double): THyperparametersParams;
    /// <summary>
    /// Immutable. The number of training epochs.
    /// </summary>
    /// <remarks>
    /// An epoch is one pass through the training data. If not set, a default of 5 will be used.
    /// </remarks>
    function EpochCount(const Value: Integer): THyperparametersParams;
    /// <summary>
    /// Immutable. The batch size hyperparameter for tuning.
    /// </summary>
    /// <remarks>
    /// If not set, a default of 4 or 16 will be used based on the number of training examples.
    /// </remarks>
    function BatchSize(const Value: Integer): THyperparametersParams;
  end;

  /// <summary>
  /// <c>TTuningExample</c> class controling a single example for tuning.
  /// </summary>
  TTuningExample = class(TJSONParam)
  public
    /// <summary>
    /// Required. The expected model output.
    /// </summary>
    function Output(const Value: string): TTuningExample;
    /// <summary>
    /// Optional. Text model input.
    /// </summary>
    function TextInput(const Value: string): TTuningExample;
    class function AddItem(const Input, Output: string): TTuningExample;
  end;

  /// <summary>
  /// <c>TTuningExample</c> class controling a single example for tuning.
  /// </summary>
  Example = TTuningExample;

  /// <summary>
  /// Provides utility methods for handling tuning tasks, including converting training data to JSON formats.
  /// </summary>
  /// <remarks>
  /// The <c>TTuningTaskHelper</c> record contains static methods that assist in transforming training data from various sources
  /// into JSON structures required by the Gemini API. It facilitates the preparation of training examples and the parsing of JSONL files.
  /// </remarks>
  TTuningTaskHelper = record
    /// <summary>
    /// Converts the contents of a CSV file into a <c>TJSONArray</c>.
    /// </summary>
    /// <param name="FileName">
    /// The file path of the CSV file containing the data.
    /// </param>
    /// <param name="Separator">
    /// The character used as the delimiter between columns in the CSV file. Default is ';'.
    /// </param>
    /// <returns>
    /// A <c>TJSONArray</c> representing the array of JSON objects parsed from the CSV file.
    /// </returns>
    /// <exception cref="Exception">
    /// Thrown if the specified CSV file does not exist or cannot be read.
    /// </exception>
    class function LoadFromCSV(const FileName: string; Separator: Char = ';'): TJSONArray; static;
    /// <summary>
    /// Converts the contents of a JSONL (JSON Lines) file into a <c>TJSONArray</c>.
    /// </summary>
    /// <param name="FileName">
    /// The file path of the JSONL file containing the data.
    /// </param>
    /// <returns>
    /// A <c>TJSONArray</c> representing the array of JSON objects parsed from the JSONL file.
    /// </returns>
    /// <exception cref="Exception">
    /// Thrown if the specified JSONL file does not exist or cannot be read.
    /// </exception>
    class function LoadFromJSONL(const FileName: string): TJSONArray; static;
    /// <summary>
    /// Converts the contents of a CSV or JSONL file into a <c>TJSONArray</c>, based on the file extension.
    /// </summary>
    /// <param name="FileName">
    /// The file path of the data file. Must be a CSV or JSONL file.
    /// </param>
    /// <returns>
    /// A <c>TJSONArray</c> representing the array of JSON objects parsed from the file.
    /// </returns>
    /// <exception cref="Exception">
    /// Thrown if the specified file does not exist, is not readable, or is of an unsupported format.
    /// </exception>
    class function FileDataToJSONArray(const FileName: string): TJSONArray; static;
    /// <summary>
    /// Builds a <c>TJSONObject</c> containing training examples from an array of <c>TTuningExample</c> instances.
    /// </summary>
    /// <param name="Value">
    /// An array of <c>TTuningExample</c> instances representing individual training examples.
    /// </param>
    /// <returns>
    /// A <c>TJSONObject</c> with a single pair where the key is "examples" and the value is a <c>TJSONArray</c> of the provided examples.
    /// </returns>
    class function ExamplesBuilder(const Value: TArray<TTuningExample>): TJSONObject; overload; static;
    /// <summary>
    /// Builds a <c>TJSONObject</c> containing training examples by reading from a JSONL file.
    /// </summary>
    /// <param name="JSONLFileName">
    /// The file path of the JSONL file containing training data.
    /// </param>
    /// <returns>
    /// A <c>TJSONObject</c> with a single pair where the key is "examples" and the value is a <c>TJSONArray</c> of the parsed examples.
    /// </returns>
    /// <exception cref="Exception">
    /// Thrown if the specified JSONL file does not exist or cannot be parsed.
    /// </exception>
    class function ExamplesBuilder(const FileName: string): TJSONObject; overload; static;
  end;

  /// <summary>
  /// <c>TTuningTaskParams</c> controls the training data for a tuned models.
  /// </summary>
  TTuningTaskParams = class(TJSONParam)
  public
    /// <summary>
    /// Required. Input only. Immutable. The model training data.
    /// </summary>
    function TrainingData(const JSONLFileName: string): TTuningTaskParams; overload;
    /// <summary>
    /// Required. Input only. Immutable. The model training data.
    /// </summary>
    function TrainingData(const Value: TArray<TTuningExample>): TTuningTaskParams; overload;
    /// <summary>
    /// Required. Input only. Immutable. The model training data.
    /// </summary>
    function TrainingData(const Value: TJSONObject): TTuningTaskParams; overload;
    /// <summary>
    /// Immutable. Hyperparameters controlling the tuning process.
    /// </summary>
    /// <remarks>
    /// If not provided, default values will be used.
    /// </remarks>
    function Hyperparameters(ParamProc: TProcRef<THyperparametersParams>): TTuningTaskParams;
  end;

  /// <summary>
  /// <c>TTunedModelParams</c> control the creation of a tuned model.
  /// </summary>
  /// <remarks>
  /// Check intermediate tuning progress (if any) through the google.longrunning.Operations service.
  /// </remarks>
  TTunedModelParams = class(TJSONParam)
  public
    /// <summary>
    /// Optional. The name to display for this model in user interfaces.
    /// </summary>
    /// <param name="Value">
    /// The display name must be up to 40 characters including spaces.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    function DisplayName(const Value: string): TTunedModelParams;
    /// <summary>
    /// A short description of this model.
    /// </summary>
    /// <param name="Value">
    /// A string to briefly describe the model.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    function Description(const Value: string): TTunedModelParams;
    /// <summary>
    /// Required. The tuning task that creates the tuned model.
    /// </summary>
    /// <param name="Value">
    /// <c>TTuningTaskParams</c> instance representing a tuning tasks that create tuned models.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    function TuningTask(const Value: TTuningTaskParams): TTunedModelParams; overload;
    /// <summary>
    /// Optional. List of project numbers that have read access to the tuned model.
    /// </summary>
    /// <param name="Value">
    /// An array of integers where each item represents a project number.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    function ReaderProjectNumbers(const Value: TArray<Integer>): TTunedModelParams;
    /// <summary>
    /// Optional. TunedModel to use as the starting point for training the new model.
    /// </summary>
    /// <param name="Value">
    /// Example: tunedModels/my-tuned-model
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    function TunedModelSource(const Value: string): TTunedModelParams;
    /// <summary>
    /// Immutable. The name of the Model to tune.
    /// </summary>
    /// <param name="Value">
    /// Example: models/gemini-1.5-flash-001
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    function BaseModel(const Value: string): TTunedModelParams;
    /// <summary>
    /// Optional. Controls the randomness of the output.
    /// </summary>
    /// <param name="Value">
    /// Values can range over [0.0,1.0], inclusive. A value closer to 1.0 will produce responses that are more varied, while a value closer to 0.0 will typically result in less surprising responses from the model.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// This value specifies default to be the one used by the base model while creating the model.
    /// </remarks>
    function Temperature(const Value: Double): TTunedModelParams;
    /// <summary>
    /// Optional. For Nucleus sampling.
    /// </summary>
    /// <param name="Value">
    /// Nucleus sampling considers the smallest set of tokens whose probability sum is at least topP.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// This value specifies default to be the one used by the base model while creating the model.
    /// </remarks>
    function TopP(const Value: Double): TTunedModelParams;
    /// <summary>
    /// Optional. For Top-k sampling.
    /// </summary>
    /// <param name="Value">
    /// Top-k sampling considers the set of topK most probable tokens. This value specifies default to be used by the backend while making the call to the model.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TTunedModelParams</c> instance, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// This value specifies default to be the one used by the base model while creating the model.
    /// </remarks>
    function TopK(const Value: Integer): TTunedModelParams;
  end;

  /// <summary>
  /// The <c>TModelTraining</c> class allows to use the information returned after processing to fine-tune a model.
  /// </summary>
  TModelTraining = class
  private
    FName: string;
    [JsonReflectAttribute(ctString, rtString, TArgsFixInterceptor)]
    FMetadata: string;
    FDone: Boolean;
    [JsonReflectAttribute(ctString, rtString, TArgsFixInterceptor)]
    FResponse: string;
  public
    /// <summary>
    /// The server-assigned name, which is only unique within the same service that originally returns it.
    /// </summary>
    /// <remarks>
    /// you use the default HTTP mapping, the name should be a resource name ending with operations/{unique_id}.
    /// </remarks>
    property Name: string read FName write FName;
    /// <summary>
    /// Service-specific metadata associated with the operation.
    /// </summary>
    /// <remarks>
    /// It typically contains progress information and common metadata such as create time. Some services might not provide such metadata. Any method that returns a long-running operation should document the metadata type, if any.
    /// <para>
    /// An object containing fields of an arbitrary type. An additional field "@type" contains a URI identifying the type. Example: { "id": 1234, "@type": "types.example.com/standard/id" }.
    /// </para>
    /// </remarks>
    property Metadata: string read FMetadata write FMetadata;
    /// <summary>
    /// If the value is false, it means the operation is still in progress.
    /// </summary>
    /// <remarks>
    /// If true, the operation is completed, and either error or response is available.
    /// </remarks>
    property Done: Boolean read FDone write FDone;
    /// <summary>
    /// The normal, successful response of the operation.
    /// </summary>
    /// <remarks>
    /// If the original method returns no data on success, such as Delete, the response is google.protobuf.Empty. If the original method is standard Get/Create/Update, the response should be the resource. For other methods, the response should have the type XxxResponse, where Xxx is the original method name. For example, if the original method name is TakeSnapshot(), the inferred response type is TakeSnapshotResponse.
    /// <para>
    /// An object containing fields of an arbitrary type. An additional field "@type" contains a URI identifying the type. Example: { "id": 1234, "@type": "types.example.com/standard/id" }.
    /// </para>
    /// </remarks>
    property Response: string read FResponse write FResponse;
  end;

  /// <summary>
  /// The <c>TTuningSnapshot</c> class allows you to utilize the information returned from a single tuning step.
  /// </summary>
  TTuningSnapshot = class
  private
    FStep: Integer;
    FEpoch: Integer;
    FMeanLoss: Double;
    FComputeTime: string;
  public
    /// <summary>
    /// Output only. The tuning step.
    /// </summary>
    property Step: Integer read FStep write FStep;
    /// <summary>
    /// Output only. The epoch this step was part of.
    /// </summary>
    property Epoch: Integer read FEpoch write FEpoch;
    /// <summary>
    /// Output only. The mean loss of the training examples for this step.
    /// </summary>
    property MeanLoss: Double read FMeanLoss write FMeanLoss;
    /// <summary>
    /// Output only. The timestamp when this metric was computed.
    /// </summary>
    /// <remarks>
    /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".
    /// </remarks>
    property ComputeTime: string read FComputeTime write FComputeTime;
  end;

  /// <summary>
  /// <c>Hyperparameters</c> class controlling the tuning process.
  /// </summary>
  THyperParameters = class
  private
    FLearningRate: Double;
    FLearningRateMultiplier: Double;
    FEpochCount: Integer;
    FBatchSize: Integer;
  public
    /// <summary>
    /// Optional. Immutable. The learning rate hyperparameter for tuning.
    /// </summary>
    /// <remarks>
    /// If not set, a default of 0.001 or 0.0002 will be calculated based on the number of training examples.
    /// </remarks>
    property LearningRate: Double read FLearningRate write FLearningRate;
    /// <summary>
    /// Optional. Immutable. The learning rate multiplier is used to calculate a final learningRate based on the default (recommended) value.
    /// </summary>
    /// <remarks>
    /// Actual learning rate := learningRateMultiplier * default learning rate Default learning rate is dependent on base model and dataset size. If not set, a default of 1.0 will be used.
    /// </remarks>
    property LearningRateMultiplier: Double read FLearningRateMultiplier write FLearningRateMultiplier;
    /// <summary>
    /// Immutable. The number of training epochs.
    /// </summary>
    /// <remarks>
    /// An epoch is one pass through the training data. If not set, a default of 5 will be used.
    /// </remarks>
    property EpochCount: Integer read FEpochCount write FEpochCount;
    /// <summary>
    /// Immutable. The batch size hyperparameter for tuning.
    /// </summary>
    /// <remarks>
    /// If not set, a default of 4 or 16 will be used based on the number of training examples.
    /// </remarks>
    property BatchSize: Integer read FBatchSize write FBatchSize;
  end;

  /// <summary>
  /// The <c>TTuningTask</c> class controls tuning tasks that create tuned models.
  /// </summary>
  TTuningTask = class
  private
    FStartTime: string;
    FCompleteTime: string;
    FSnapshots: TArray<TTuningSnapshot>;
    FHyperparameters: THyperParameters;
  public
    /// <summary>
    /// Output only. The timestamp when tuning this model started.
    /// </summary>
    /// <remarks>
    /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".
    /// </remarks>
    property StartTime: string read FStartTime write FStartTime;
    /// <summary>
    /// Output only. The timestamp when tuning this model completed.
    /// </summary>
    /// <remarks>
    /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".
    /// </remarks>
    property CompleteTime: string read FCompleteTime write FCompleteTime;
    /// <summary>
    /// Output only. Metrics collected during tuning.
    /// </summary>
    property Snapshots: TArray<TTuningSnapshot> read Fsnapshots write Fsnapshots;
    /// <summary>
    /// Immutable. Hyperparameters controlling the tuning process. If not provided, default values will be used.
    /// </summary>
    property Hyperparameters: THyperParameters read FHyperparameters write FHyperparameters;
    destructor Destroy; override;
  end;

  /// <summary>
  /// The <TTunedModelSource> class controls a tuned model as a source for training a new model.
  /// </summary>
  TTunedModelSource = class
  private
    FTunedModel: string;
    FBaseModel: string;
  public
    /// <summary>
    /// Immutable. The name of the TunedModel to use as the starting point for training the new model.
    /// </summary>
    /// <remarks>
    /// Example: tunedModels/my-tuned-model
    /// </remarks>
    property TunedModel: string read FTunedModel write FTunedModel;
    /// <summary>
    /// Output only. The name of the base Model this TunedModel was tuned from.
    /// </summary>
    /// <remarks>
    /// Example: models/gemini-1.5-flash-001
    /// </remarks>
    property BaseModel: string read FBaseModel write FBaseModel;
  end;

  /// <summary>
  /// The <c>TTunedModel</c> class allows to utilize the information from created fine-tuned model.
  /// </summary>
  TTunedModel = class
  private
    FName: string;
    FDisplayName: string;
    FDescription: string;
    [JsonReflectAttribute(ctString, rtString, TModelStateInterceptor)]
    FState: TModelState;
    FCreateTime: string;
    FUpdateTime: string;
    FTuningTask: TTuningTask;
    FReaderProjectNumbers: TArray<Int64>;
    FTunedModelSource: TTunedModelSource;
    FBaseModel: string;
    FTemperature: Double;
    FTopP: Double;
    FTopK: Integer;
  public
    /// <summary>
    /// Output only. The tuned model name.
    /// </summary>
    /// <summary>
    /// A unique name will be generated on create. Example: tunedModels/az2mb0bpw6i If displayName is set on create, the id portion of the name will be set by concatenating the words of the displayName with hyphens and adding a random portion for uniqueness.
    /// <para>
    /// Example: displayName = Sentence Translator; name = tunedModels/sentence-translator-u3b7m
    /// </para>
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// Optional. The name to display for this model in user interfaces.
    /// </summary>
    /// <remarks>
    /// The display name must be up to 40 characters including spaces.
    /// </remarks>
    property DisplayName: string read FDisplayName write FDisplayName;
    /// <summary>
    /// Optional. A short description of this model.
    /// </summary>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// Output only. The state of the tuned model.
    /// </summary>
    property State: TModelState read FState write FState;
    /// <summary>
    /// Output only. The timestamp when this model was created.
    /// </summary>
    /// <remarks>
    /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".
    /// </remarks>
    property CreateTime: string read FCreateTime write FCreateTime;
    /// <summary>
    /// Output only. The timestamp when this model was updated.
    /// </summary>
    /// <remarks>
    /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and up to nine fractional digits. Examples: "2014-10-02T15:01:23Z" and "2014-10-02T15:01:23.045123456Z".
    /// </remarks>
    property UpdateTime: string read FUpdateTime write FUpdateTime;
    /// <summary>
    /// Required. The tuning task that creates the tuned model.
    /// </summary>
    property TuningTask: TTuningTask read FTuningTask write FTuningTask;
    /// <summary>
    /// Optional. List of project numbers that have read access to the tuned model.
    /// </summary>
    property ReaderProjectNumbers: TArray<Int64> read FReaderProjectNumbers write FReaderProjectNumbers;
    /// <summary>
    /// Optional. TunedModel to use as the starting point for training the new model.
    /// </summary>
    property TunedModelSource: TTunedModelSource read FTunedModelSource write FTunedModelSource;
    /// <summary>
    /// Immutable. The name of the Model to tune.
    /// </summary>
    /// <remarks>
    /// Example: models/gemini-1.5-flash-001
    /// </remarks>
    property BaseModel: string read FBaseModel write FBaseModel;
    /// <summary>
    /// Optional. Controls the randomness of the output.
    /// </summary>
    /// <remarks>
    /// Values can range over [0.0,1.0], inclusive. A value closer to 1.0 will produce responses that are more varied, while a value closer to 0.0 will typically result in less surprising responses from the model.
    /// This value specifies default to be the one used by the base model while creating the model.
    /// </remarks>
    property Temperature: Double read FTemperature write FTemperature;
    /// <summary>
    /// Optional. For Nucleus sampling.
    /// </summary>
    /// <remarks>
    /// Nucleus sampling considers the smallest set of tokens whose probability sum is at least topP.
    /// This value specifies default to be the one used by the base model while creating the model.
    /// </remarks>
    property TopP: Double read FTopP write FTopP;
    /// <summary>
    /// Optional. For Top-k sampling.
    /// </summary>
    /// <remarks>
    /// Top-k sampling considers the set of topK most probable tokens. This value specifies default to be used by the backend while making the call to the model.
    /// This value specifies default to be the one used by the base model while creating the model.
    /// </remarks>
    property TopK: Integer read FTopK write FTopK;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a collection of tuned models along with pagination information.
  /// </summary>
  /// <remarks>
  /// The <c>TTunedModels</c> class contains a list of <c>TTunedModel</c> instances and a token for fetching the next page of results.
  /// This is typically used when listing tuned models with support for pagination.
  /// </remarks>
  TTunedModels = class
  private
    FTunedModels: TArray<TTunedModel>;
    FNextPageToken: string;
  public
    /// <summary>
    /// Gets or sets the array of tuned models.
    /// </summary>
    /// <value>
    /// An array of <c>TTunedModel</c> instances representing the tuned models.
    /// </value>
    property TunedModels: TArray<TTunedModel> read FTunedModels write FTunedModels;
    /// <summary>
    /// Gets or sets the token used to retrieve the next page of tuned models.
    /// </summary>
    /// <value>
    /// A string token that can be used to fetch the next page of results. If empty, there are no more pages.
    /// </value>
    property NextPageToken: string read FNextPageToken write FNextPageToken;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Class defined for compatibility with asynchrony handling.
  /// </summary>
  TModelDelete = class
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TModelTraining</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModelTraining</c> type extends the <c>TAsynParams&lt;TModelTraining&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModelTraining = TAsynCallBack<TModelTraining>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TTunedModel</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTunedModel</c> type extends the <c>TAsynParams&lt;TTunedModel&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTunedModel = TAsynCallBack<TTunedModel>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TTunedModels</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTunedModels</c> type extends the <c>TAsynParams&lt;TTunedModels&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTunedModels = TAsynCallBack<TTunedModels>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TModelDelete</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModelDelete</c> type extends the <c>TAsynParams&lt;TModelDelete&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModelDelete = TAsynCallBack<TModelDelete>;

  /// <summary>
  /// Provides methods for managing fine-tuned models, including creation, listing, retrieval, updating, and deletion.
  /// </summary>
  /// <remarks>
  /// The <c>TFineTuneRoute</c> class extends <c>TGeminiAPIRoute</c> and interacts with the Gemini API to perform operations related to fine-tuning models.
  /// It supports both synchronous and asynchronous operations, allowing for flexible integration into various application workflows.
  /// </remarks>
  TFineTuneRoute = class(TGeminiAPIRoute)
    /// <summary>
    /// Asynchronously creates a new model training operation using a JSON object.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing the parameters for the model training.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynModelTraining</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   ASynCreate('JSONObject',
    ///    function : TAsynModelTraining
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Model: TModelTraining)
    ///        begin
    ///          // Trigger the success method
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    /// </remarks>
    procedure ASynCreate(const Value: TJSONObject; CallBacks: TFunc<TAsynModelTraining>); overload;
    /// <summary>
    /// Asynchronously creates a new model training operation using a parameter procedure.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures <c>TTunedModelParams</c> for the model training.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynModelTraining</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   ASynCreate('JSONObject',
    ///    procedure (Params: TTunedModelParams)
    ///    begin
    ///      // Set parameters
    ///    end,
    ///
    ///    function : TAsynModelTraining
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Model: TModelTraining)
    ///        begin
    ///          // Trigger the success method
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    /// </remarks>
    procedure ASynCreate(ParamProc: TProc<TTunedModelParams>; CallBacks: TFunc<TAsynModelTraining>); overload;
    /// <summary>
    /// Asynchronously retrieves a list of tuned models with pagination support.
    /// </summary>
    /// <param name="PageSize">
    /// The maximum number of tuned models to return in the response.
    /// </param>
    /// <param name="PageToken">
    /// A token identifying the page of results to retrieve.
    /// </param>
    /// <param name="Filter">
    /// A filter string to constrain the results.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynTunedModels</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   // Declare the variable "Next" as a string type earlier in the code.
    ///   ASynList(PageSize, Next
    ///    function : TAsynTunedModels
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Models: TTunedModels)
    ///        begin
    ///          // Trigger the success method
    ///          Next := Models.NextPageToken;
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    /// </remarks>
    procedure ASynList(const PageSize: Integer; const PageToken, Filter: string;
      CallBacks: TFunc<TAsynTunedModels>);
    /// <summary>
    /// Asynchronously retrieves a specific tuned model by its name.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynTunedModel</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   ASynRetrieve('FileName_to_retrieve',
    ///    function : TAsynTunedModel
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Model: TTunedModel)
    ///        begin
    ///          // Trigger the success method
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    /// </remarks>
    procedure ASynRetrieve(const TunedModelName: string; CallBacks: TFunc<TAsynTunedModel>);
    /// <summary>
    /// Asynchronously updates a tuned model using a JSON object.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to update.
    /// </param>
    /// <param name="UpdateMask">
    /// A mask specifying which fields to update.
    /// </param>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing the updated values for the tuned model.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynTunedModel</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   ASynUpdate(TunedModelName, UpdateMask, Value,
    ///    function : TAsynTunedModel
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Model: TTunedModel)
    ///        begin
    ///          // Trigger the success method
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    /// </remarks>
    procedure ASynUpdate(const TunedModelName: string; const UpdateMask: string; const Value: TJSONObject;
      CallBacks: TFunc<TAsynTunedModel>); overload;
    /// <summary>
    /// Asynchronously updates a tuned model using a parameter procedure.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to update.
    /// </param>
    /// <param name="UpdateMask">
    /// A mask specifying which fields to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures <c>TTunedModelParams</c> with the updated values.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynTunedModel</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   ASynUpdate(TunedModelName, UpdateMask,
    ///    procedure (Params: TTunedModelParams)
    ///    begin
    ///      // Set parameters
    ///    end,
    ///    function : TAsynTunedModel
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Model: TTunedModel)
    ///        begin
    ///          // Trigger the success method
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    procedure ASynUpdate(const TunedModelName: string; const UpdateMask: string; ParamProc: TProc<TTunedModelParams>;
      CallBacks: TFunc<TAsynTunedModel>); overload;
    /// <summary>
    /// Asynchronously deletes a tuned model by its name.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A callback function that handles the asynchronous response of type <c>TAsynModelDelete</c>.
    /// </param>
    /// <remarks>
    /// <code>
    ///   ASynDelete(TunedModelName,
    ///    function : TAsynModelDelete
    ///    begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject)
    ///        begin
    ///           // Trigger the start method
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Model: TModelDelete)
    ///        begin
    ///          // Trigger the success method
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Trigger the error method
    ///        end;
    ///    end);
    /// </code>
    /// </remarks>
    procedure ASynDelete(const TunedModelName: string; CallBacks: TFunc<TAsynModelDelete>);
    /// <summary>
    /// Creates a new model training operation using a JSON object.
    /// </summary>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing the parameters for the model training.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TModelTraining</c> representing the training operation.
    /// </returns>
    /// <remarks>
    /// <code>
    ///   var ModelTraining := Create(
    ///     procedure (Params: TTunedModelParams)
    ///     begin
    ///       // Set parameters
    ///     end);
    ///   try
    ///     // Do something
    ///   finally
    ///     ModelTraining.Free;
    ///   end;
    /// </code>
    /// </remarks>
    function Create(ParamProc: TProc<TTunedModelParams>): TModelTraining; overload;
    /// <summary>
    /// Retrieves a list of tuned models with pagination support.
    /// </summary>
    /// <param name="PageSize">
    /// The maximum number of tuned models to return in the response.
    /// </param>
    /// <param name="PageToken">
    /// A token identifying the page of results to retrieve.
    /// </param>
    /// <param name="Filter">
    /// A filter string to constrain the results.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TTunedModels</c> containing the list of tuned models and pagination information.
    /// </returns>
    function Create(const Value: TJSONObject): TModelTraining; overload;
    /// <summary>
    /// Creates a new model training operation using a parameter procedure.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures <c>TTunedModelParams</c> for the model training.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TModelTraining</c> representing the training operation.
    /// </returns>
    function List(const PageSize: Integer; const PageToken, Filter: string): TTunedModels;
    /// <summary>
    /// Retrieves a specific tuned model by its name.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to retrieve.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TTunedModel</c> representing the retrieved tuned model.
    /// </returns>
    function Retrieve(const TunedModelName: string): TTunedModel;
    /// <summary>
    /// Updates a tuned model using a parameter procedure.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to update.
    /// </param>
    /// <param name="UpdateMask">
    /// A mask specifying which fields to update.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures <c>TTunedModelParams</c> with the updated values.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TTunedModel</c> representing the updated tuned model.
    /// </returns>
    /// <remarks>
    /// <code>
    ///   var TunedModel := Update(TunedModelName, UpdateMask,
    ///     procedure (Params: TTunedModelParams)
    ///     begin
    ///       // Set parameters
    ///     end);
    ///   try
    ///     // Do something
    ///   finally
    ///     TunedModel.Free;
    ///   end;
    /// </code>
    /// </remarks>
    function Update(const TunedModelName: string; const UpdateMask: string; ParamProc: TProc<TTunedModelParams>): TTunedModel; overload;
    /// <summary>
    /// Updates a tuned model using a JSON object.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to update.
    /// </param>
    /// <param name="UpdateMask">
    /// A mask specifying which fields to update.
    /// </param>
    /// <param name="Value">
    /// A <c>TJSONObject</c> containing the updated values for the tuned model.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TTunedModel</c> representing the updated tuned model.
    /// </returns>
    function Update(const TunedModelName: string; const UpdateMask: string; const Value: TJSONObject): TTunedModel; overload;
    /// <summary>
    /// Deletes a tuned model by its name.
    /// </summary>
    /// <param name="TunedModelName">
    /// The unique name of the tuned model to delete.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TModelDelete</c> representing the delete operation.
    /// </returns>
    function Delete(const TunedModelName: string): TModelDelete;
  end;

implementation

uses
  System.StrUtils, System.IOUtils, System.Rtti, Rest.Json;

{ TModelStateHelper }

class function TModelStateHelper.Create(const Value: string): TModelState;
begin
  var Index := IndexStr(AnsiUpperCase(Value), [
         'STATE_UNSPECIFIED', 'CREATING', 'ACTIVE', 'FAILED']);
  if Index = -1 then
    raise Exception.CreateFmt('"Model state" unknown : %s', [Value]);
  Result := TModelState(Index);
end;

function TModelStateHelper.ToString: string;
begin
  case Self of
    STATE_UNSPECIFIED:
      Exit('STATE_UNSPECIFIED');
    CREATING:
      Exit('CREATING');
    ACTIVE:
      Exit('ACTIVE');
    FAILED:
      Exit('FAILED');
  end;
end;

{ TModelStateInterceptor }

function TModelStateInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TModelState>.ToString;
end;

procedure TModelStateInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TModelState.Create(Arg)));
end;

{ TTunedModelParams }

function TTunedModelParams.BaseModel(const Value: string): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('baseModel', Value));
end;

function TTunedModelParams.Description(const Value: string): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('description', Value));
end;

function TTunedModelParams.DisplayName(const Value: string): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('displayName', Value));
end;

function TTunedModelParams.ReaderProjectNumbers(
  const Value: TArray<Integer>): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('readerProjectNumbers', Value));
end;

function TTunedModelParams.Temperature(const Value: Double): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('temperature', Value));
end;

function TTunedModelParams.TopK(const Value: Integer): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('topK', Value));
end;

function TTunedModelParams.TopP(const Value: Double): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('topP', Value));
end;

function TTunedModelParams.TunedModelSource(
  const Value: string): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('tunedModelSource', TJSONObject.Create.AddPair('tunedModel', Value)));
end;

function TTunedModelParams.TuningTask(
  const Value: TTuningTaskParams): TTunedModelParams;
begin
  Result := TTunedModelParams(Add('tuningTask', Value.Detach));
end;

{ TTuningExample }

class function TTuningExample.AddItem(const Input,
  Output: string): TTuningExample;
begin
  Result := TTuningExample.Create.TextInput(Input).Output(Output);
end;

function TTuningExample.Output(const Value: string): TTuningExample;
begin
  Result := TTuningExample(Add('output', Value));
end;

function TTuningExample.TextInput(
  const Value: string): TTuningExample;
begin
  Result := TTuningExample(Add('textInput', Value));
end;

{ THyperparametersParams }

function THyperparametersParams.BatchSize(const Value: Integer): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('batchSize', Value));
end;

function THyperparametersParams.EpochCount(const Value: Integer): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('epochCount', Value));
end;

function THyperparametersParams.LearningRate(const Value: Double): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('learningRate', Value));
end;

function THyperparametersParams.LearningRateMultiplier(
  const Value: Double): THyperparametersParams;
begin
  Result := THyperparametersParams(Add('learningRateMultiplier', Value));
end;

{ TTuningTask }

function TTuningTaskParams.Hyperparameters(
  ParamProc: TProcRef<THyperparametersParams>): TTuningTaskParams;
begin
  var Params := THyperparametersParams.Create;
  if Assigned(ParamProc) then
    ParamProc(Params);
  Result := TTuningTaskParams(Add('hyperparameters', Params.Detach));
end;

function TTuningTaskParams.TrainingData(
  const JSONLFileName: string): TTuningTaskParams;
begin
  Result := TTuningTaskParams(Add('training_data', TTuningTaskHelper.ExamplesBuilder(JSONLFileName)));
end;

function TTuningTaskParams.TrainingData(
  const Value: TArray<TTuningExample>): TTuningTaskParams;
begin
  Result := TTuningTaskParams(Add('training_data', TTuningTaskHelper.ExamplesBuilder(Value)));
end;

function TTuningTaskParams.TrainingData(
  const Value: TJSONObject): TTuningTaskParams;
begin
  Result := TTuningTaskParams(Add('training_data', Value));
end;

{ TTuningTaskHelper }

class function TTuningTaskHelper.ExamplesBuilder(
  const Value: TArray<TTuningExample>): TJSONObject;
begin
  {--- Add examples to a JSON array }
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);

  {--- Building the JSON string for the API request }
  Result := TJSONObject.Create.AddPair('examples', TJSONObject.Create.AddPair('examples', JSONArray));
end;

class function TTuningTaskHelper.ExamplesBuilder(
  const FileName: string): TJSONObject;
begin
  {--- Check the existence of the file.}
  if not FileExists(FileName) then
    raise Exception.CreateFmt('Training file not found : %s', [FileName]);

  {--- Try to load the data from the file to a JSON array }
  var JSONArray := FileDataToJSONArray(FileName);
  if not Assigned(JSONArray) then
    raise Exception.CreateFmt('Error importing training file : %s', [FileName]);

  {--- Building the JSON string for the API request }
  Result := TJSONObject.Create.AddPair('examples', TJSONObject.Create.AddPair('examples', JSONArray));
end;

class function TTuningTaskHelper.FileDataToJSONArray(
  const FileName: string): TJSONArray;
begin
  case IndexStr(ExtractFileExt(FileName).ToLower, ['.csv', '.jsonl']) of
    0 : Result := LoadFromCSV(FileName);
    1 : Result := LoadFromJSONL(FileName);
    else
      raise Exception.Create('Trainig examples: Only CSV (using `;` as a separator) or JSONL files are supported');
  end;
end;

class function TTuningTaskHelper.LoadFromCSV(
  const FileName: string; Separator: Char): TJSONArray;
begin
  Result := TJSONArray.Create;
  var CSVFile := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  var Reader := TStreamReader.Create(CSVFile, TEncoding.UTF8);
  try
    try
      var Index := 0;
      while not Reader.EndOfStream do
        begin
          Inc(Index);
          if Index = 1 then
            Continue;
          var Fields := Reader.ReadLine.Split([Separator]);
          if Length(Fields) = 2 then
            begin
              Result.Add( TJSONOBject.Create
                .AddPair('text_input', Fields[0].Trim)
                .AddPair('output', Fields[1].Trim));
            end;
        end;
    except
      FreeAndNil(Result);
    end;
  finally
    Reader.Free;
    CSVFile.Free;
  end;
end;

class function TTuningTaskHelper.LoadFromJSONL(
  const FileName: string): TJSONArray;
begin
  Result := TJSONArray.Create;
  var JSONLFile := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  var StreamReader := TStreamReader.Create(JSONLFile, TEncoding.UTF8);
  try
    try
      while not StreamReader.EndOfStream do
        begin
          Result.Add(TJSONObject.ParseJSONValue(StreamReader.ReadLine) as TJSONObject)
        end;
    except
      FreeAndNil(Result);
    end;
  finally
    StreamReader.Free;
    JSONLFile.Free;
  end;
end;

{ TFineTuneRoute }

procedure TFineTuneRoute.ASynCreate(const Value: TJSONObject;
  CallBacks: TFunc<TAsynModelTraining>);
begin
  with TAsynCallBackExec<TAsynModelTraining, TModelTraining>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModelTraining
      begin
        Result := Self.Create(Value);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuneRoute.ASynCreate(ParamProc: TProc<TTunedModelParams>;
  CallBacks: TFunc<TAsynModelTraining>);
begin
  with TAsynCallBackExec<TAsynModelTraining, TModelTraining>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModelTraining
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuneRoute.ASynDelete(const TunedModelName: string;
  CallBacks: TFunc<TAsynModelDelete>);
begin
  with TAsynCallBackExec<TAsynModelDelete, TModelDelete>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModelDelete
      begin
        Result := Self.Delete(TunedModelName);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuneRoute.ASynList(const PageSize: Integer; const PageToken,
  Filter: string; CallBacks: TFunc<TAsynTunedModels>);
begin
  with TAsynCallBackExec<TAsynTunedModels, TTunedModels>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTunedModels
      begin
        Result := Self.List(PageSize, PageToken, Filter);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuneRoute.ASynRetrieve(const TunedModelName: string;
  CallBacks: TFunc<TAsynTunedModel>);
begin
  with TAsynCallBackExec<TAsynTunedModel, TTunedModel>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTunedModel
      begin
        Result := Self.Retrieve(TunedModelName);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuneRoute.ASynUpdate(const TunedModelName, UpdateMask: string;
  ParamProc: TProc<TTunedModelParams>; CallBacks: TFunc<TAsynTunedModel>);
begin
  with TAsynCallBackExec<TAsynTunedModel, TTunedModel>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTunedModel
      begin
        Result := Self.Update(TunedModelName, UpdateMask, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFineTuneRoute.ASynUpdate(const TunedModelName, UpdateMask: string;
  const Value: TJSONObject; CallBacks: TFunc<TAsynTunedModel>);
begin
  with TAsynCallBackExec<TAsynTunedModel, TTunedModel>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTunedModel
      begin
        Result := Self.Update(TunedModelName, UpdateMask, Value);
      end);
  finally
    Free;
  end;
end;

function TFineTuneRoute.Create(
  ParamProc: TProc<TTunedModelParams>): TModelTraining;
begin
  Result := API.Post<TModelTraining, TTunedModelParams>('tunedModels', ParamProc);
end;

function TFineTuneRoute.Create(
  const Value: TJSONObject): TModelTraining;
begin
  try
    Result := API.Post<TModelTraining>('tunedModels', Value);
  finally
    Value.Free;
  end;
end;

function TFineTuneRoute.Delete(const TunedModelName: string): TModelDelete;
begin
  Result := API.Delete<TModelDelete>(TunedModelName);
end;

function TFineTuneRoute.List(const PageSize: Integer;
  const PageToken, Filter: string): TTunedModels;
begin
  Result := API.Get<TTunedModels>('tunedModels', ParamsBuilder(PageSize, PageToken, Filter));
end;

function TFineTuneRoute.Retrieve(const TunedModelName: string): TTunedModel;
begin
  Result := API.Get<TTunedModel>(TunedModelName);
end;

function TFineTuneRoute.Update(const TunedModelName, UpdateMask: string;
  ParamProc: TProc<TTunedModelParams>): TTunedModel;
begin
  Result := API.Patch<TTunedModel, TTunedModelParams>(TunedModelName, UpdateMask, ParamProc);
end;

function TFineTuneRoute.Update(const TunedModelName: string;
  const UpdateMask: string; const Value: TJSONObject): TTunedModel;
begin
  try
    Result := API.Patch<TTunedModel>(TunedModelName, UpdateMask, Value);
  finally
    Value.Free;
  end;
end;

{ TTuningTask }

destructor TTuningTask.Destroy;
begin
  for var Item in FSnapshots do
    Item.Free;
  if Assigned(FHyperparameters) then
    FHyperparameters.Free;
  inherited;
end;

{ TTunedModel }

destructor TTunedModel.Destroy;
begin
  if Assigned(FTuningTask) then
    FTuningTask.Free;
  if Assigned(FTunedModelSource) then
    FTunedModelSource.Free;
  inherited;
end;

{ TTunedModels }

destructor TTunedModels.Destroy;
begin
  for var Item in FTunedModels do
    Item.Free;
  inherited;
end;

end.
