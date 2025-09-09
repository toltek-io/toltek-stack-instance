import dlt
from toltek.extraction.sources.weather_api_source import weather_api


def run(environment: str = "dev"):
    pipeline = dlt.pipeline(
        pipeline_name=f"weather_api_{environment}",
        destination="bigquery",
        dataset_name=f"raw_weather_{environment}"
    )
    
    source = weather_api()
    load_info = pipeline.run(source)
    print(load_info)
    return load_info


if __name__ == "__main__":
    run()