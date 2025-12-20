"""Logging configuration for infrautil."""

import logging
import sys
from typing import Literal

LogLevel = Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]


def setup_logging(level: LogLevel = "INFO", verbose: bool = False) -> logging.Logger:
    """Configure logging for the application.

    Args:
        level: Logging level
        verbose: Enable verbose output

    Returns:
        Configured logger instance
    """
    if verbose:
        level = "DEBUG"

    numeric_level = getattr(logging, level)

    logging.basicConfig(
        level=numeric_level,
        format="%(levelname)s: %(message)s",
        stream=sys.stderr,
    )

    return logging.getLogger("infrautil")
