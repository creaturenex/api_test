require 'rails_helper'

file = File.join(Rails.root, 'spec', 'requests', 'test_1_hash.json')
test_1_hash = File.read(file)

file = File.join(Rails.root, 'spec', 'requests', 'test_2_hash.json')
test_2_hash = File.read(file)

RSpec.describe 'Post API', type: :request do
  # Test suite for GET /posts
  describe 'GET /posts' do
    # valid payload
    let(:valid_attributes) { { tags: 'history,tech', sortBy: 'likes', direction: 'desc' } }

    context 'when the request is valid with only required param' do
      before { get '/posts', params: { tags: 'tech' } }

      # tags results are sorted in ascending or by id due to hatchway api
      it 'creates a sorted list by id and in ascending order' do
        expect(response.body).eql?(test_2_hash)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is valid with required and optional params' do
      before { get '/posts', params: valid_attributes }

      it 'creates a sorted list by likes and in descending order' do
        expect(response.body).eql?(test_1_hash)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is valid with optional params default values' do
      before { get '/posts', params: { tags: 'history,tech', sortBy: nil, direction: nil } }

      # testing behavior not implementation, refer to line12-14 in post controller for implementation
      it 'creates a sorted list by id and in ascending order' do
        result_hash = JSON.parse(response.body)['posts']

        expect(result_hash.first[:id]).eql?(1)
        expect(result_hash.last[:id]).eql?(100)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid due to tag' do
      before { get '/posts', params: {tags: nil}  }

      it 'returns a validation failure message' do
        expect(response.body).to match(/Tags parameter is required/)
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request is invalid due to sortBy' do
      before { get '/posts', params: {tags: 'tech', sortBy: ''} }

      it 'returns a validation failure message' do
        expect(response.body).to match(/sortBy parameter is invalid/)
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end

    context 'when the request is invalid due to direction' do
      before { get '/posts', params: {tags: 'tech', sortBy: 'id', direction: 'up'} }

      it 'returns a validation failure message' do
        expect(response.body).to match(/direction parameter is invalid/)
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end
  end

  # Test suite for PING /ping
  describe 'GET /ping' do
    it 'returns a success message' do
      get "/ping"
      expect(response).eql?({"success": true})
    end

    it 'returns status code 200' do
      get "/ping"
      expect(response).to have_http_status(200)
    end
  end
end
