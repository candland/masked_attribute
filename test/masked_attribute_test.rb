require "test_helper"

class MaskedAttributeTest < ActiveSupport::TestCase
  attr_reader :user

  setup do
    @user = User.new
  end

  test "it has a version number" do
    assert MaskedAttribute::VERSION
  end

  test "should make constants" do
    assert User.const_defined?(:ROLES)
    assert User.const_defined?(:INDEXED_ROLES)
  end

  test "should get roles" do
    assert_equal [], user.roles
  end

  test "should set roles" do
    user.roles = [:admin]
    assert user.admin?
    assert_not user.sysadmin?

    user.roles = [:sysadmin]
    assert_not user.admin?
    assert user.sysadmin?
  end

  test "should add roles" do
    assert_not user.admin?

    user.add_admin!
    assert_equal [:admin], user.roles
    assert user.admin?
    assert_not user.sysadmin?

    user.add_sysadmin!
    assert_equal [:admin, :sysadmin], user.roles
    assert user.admin?
    assert user.sysadmin?

    user.add_sysadmin!
    user.add_admin!
    assert_equal [:admin, :sysadmin], user.roles
  end

  test "should remove roles" do
    user.add_admin!
    user.add_sysadmin!
    assert_equal [:admin, :sysadmin], user.roles

    user.remove_admin!
    assert_equal [:sysadmin], user.roles

    user.remove_sysadmin!
    assert_equal [], user.roles

    user.remove_admin!
    user.remove_sysadmin!
    assert_equal [], user.roles
  end

  test "should provide scopes" do
    assert_equal 0, User.admins.count

    user.add_admin!
    assert_equal 1, User.admins.count
    assert_equal 1, User.with_roles(:admin).count
    assert_equal 0, User.with_roles(:admin, :sysadmin).count
    assert_equal 1, User.with_any_roles(:admin, :sysadmin).count

    user.add_sysadmin!
    assert_equal 1, User.admins.count
    assert_equal 1, User.with_roles(:admin, :sysadmin).count
  end
end
