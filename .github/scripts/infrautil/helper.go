package main

import (
	"errors"
	"log/slog"

	"github.com/google/subcommands"
)

var ErrUsage = errors.New("bad usage")

func ExecuteHelper(f func() error) subcommands.ExitStatus {
	if err := f(); err != nil {
		if errors.Is(err, ErrUsage) {
			slog.Error(ErrUsage.Error())
			return subcommands.ExitUsageError
		}
		slog.Error("error", slog.Any("error", err))
		return subcommands.ExitFailure
	}
	return subcommands.ExitSuccess
}
