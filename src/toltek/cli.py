#!/usr/bin/env python3
"""CLI for toltek data stack operations."""

import os
import sys
import argparse
import subprocess
from pathlib import Path

# Add src to path
sys.path.append(str(Path(__file__).parent.parent))

from toltek.extraction.pipelines import google_sheets_pipeline, weather_api_pipeline


AVAILABLE_EXTRACTION_PIPELINES = {
    "google_sheets": google_sheets_pipeline.run,
    "weather_api": weather_api_pipeline.run
}


def run_extraction_pipeline(pipeline_name: str, environment: str) -> bool:
    """Run a specific extraction pipeline."""
    if pipeline_name not in AVAILABLE_EXTRACTION_PIPELINES:
        print(f"Unknown pipeline: {pipeline_name}")
        return False
    
    try:
        print(f"Running {pipeline_name} pipeline in {environment} environment...")
        load_info = AVAILABLE_EXTRACTION_PIPELINES[pipeline_name](environment=environment)
        print(f"✓ {pipeline_name} pipeline completed successfully")
        return True
        
    except Exception as e:
        print(f"✗ {pipeline_name} pipeline failed: {str(e)}")
        return False


def run_extraction(args):
    """Run extraction pipelines."""
    environment = args.env or os.getenv("ENVIRONMENT", "dev")
    
    # If running in Cloud Run, parse from environment variables
    if os.getenv("CLOUD_RUN"):
        pipelines_env = os.getenv("PIPELINES", "all")
        pipelines = pipelines_env.split(",") if pipelines_env != "all" else ["all"]
    else:
        pipelines = args.pipelines or ["all"]
    
    # Determine which pipelines to run
    if "all" in pipelines:
        pipelines_to_run = list(AVAILABLE_EXTRACTION_PIPELINES.keys())
    else:
        pipelines_to_run = pipelines
    
    print(f"Starting extraction job - Environment: {environment}")
    print(f"Pipelines to run: {', '.join(pipelines_to_run)}")
    
    # Run pipelines
    results = {}
    for pipeline_name in pipelines_to_run:
        results[pipeline_name] = run_extraction_pipeline(pipeline_name, environment)
    
    # Summary
    successful = [name for name, success in results.items() if success]
    failed = [name for name, success in results.items() if not success]
    
    print(f"\nExecution Summary:")
    print(f"✓ Successful: {len(successful)} ({', '.join(successful) if successful else 'none'})")
    print(f"✗ Failed: {len(failed)} ({', '.join(failed) if failed else 'none'})")
    
    if failed:
        sys.exit(1)
    else:
        print("All pipelines completed successfully!")
        sys.exit(0)


def run_transformation(args):
    """Run dbt transformations."""
    environment = args.env or os.getenv("ENVIRONMENT", "dev")
    print(f"Starting dbt build job - Environment: {environment}")
    
    try:
        # Change to transformation directory
        transformation_dir = Path(__file__).parent / "transformation"
        
        result = subprocess.run(
            ["dbt", "build"],
            cwd=transformation_dir,
            capture_output=True,
            text=True,
            timeout=1800  # 30 minutes timeout for Cloud Run Jobs
        )
        
        if result.returncode == 0:
            print("✓ dbt build completed successfully")
            print(result.stdout)
            sys.exit(0)
        else:
            print(f"✗ dbt build failed: {result.stderr}")
            sys.exit(1)
            
    except subprocess.TimeoutExpired:
        print("✗ dbt build timed out")
        sys.exit(1)
    except Exception as e:
        print(f"✗ dbt build error: {str(e)}")
        sys.exit(1)


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(description="Toltek data stack CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Extraction command
    extraction_parser = subparsers.add_parser("extraction", help="Run extraction pipelines")
    extraction_parser.add_argument(
        "--pipelines", 
        nargs="+",
        choices=list(AVAILABLE_EXTRACTION_PIPELINES.keys()) + ["all"],
        help="Pipeline names to run (default: all)"
    )
    extraction_parser.add_argument(
        "--env",
        choices=["dev", "prod"],
        help="Environment to run in"
    )
    
    # Transformation command
    transformation_parser = subparsers.add_parser("transformation", help="Run dbt transformations")
    transformation_parser.add_argument(
        "--env",
        choices=["dev", "prod"],
        help="Environment to run in"
    )
    
    args = parser.parse_args()
    
    if args.command == "extraction":
        run_extraction(args)
    elif args.command == "transformation":
        run_transformation(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()