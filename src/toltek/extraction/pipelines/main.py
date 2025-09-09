"""Simple pipeline runner for dlt data extraction."""

import os
import dlt
from enum import Enum
from typing import Optional
from dataclasses import dataclass


class Environment(str, Enum):
    """Available environments."""
    DEV = "dev"
    PROD = "prod"


@dataclass
class PipelineResult:
    """Pipeline execution result."""
    source_name: str
    success: bool
    error_message: Optional[str] = None


class PipelineRunner:
    """Simple pipeline runner for dlt data extraction."""
    
    def __init__(self, environment: Environment = Environment.DEV):
        """Initialize pipeline runner."""
        self.environment = environment
        
        self.pipeline = dlt.pipeline(
            pipeline_name=f"extraction_{environment.value}",
            destination="bigquery",
            dataset_name=f"dlt_{environment.value}"
        )
    
    def _execute_source(self, source_name: str, source_func) -> PipelineResult:
        """Execute a source with basic error handling."""
        try:
            source = source_func()
            load_info = self.pipeline.run(source)
            
            if load_info.has_failed_jobs:
                failed_jobs = [
                    job for job in load_info.load_packages[0].jobs.values() 
                    if job.exception
                ]
                error_messages = [str(job.exception) for job in failed_jobs]
                error_message = "; ".join(error_messages)
                
                return PipelineResult(
                    source_name=source_name,
                    success=False,
                    error_message=error_message
                )
            
            return PipelineResult(
                source_name=source_name,
                success=True
            )
            
        except Exception as e:
            return PipelineResult(
                source_name=source_name,
                success=False,
                error_message=str(e)
            )
    
    def run_google_sheets_pipeline(self) -> PipelineResult:
        """Run Google Sheets pipeline using dlt's verified source."""
        def _create_source():
            from dlt.sources import google_sheets
            return google_sheets()
        
        return self._execute_source("google_sheets", _create_source)
    
    def run_weather_api_pipeline(self) -> PipelineResult:
        """Run Weather API pipeline using custom REST API source."""
        def _create_source():
            from toltek.extraction.sources.weather_api_source import weather_api
            return weather_api()
        
        return self._execute_source("weather_api", _create_source)
    
    def run_cloud_storage_pipeline(self) -> PipelineResult:
        """Run Cloud Storage pipeline using dlt's filesystem verified source."""
        def _create_source():
            from dlt.sources import filesystem
            return filesystem(bucket_url="gs://your-bucket")
        
        return self._execute_source("gcs", _create_source)


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Run dlt pipelines")
    parser.add_argument(
        "--source", 
        required=True, 
        choices=["google_sheets", "weather_api", "cloud_storage", "all"],
        default="all",
        help="Source type to run"
    )
    parser.add_argument(
        "--env", 
        choices=["dev", "prod"], 
        default="dev",
        help="Environment to run in"
    )
    
    args = parser.parse_args()
    
    environment = Environment(args.env)
    runner = PipelineRunner(environment)
    
    results = []
    
    if args.source == "google_sheets":
        results.append(runner.run_google_sheets_pipeline())
    elif args.source == "weather_api":
        results.append(runner.run_weather_api_pipeline())
    elif args.source == "cloud_storage":
        results.append(runner.run_cloud_storage_pipeline())
    elif args.source == "all":
        results = [
            runner.run_google_sheets_pipeline(),
            runner.run_weather_api_pipeline(),
            runner.run_cloud_storage_pipeline()
        ]
    
    failed_runs = [r for r in results if not r.success]
    
    if failed_runs:
        for result in failed_runs:
            print(f"Pipeline {result.source_name} failed: {result.error_message}")
        exit(1)
    
    print("All pipelines completed successfully")
    exit(0)


if __name__ == "__main__":
    main()