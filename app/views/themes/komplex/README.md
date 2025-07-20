# Komplex Theme for Spree

This theme integrates the Komplex Marketplace template into Spree's theming system.

## Structure

The theme is organized as follows:

- `lib/spree/themes/komplex_theme.rb`: The theme class that registers with Spree
- `app/views/themes/komplex/`: The theme views directory
  - `layouts/`: Layout templates
  - `shared/`: Shared partials (header, footer, etc.)
  - `listings/`: Marketplace listing templates

## Usage

The theme is automatically registered with Spree in the `config/initializers/spree.rb` file:

```ruby
Rails.application.config.spree.themes << Spree::Themes::KomplexTheme
```

## Customization

To customize the theme:

1. Edit the templates in `app/views/themes/komplex/`
2. Add new templates as needed, following the same directory structure

## Adding More Templates

To add more templates from the Komplex Marketplace to the Spree theme:

1. Create the appropriate directory structure in `app/views/themes/komplex/`
2. Copy the template from `app/views/komplex/storefront/` to the corresponding location in `app/views/themes/komplex/`
3. Update any paths or references as needed

For example, to add the `show.html.erb` template for listings:

```
mkdir -p app/views/themes/komplex/listings
cp app/views/komplex/storefront/listings/show.html.erb app/views/themes/komplex/listings/
```

## Helpers

The theme includes a helper module in `app/helpers/themes/komplex/theme_helper.rb` that provides methods used by the templates.