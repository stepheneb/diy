require File.dirname(__FILE__) + '/../test_helper'
require 'probe_types_controller'

# Re-raise errors caught by the controller.
class ProbeTypesController; def rescue_action(e) raise e end; end

class ProbeTypesControllerTest < Test::Unit::TestCase
  fixtures :probe_types

  def setup
    @controller = ProbeTypesController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:probe_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_probe_type
    old_count = ProbeType.count
    post :create, :probe_type => { }
    assert_equal old_count+1, ProbeType.count
    
    assert_redirected_to probe_type_path(assigns(:probe_type))
  end

  def test_should_show_probe_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_probe_type
    put :update, :id => 1, :probe_type => { }
    assert_redirected_to probe_type_path(assigns(:probe_type))
  end
  
  def test_should_destroy_probe_type
    old_count = ProbeType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ProbeType.count
    
    assert_redirected_to probe_types_path
  end
end
