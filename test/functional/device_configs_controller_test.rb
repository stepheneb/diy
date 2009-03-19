require File.dirname(__FILE__) + '/../test_helper'

class DeviceConfigsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:device_configs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_device_config
    assert_difference('DeviceConfig.count') do
      post :create, :device_config => { }
    end

    assert_redirected_to device_config_path(assigns(:device_config))
  end

  def test_should_show_device_config
    get :show, :id => device_configs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => device_configs(:one).id
    assert_response :success
  end

  def test_should_update_device_config
    put :update, :id => device_configs(:one).id, :device_config => { }
    assert_redirected_to device_config_path(assigns(:device_config))
  end

  def test_should_destroy_device_config
    assert_difference('DeviceConfig.count', -1) do
      delete :destroy, :id => device_configs(:one).id
    end

    assert_redirected_to device_configs_path
  end
end
