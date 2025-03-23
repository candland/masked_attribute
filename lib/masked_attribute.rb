require "masked_attribute/version"
require "masked_attribute/railtie"

module MaskedAttribute
  extend ActiveSupport::Concern

  class_methods do
    def mask_from values, check_values
      (check_values & values).map { |r| 2**values.index(r) }.inject(0, :+)
    end

    private

    # Add methods for working with a masked attribute in the model
    #
    # attribute_name = the name for the masked attribute. For example
    #   a name of :roles will create methods for the role_mask backing attribute
    #
    # masks = an array of symbols for the mask values. Order matters.
    #   %i[admin sysadmin]
    #
    # With those examples the follow methods & scopes will be created:
    #
    # scope with_roles(*masks)
    # scope with_any_roles(*masks)
    #
    # scope admins()
    # scope sysadmins()
    #
    # def admin?
    # def sysadmin?
    #
    # def add_admin!
    # def remove_admin!
    #
    # def add_sysadmin!
    # def remove_sysadmin!
    #
    # def roles=(array of masks)
    # def roles -> array of masks
    #
    # def add_role(ROLE)
    # def remove_role(ROLE)
    #
    # Class::ROLES = masks
    # Class::INDEXED_ROLES = {mask_value => mask, ...}
    def masked_attribute attribute_name, masks
      attribute_name = attribute_name.to_s
      mask_attribute_name = "#{attribute_name.singularize}_mask"
      masks_const_name = attribute_name.upcase
      masks = masks.freeze

      indexed_masks = masks.map { |v| [2**masks.index(v), v] }.to_h.freeze

      const_set masks_const_name, masks
      const_set :"INDEXED_#{masks_const_name}", indexed_masks

      # Add a scope with_ATTRIBUTE_NAME, which returns records that match ALL given masks
      self.class.define_method(:"with_#{attribute_name}") do |*values|
        ok_mask = mask_from(masks, values)
        where("#{mask_attribute_name} & ? = ?", ok_mask, ok_mask)
      end

      # Add a scope with_any_ATTRIBUTE_NAME, which returns records that match ANY given masks
      self.class.define_method(:"with_any_#{attribute_name}") do |*values|
        ok_mask = mask_from(masks, values)
        where("#{mask_attribute_name} & ? != 0", ok_mask)
      end

      masks.each do |value|
        value_int = 2**masks.index(value)

        # Add MASK? method. Returns true if the mask is set
        define_method(:"#{value}?") do
          has = __send__(mask_attribute_name)
          has & value_int > 0
        end

        # Add add_MASK! method. Updates the MASKS_mask with the MASK in the name
        define_method(:"add_#{value}!") do
          has = __send__(mask_attribute_name)
          update!("#{mask_attribute_name}": (has | value_int))
        end

        # Add remove_MASK! method. Updates the MASKS_mask without the MASK in the name
        define_method(:"remove_#{value}!") do
          has = __send__(mask_attribute_name)
          update!("#{mask_attribute_name}": (has & ~value_int))
        end

        # Add scope MASK, to return records with the MASK in the name
        scope value.to_s.pluralize, -> { __send__(:"with_#{attribute_name}", value) }
      end

      # Add attr_writer for the attribute_name
      define_method(:"#{attribute_name}=") do |value|
        value = Array.wrap(value).map(&:to_sym)
        __send__(:"#{mask_attribute_name}=", self.class.mask_from(masks, value))
      end

      # Add attr_reader for the attribute_name
      define_method(attribute_name.to_s) do
        masks.reject do |r|
          ((__send__(mask_attribute_name).to_i || 0) & 2**masks.index(r)).zero?
        end
      end

      # Add a MASK from the mask_attribute_name
      # params: value = the mask to add
      define_method(:"add_#{attribute_name.singularize}") do |value|
        value_int = 2**masks.index(value)
        has = __send__(mask_attribute_name)
        __send__(:"#{mask_attribute_name}=", has | value_int)
      end

      # Remove a MASK from the mask_attribute_name
      # params: value = the mask to remove
      define_method(:"remove_#{attribute_name.singularize}") do |value|
        value_int = 2**masks.index(value)
        has = __send__(mask_attribute_name)
        __send__(:"#{mask_attribute_name}=", has & ~value_int)
      end
    end
  end
end
