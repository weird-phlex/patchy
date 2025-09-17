# Delegation testing strategy

Tests here should
- invoke Patchy::CLI (via the `run` helper)
- stub everything within Patchy::Main
- test non-interactive AND interactive CLI features
