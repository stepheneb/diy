require File.dirname(__FILE__) + '/../test_helper'

class VendorInterfacesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:vendor_interfaces)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_vendor_interface
    assert_difference('VendorInterface.count') do
      post :create, :vendor_interface => { }
    end

    assert_redirected_to vendor_interface_path(assigns(:vendor_interface))
  end

  def test_should_show_vendor_interface
    get :show, :id => vendor_interfaces(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => vendor_interfaces(:one).id
    assert_response :success
  end

  def test_should_update_vendor_interface
    put :update, :id => vendor_interfaces(:one).id, :vendor_interface => { }
    assert_redirected_to vendor_interface_path(assigns(:vendor_interface))
  end

  def test_should_destroy_vendor_interface
    assert_difference('VendorInterface.count', -1) do
      delete :destroy, :id => vendor_interfaces(:one).id
    end

    assert_redirected_to vendor_interfaces_path
  end
end
