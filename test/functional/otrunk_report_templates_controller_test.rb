require File.dirname(__FILE__) + '/../test_helper'

class OtrunkReportTemplatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:otrunk_report_templates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_otrunk_report_template
    assert_difference('OtrunkReportTemplate.count') do
      post :create, :otrunk_report_template => { }
    end

    assert_redirected_to otrunk_report_template_path(assigns(:otrunk_report_template))
  end

  def test_should_show_otrunk_report_template
    get :show, :id => otrunk_report_templates(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => otrunk_report_templates(:one).id
    assert_response :success
  end

  def test_should_update_otrunk_report_template
    put :update, :id => otrunk_report_templates(:one).id, :otrunk_report_template => { }
    assert_redirected_to otrunk_report_template_path(assigns(:otrunk_report_template))
  end

  def test_should_destroy_otrunk_report_template
    assert_difference('OtrunkReportTemplate.count', -1) do
      delete :destroy, :id => otrunk_report_templates(:one).id
    end

    assert_redirected_to otrunk_report_templates_path
  end
end
