# README

This Rails project is intended as an example project for installing components via the
gem `weird_phlex` and the component pack `weird_phlex-dev_component_pack-testing`.

You are on the `avi-sample` branch. This branch contains the following:
- `rails new target_project -c tailwind -a propshaft` 
- The two gems mentioned abobe were added to the Gemfile as local dependencies.
  Their repos need to be checked out next to this repo
- `rails g shadcn-ui` and manual post installation steps

Use this branch for:
- Component generation testing, so:
  - Assume that all necessary dependencies are installed
  - Let `weird_phlex` generate components

After a test, do `git add .; git reset --hard HEAD`

If you want to preserve intermediate working states, do not commit to this branch. Branch away
from here and keep the changes in your own branch.

The only thing that's allowed to get committed here are preview views that are specific to
this component pack branch.

# Other branches

It is advised to keep branch names in sync with our dev component pack or this will get confusing.
