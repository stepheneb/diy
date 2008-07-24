require File.dirname(__FILE__) + '/../test_helper'
require 'model_types_controller'

# Re-raise errors caught by the controller.
class ModelTypesController; def rescue_action(e) raise e end; end

class ModelTypesControllerTest < Test::Unit::TestCase
  fixtures :model_types

  def setup
    @controller = ModelTypesController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:model_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_model_type
    old_count = ModelType.count
    post :create, :model_type => { }
    assert_equal old_count+1, ModelType.count
    
    assert_redirected_to model_type_path(assigns(:model_type))
  end

  def test_should_show_model_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_model_type
    put :update, :id => 1, :model_type => { }
    assert_redirected_to model_type_path(assigns(:model_type))
  end
  
  def test_should_destroy_model_type
    old_count = ModelType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ModelType.count
    
    assert_redirected_to model_types_path
  end
end
