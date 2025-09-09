import dlt
from typing import Union, Sequence
from dlt.common.configuration.specs import (
    GcpOAuthCredentials,
    GcpServiceAccountCredentials
)


@dlt.source
def google_spreadsheet(
    spreadsheet_id: str,
    sheet_names: Sequence[str],
    credentials: Union[
        GcpServiceAccountCredentials, 
        GcpOAuthCredentials, 
        str
    ] = dlt.secrets.value
):
    """Google Sheets source that loads data from specified sheets"""
    from googleapiclient.discovery import build
    
    def _initialize_sheets(credentials):
        service = build("sheets", "v4", credentials=credentials.to_native_credentials())
        return service
    
    sheets = _initialize_sheets(credentials)
    
    def get_sheet(sheet_name: str):
        result = sheets.spreadsheets().values().get(
            spreadsheetId=spreadsheet_id,
            range=sheet_name,
            valueRenderOption="UNFORMATTED_VALUE",
            dateTimeRenderOption="FORMATTED_STRING"
        ).execute()
        
        values = result.get("values", [])
        if not values:
            return
            
        headers = values[0] if values else []
        for row in values[1:]:
            # Pad row with None values if shorter than headers
            padded_row = row + [None] * (len(headers) - len(row))
            yield {header: value for header, value in zip(headers, padded_row)}
    
    return [
        dlt.resource(get_sheet(name), name=name, write_disposition="replace")
        for name in sheet_names
    ]


def run(environment: str = "dev", spreadsheet_id: str = None, sheet_names: Sequence[str] = None):
    """Run the Google Sheets pipeline"""
    pipeline = dlt.pipeline(
        pipeline_name=f"google_sheets_{environment}",
        destination="bigquery",
        dataset_name=f"raw_google_sheets_{environment}"
    )
    
    if not spreadsheet_id or not sheet_names:
        raise ValueError("spreadsheet_id and sheet_names are required")
    
    load_info = pipeline.run(
        google_spreadsheet(
            spreadsheet_id=spreadsheet_id,
            sheet_names=sheet_names
        )
    )
    print(load_info)
    return load_info


if __name__ == "__main__":
    # Example usage - replace with your actual spreadsheet ID and sheet names
    spreadsheet_id = "your_spreadsheet_id_here"
    sheet_names = ["Sheet1", "Sheet2"]
    run(spreadsheet_id=spreadsheet_id, sheet_names=sheet_names)