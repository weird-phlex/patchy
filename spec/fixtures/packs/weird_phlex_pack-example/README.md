# Weird Phlex Dev Component Pack Testing

Extracted from Avi Flombaums gem `shadcn-rails`.

Used shared parts:
- Rakefile
- form_builder
- helper
- partial

Used component parts:
- helper
- partial
- stimulus_controller

Quirks:
- subdirectory in `tabs_component/partial`
- namespace directory `namespace_subdirectory/` containing `button_component` and `collapsible_component`

## Installation (dev setup)

```ruby
# Gemfile
gem "weird_phlex-dev_component_pack-testing", path: '../weird_phlex-dev_component_pack-testing'
```

## Usage

This is a component pack for `weird_phlex`. Read the documentation of that gem to get more info
about the installation.
