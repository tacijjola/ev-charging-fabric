[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "end_reason_mapping_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared end_reason_mapping = let
  Source = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Source{[workspaceId = "."]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "LH_EV"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "landing"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "reference"]}[Content],
  Navigation = #"Navigation 5"{[Name = "end_reason_mapping.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 3, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"ended_by", type text}, {"end_reason_group", type text}, {"is_fault", Int64.Type}}, "en")
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "site_reference_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared site_reference = let
  Source = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Source{[workspaceId = "."]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "LH_EV"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "landing"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "reference"]}[Content],
  Navigation = #"Navigation 5"{[Name = "site_reference.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 9, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"site_code", type text}, {"site_name", type text}, {"address", type text}, {"postal_code", Int64.Type}, {"latitude", type number}, {"longitude", type number}, {"port_count", Int64.Type}, {"first_session_date", type date}, {"fee_policy", type text}}, "en")
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "site_reference_change_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared site_reference_change = let
  Source = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Source{[workspaceId = "."]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "LH_EV"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "landing"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "reference"]}[Content],
  Navigation = #"Navigation 5"{[Name = "site_reference_change_2017-08-01.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 3, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"site_code", type text}, {"fee_policy", type text}, {"effective_date", type date}}, "en")
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "site_managers_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared site_managers = let
  Source = Lakehouse.Contents([HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  #"Navigation 1" = Source{[workspaceId = "."]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseName = "LH_EV"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "landing"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "reference"]}[Content],
  Navigation = #"Navigation 5"{[Name = "site_managers.csv"]}[Content],
  #"Imported CSV" = Csv.Document(Navigation, [Delimiter = ",", Columns = 2, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Lowercased text" = Table.TransformColumns(#"Promoted headers", {{"manager_upn", each Text.Lower(_), type nullable text}})
in
  #"Lowercased text";
shared site_managers_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "ffb7a8a2-5e81-4faf-8d12-ece0214fe2f1"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "baf7efc9-7906-4ca6-b0f9-8a0ef530373f"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "stg"]}[Data],
  TableNavigation = Navigation_3{[Name = "site_managers"]}?[Data]?
in
  TableNavigation;
shared end_reason_mapping_DataDestination = let
  Pattern = Fabric.Warehouse([HierarchicalNavigation = true, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "WH_EV_Gold"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "stg"]}[Data],
  TableNavigation = Navigation_3{[Name = "end_reason_mapping"]}?[Data]?
in
  TableNavigation;
shared site_reference_DataDestination = let
  Pattern = Fabric.Warehouse([HierarchicalNavigation = true, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "WH_EV_Gold"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "stg"]}[Data],
  TableNavigation = Navigation_3{[Name = "site_reference"]}?[Data]?
in
  TableNavigation;
shared site_reference_change_DataDestination = let
  Pattern = Fabric.Warehouse([HierarchicalNavigation = true, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "WH_EV_Gold"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "stg"]}[Data],
  TableNavigation = Navigation_3{[Name = "site_reference_change"]}?[Data]?
in
  TableNavigation;
