# Fences::Fortified

A gem to implement authorization in your Rails app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fences-fortified'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fences-fortified

## Usage

The gem will look for the relationship between your model and the permission you send it as 
a direct relationship, but will also search in all of your model's belongs_to and has_many relationships to see if these comply with the permission.

For example, your user may not explicitly be allowed to perform a certain action but may have an admin role that is allowed.  So, your user will transparently be able to perform the action as expected.

You may blacklist the relationships from which you'd prefer not to obtain permissions from. For example, a user may belong to another user, :administrated_by. In this case, we wouldn't want the permissions from this administrator to filter through to our user.

You may also send more than one permission through. If at least one is allowed, it returns true.

Finally, you can also define implications.  You can set that a particular permission implies that a list of other permissions will be allowed as well.  There is one implication already in place. That is, if you define an :all permission, the gem will allow any permission for any fortifiable type.

Version 0.1.0 is still just an MVP.  TODOs include generating the migration files
ready for their execution to include the Permissions and Bastions tables needed for this gem to work.

For now, you may generate a Permission model and its migration with the necessary field of :name.  And the Bastion model with polymorphic relationship to fortifiable types and permission ids as such:

Migrations:
```ruby
# establishes many to many relationship between fortifiable types and permissions
create_table :bastions do |t|
  t.references :fortifiable, polymorphic: true, index: true
  t.integer :permission_id

  t.timestamps
end
# the permissions you want to set in your application will live here
create_table :permissions do |t|
  t.string :name
  t.text   :description

  t.timestamps
end
```

Models:
```ruby
class Bastion < ActiveRecord::Base

  belongs_to :fortifiable, polymorphic: true
  belongs_to :permission

end

class Permission < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

end

class User < ActiveRecord::Base
  include Fences::Fortified
  
  # optional: blacklist
  def reject_permissions_from
    [:administrated_by]
  end
  
  # optional: implications
  # Important: must start with permission name and end in _implies
  def create_new_users_implies
    [:view_user_profiles, :edit_users]
  end
  
end
```
Finally and most importantly, an example usage would be:

```ruby
unless $user.is_allowed_to?(:create_new_users)
  # your code here
end
```

In the models where you'd want to apply permissions, add:
```ruby
include Fences::Fortified
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/giuliani/fences-fortified. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

