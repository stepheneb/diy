require File.dirname(__FILE__) + '/../test_helper'
require 'models_controller'

# Re-raise errors caught by the controller.
class ModelsController; def rescue_action(e) raise e end; end

class ModelsControllerTest < Test::Unit::TestCase
  fixtures :models

  def setup
    @controller = ModelsController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:models)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_model
    old_count = Model.count
    post :create, :model => { }
    assert_equal old_count+1, Model.count
    
    assert_redirected_to model_path(assigns(:model))
  end

  def test_should_show_model
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_model
    put :update, :id => 1, :model => { }
    assert_redirected_to model_path(assigns(:model))
  end
  
  def test_should_destroy_model
    old_count = Model.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Model.count
    
    assert_redirected_to models_path
  end
end
