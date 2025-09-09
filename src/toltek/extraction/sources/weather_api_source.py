"""Weather API source using dlt's native REST API source."""

import dlt
from dlt.sources.rest_api import rest_api_source
from typing import List, Dict, Any


@dlt.source
def weather_api(
    api_key: str = dlt.secrets.value,
    cities: List[str] = ["London", "New York", "Tokyo"],
    base_url: str = "https://api.openweathermap.org/data/2.5/"
):
    """
    Weather API source using dlt's native REST API source.
    
    Args:
        api_key: OpenWeatherMap API key (from dlt secrets)
        cities: List of cities to get weather for
        base_url: Base URL for the weather API
    """
    
    def add_metadata(response_data: Dict[str, Any]) -> Dict[str, Any]:
        """Add extraction metadata to response data."""
        response_data["extraction_timestamp"] = dlt.common.pendulum.now().isoformat()
        return response_data
    
    # Create resources for each city
    resources = []
    for city in cities:
        config = {
            "client": {
                "base_url": base_url,
                "params": {
                    "appid": api_key,
                    "units": "metric"
                }
            },
            "resources": [
                {
                    "name": f"weather_{city.lower().replace(' ', '_')}",
                    "endpoint": {
                        "path": "weather",
                        "params": {"q": city}
                    },
                    "data_selector": "$",
                    "processing_steps": [
                        {
                            "filter": add_metadata
                        },
                        {
                            "add_field": {
                                "field_name": "city_requested",
                                "value": city
                            }
                        }
                    ]
                }
            ]
        }
        
        source = rest_api_source(config)
        resources.extend(source.resources.values())
    
    return resources


