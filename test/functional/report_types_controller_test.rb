require File.dirname(__FILE__) + '/../test_helper'

class ReportTypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:report_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_report_type
    assert_difference('ReportType.count') do
      post :create, :report_type => { }
    end

    assert_redirected_to report_type_path(assigns(:report_type))
  end

  def test_should_show_report_type
    get :show, :id => report_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => report_types(:one).id
    assert_response :success
  end

  def test_should_update_report_type
    put :update, :id => report_types(:one).id, :report_type => { }
    assert_redirected_to report_type_path(assigns(:report_type))
  end

  def test_should_destroy_report_type
    assert_difference('ReportType.count', -1) do
      delete :destroy, :id => report_types(:one).id
    end

    assert_redirected_to report_types_path
  end
end
