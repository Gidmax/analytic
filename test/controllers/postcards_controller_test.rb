require 'test_helper'

class PostcardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @postcard = postcards(:one)
  end

  test "should get index" do
    get postcards_url
    assert_response :success
  end

  test "should get new" do
    get new_postcard_url
    assert_response :success
  end

  test "should create postcard" do
    assert_difference('Postcard.count') do
      post postcards_url, params: { postcard: { desc: @postcard.desc, ix: @postcard.ix, src: @postcard.src, title: @postcard.title } }
    end

    assert_redirected_to postcard_url(Postcard.last)
  end

  test "should show postcard" do
    get postcard_url(@postcard)
    assert_response :success
  end

  test "should get edit" do
    get edit_postcard_url(@postcard)
    assert_response :success
  end

  test "should update postcard" do
    patch postcard_url(@postcard), params: { postcard: { desc: @postcard.desc, ix: @postcard.ix, src: @postcard.src, title: @postcard.title } }
    assert_redirected_to postcard_url(@postcard)
  end

  test "should destroy postcard" do
    assert_difference('Postcard.count', -1) do
      delete postcard_url(@postcard)
    end

    assert_redirected_to postcards_url
  end
end
