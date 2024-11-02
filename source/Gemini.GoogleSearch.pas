unit Gemini.GoogleSearch;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON, REST.JsonReflect, REST.Json.Types,
  Gemini.API.Params, Gemini.API;

type
  /// <summary>
  /// Configures dynamic retrieval settings for Google Search operations.
  /// </summary>
  TDynamicRetrievalConfig = class(TJSONParam)
  public
    /// <summary>
    /// Sets the mode for dynamic retrieval.
    /// </summary>
    /// <param name="Value">
    /// A string representing the retrieval mode. For example, "MODE_DYNAMIC".
    /// </param>
    /// <returns>
    /// Returns the updated <c>TDynamicRetrievalConfig</c> instance for method chaining.
    /// </returns>
    function Mode(const Value: string): TDynamicRetrievalConfig;
    /// <summary>
    /// Sets the dynamic threshold for retrieval confidence.
    /// </summary>
    /// <param name="Value">
    /// A double representing the threshold value. Defaults to <c>0.7</c> if not specified.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TDynamicRetrievalConfig</c> instance for method chaining.
    /// </returns>
    function DynamicThreshold(const Value: Double): TDynamicRetrievalConfig;
  end;

  /// <summary>
  /// Configures Google Search retrieval settings within chat parameters.
  /// </summary>
  TGoogleSearchRetrieval = class(TJSONParam)
  public
    /// <summary>
    /// Configures dynamic retrieval settings for Google Search.
    /// </summary>
    /// <param name="Mode">
    /// A string specifying the retrieval mode, such as "MODE_DYNAMIC".
    /// </param>
    /// <param name="DynamicThreshold">
    /// A double indicating the confidence threshold for dynamic retrieval. Defaults to <c>0.7</c>.
    /// </param>
    /// <returns>
    /// Returns the updated <c>TGoogleSearchRetrieval</c> instance for method chaining.
    /// </returns>
    function DynamicRetrievalConfig(const Mode: string; const DynamicThreshold: Double): TGoogleSearchRetrieval;
  end;

  /// <summary>
  /// Represents a web source with a URI and title.
  /// </summary>
  TWeb = class
  private
    FUri: string;
    FTitle: string;
  public
    /// <summary>
    /// The URI of the web source.
    /// </summary>
    property Uri: string read FUri write FUri;
    /// <summary>
    /// The title of the web source.
    /// </summary>
    property Title: string read FTitle write FTitle;
  end;

  /// <summary>
  /// Represents a grounding chunk containing web information.
  /// </summary>
  TGroundingChunksItem = class
  private
    FWeb: TWeb;
  public
    /// <summary>
    /// The web source associated with this grounding chunk.
    /// </summary>
    property Web: TWeb read FWeb write FWeb;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the entry point of a search within grounding metadata.
  /// </summary>
  TSearchEntryPoint = class
  private
    FRenderedContent: string;
  public
    /// <summary>
    /// The rendered content of the search entry point, typically containing HTML or styled text.
    /// </summary>
    property RenderedContent: string read FRenderedContent write FRenderedContent;
  end;

  /// <summary>
  /// Represents a text segment within grounding metadata.
  /// </summary>
  TSegment = class
  private
    FStartIndex: Int64;
    FEndIndex: Int64;
    FText: string;
  public
    /// <summary>
    /// The starting index of the text segment.
    /// </summary>
    property StartIndex: Int64 read FStartIndex write FStartIndex;
    /// <summary>
    /// The ending index of the text segment.
    /// </summary>
    property EndIndex: Int64 read FEndIndex write FEndIndex;
    /// <summary>
    /// The textual content of the segment.
    /// </summary>
    property Text: string read FText write FText;
  end;

  /// <summary>
  /// Represents the support details for a grounding segment.
  /// </summary>
  TGroundingSupportsItem = class
  private
    FSegment: TSegment;
    FGroundingChunkIndices: TArray<Int64>;
    FConfidenceScores: TArray<Double>;
  public
    /// <summary>
    /// The text segment associated with this grounding support.
    /// </summary>
    property Segment: TSegment read FSegment write FSegment;
    /// <summary>
    /// Indices referencing the grounding chunks that support this segment.
    /// </summary>
    property GroundingChunkIndices: TArray<Int64> read FGroundingChunkIndices write FGroundingChunkIndices;
    /// <summary>
    /// Confidence scores corresponding to each grounding chunk index.
    /// </summary>
    property ConfidenceScores: TArray<Double> read FConfidenceScores write FConfidenceScores;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Contains metadata related to grounding information from Google Search.
  /// </summary>
  TGroundingMetadata = class
  private
    FSearchEntryPoint: TSearchEntryPoint;
    FGroundingChunks: TArray<TGroundingChunksItem>;
    FWebSearchQueries: TArray<string>;
  public
    /// <summary>
    /// The entry point of the search, containing rendered content.
    /// </summary>
    property SearchEntryPoint: TSearchEntryPoint read FSearchEntryPoint write FSearchEntryPoint;
    /// <summary>
    /// A collection of grounding chunks providing detailed web sources.
    /// </summary>
    property GroundingChunks: TArray<TGroundingChunksItem> read FGroundingChunks write FGroundingChunks;
    /// <summary>
    /// The search queries used to retrieve grounding information.
    /// </summary>
    property WebSearchQueries: TArray<string> read FWebSearchQueries write FWebSearchQueries;
    destructor Destroy; override;
  end;

implementation

{ TDynamicRetrievalConfig }

function TDynamicRetrievalConfig.DynamicThreshold(
  const Value: Double): TDynamicRetrievalConfig;
begin
  Result := TDynamicRetrievalConfig(Add('dynamic_threshold', Value));
end;

function TDynamicRetrievalConfig.Mode(
  const Value: string): TDynamicRetrievalConfig;
begin
  Result := TDynamicRetrievalConfig(Add('mode', Value));
end;

{ TGoogleSearchRetrieval }

function TGoogleSearchRetrieval.DynamicRetrievalConfig(const Mode: string;
  const DynamicThreshold: Double): TGoogleSearchRetrieval;
begin
  var Value := TDynamicRetrievalConfig.Create.Mode(Mode).DynamicThreshold(DynamicThreshold);
  Result := TGoogleSearchRetrieval(Add('dynamic_retrieval_config', Value.Detach));
end;

{ TGroundingMetadata }

destructor TGroundingMetadata.Destroy;
begin
  if Assigned(FSearchEntryPoint) then
    FSearchEntryPoint.Free;
  for var Item in FGroundingChunks do
      Item.Free;
  inherited;
end;

{ TGroundingChunksItem }

destructor TGroundingChunksItem.Destroy;
begin
  if Assigned(FWeb) then
    FWeb.Free;
  inherited;
end;

{ TGroundingSupportsItem }

destructor TGroundingSupportsItem.Destroy;
begin
  if Assigned(FSegment) then
    FSegment.Free;
  inherited;
end;

end.
