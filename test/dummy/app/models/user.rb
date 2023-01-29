class User < ApplicationRecord
  include MaskedAttribute

  masked_attribute :roles, %i[admin sysadmin]
end
