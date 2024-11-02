package main

import (
	"context"
	"flag"
	"log/slog"
	"os"

	"github.com/google/subcommands"
	"github.com/phsym/console-slog"
)

func main() {
	logger := slog.New(
		console.NewHandler(os.Stderr, &console.HandlerOptions{
			AddSource: true,
			Level:     slog.LevelInfo,
		}),
	)
	slog.SetDefault(logger)

	subcommands.Register(subcommands.HelpCommand(), "")
	subcommands.Register(subcommands.FlagsCommand(), "")
	subcommands.Register(subcommands.CommandsCommand(), "")
	subcommands.Register(&namespaceCmd{}, "")

	flag.Parse()
	ctx := context.Background()
	os.Exit(int(subcommands.Execute(ctx)))
}
