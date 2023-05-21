# MaskedAttribute

Add methods for working with a masked attribute in models.

## Usage

### Add field to database

Create the backing field. It should be appended with `_mask`. To add `roles` to `User`, the field would be `role_mask`.
The field must be an `integer` and should be `default: 0, null: false`.

Example migration:

```bash
bin/rails generate migration add_roles_to_user role_mask:integer
```

Modify the migration to set the default to 0, and disallow NULLs.

```ruby
class AddRolesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role_mask, :integer, null: false, default: 0
  end
end
```

```bash
bin/rails db:migrate
```

### Include in your model

```ruby
class User
  include MaskedAttribute

  masked_attribute :roles, %i[admin sysadmin]
end
```

The `masked_attribute` takes two arguments, `attribute_name` and `masks`.

`attribute_name` is the name for the masked attribute. For example
a name of `:roles` will create methods for the role_mask backing attribute.

`masks` is an array of symbols for the mask values. Order matters. You can change the values
of the masks, but if you change the order, you'll need to migrate existing data.

`masked_attribute` will add methods, scopes, and contants to `User` for working with `roles`.

```ruby
User::ROLES = masks
User::INDEXED_ROLES = {mask_value => mask, ...}

# Add attr_writer for the ATTRIBUTE_NAME. This should always be called with the full array of roles.
def roles= [array_of_masks]

# Add attr_reader for the ATTRIBUTE_NAME
def roles -> [array_of_masks]

# Add a scope with_ATTRIBUTE_NAME, which returns records that match ALL given masks
scope with_roles(*masks)

# Add a scope with_any_ATTRIBUTE_NAME, which returns records that match ANY given masks
scope with_any_roles(*masks)

# Add scopes for each MASK, to return records with the MASK in the name of the method
scope admins()
scope sysadmins()

# Add MASK? methods. Returns true if the mask is set
def admin?
def sysadmin?

# Add add_MASK! methods. Updates the backing field with the MASK value in the name.
def add_admin!
def add_sysadmin!

# Add remove_MASK! methods. Updates the backing field with the MASK value in the name.
def remove_admin!
def remove_sysadmin!

# Add a MASK from the mask_attribute_name
def add_role(mask)

# Remove a MASK from the mask_attribute_name
def remove_role(mask)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "masked_attribute"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install masked_attribute
```

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
