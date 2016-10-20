require "fences/fortified/version"
require "active_record"

module Fences
  module Fortified

    def self.included(base)
      base.extend(ClassMethods).fencable
    end

    def is_allowed_to?(*args)
      return true if resolve_implications(args)
      args = args.map(&:to_s)
      return true if self.permissions && self.permissions.where("name in (?)", args).any?
      allowed_to_in_relationships?(args)
    end

    def method_missing(method_name, *args)
      if method_name.to_s.match /(\w+)_implies/
        self.class.class_eval do
          define_method(method_name) do
            nil
          end
        end
        send(method_name)
      else
        super
      end
    end

    def allowed_to_in_relationships?(args)
      # Collect all of the has_many and belongs_to relationships
      # for the object to iterate over them and look for
      # the permission there
      allowed = false
      associations = self.class.reflect_on_all_associations(:has_many).map(&:name)
      associations += self.class.reflect_on_all_associations(:belongs_to).map(&:name)
      associations -=
        self.class.reject_permissions_from if self.class.respond_to?(:reject_permissions_from)
      associations.each do |assoc|
        relations = self.send(assoc)
        if relations.is_a?(Array)
          relations.each do |relation|
            relation_permissions = relation.permissions rescue nil
            if relation_permissions && relation_permissions.any?
              allowed = relation_permissions.where("name in (?)", args).any?
              return true if allowed
            end
          end
        else
          assoc_permissions = relations.permissions rescue nil
          if assoc_permissions && assoc_permissions.any?
            allowed = assoc_permissions.where("name in (?)", args).any?
            return true if allowed
          end
        end
      end
      false
    end

    def resolve_implications(args)
      # Add permission names that are implied by
      # each of the permissions passed in
      return true if args.include?(:all)
      return false if args.empty?
      args.each do |arg|
        args << self.send(arg.to_s + "_implies") if arg.is_a?(Symbol)
      end
      args.compact!
      false
    end

    module ClassMethods
      def fencable
        has_many :bastions, as: :fortifiable
        has_many :permissions, through: :bastions
      end
    end

  end
end
