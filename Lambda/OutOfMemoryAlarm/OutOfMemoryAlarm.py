import os


def lambda_handler(event, context):
    mem_size_mb = int(
        os.environ["LAMBDA_FUNCTION_MEMORY_SIZE"]
    )  # Get the configured memory size from the Lambda from terraform deployment
    print(f"Configured Lambda memory: {mem_size_mb} MB")

    # Allocate memory slightly over the limit
    bytes_to_allocate = (mem_size_mb + 10) * 1024 * 1024  # exceed by 10 MB
    memory_hog = "X" * bytes_to_allocate
    return len(memory_hog)
