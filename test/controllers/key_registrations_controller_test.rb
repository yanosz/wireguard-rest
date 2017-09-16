require 'test_helper'

class KeyRegistrationsControllerTest < ActionController::TestCase
  setup do
    @key_registration = key_registrations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_registrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_registration" do
    assert_difference('KeyRegistration.count') do
      post :create, key_registration: { document: @key_registration.document, pubkey: @key_registration.pubkey }
    end

    assert_redirected_to key_registration_path(assigns(:key_registration))
  end

  test "should show key_registration" do
    get :show, id: @key_registration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_registration
    assert_response :success
  end

  test "should update key_registration" do
    patch :update, id: @key_registration, key_registration: { document: @key_registration.document, pubkey: @key_registration.pubkey }
    assert_redirected_to key_registration_path(assigns(:key_registration))
  end

  test "should destroy key_registration" do
    assert_difference('KeyRegistration.count', -1) do
      delete :destroy, id: @key_registration
    end

    assert_redirected_to key_registrations_path
  end
end
