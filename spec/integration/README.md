# Integration testing strategy

Tests here should
- invoke Patchy::CLI (via the `run` helper)
- use the fixtures for test setup
- make assertions about actual files
- only test the non-interactive parts of the CLI

They should NOT:
- invoke the binaries (only 2 lines, not worth it)
- test interactive CLI features
