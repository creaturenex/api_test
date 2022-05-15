class PostsController < ApplicationController
  require 'rest-client'
  require 'json'
  URL = "https://api.hatchways.io/assessment/blog/posts?tag="
  SORTBY = %w(id reads likes popularity)
  DIRECTION = %w(asc desc)

  rescue_from ActionController::ParameterMissing, with: :tag_missing

  def index
    params.require(:tags)
    params.permit(:sortBy, :direction)
    params[:sortBy] = 'id' if params[:sortBy].nil?
    params[:direction] = 'asc' if params[:direction].nil?

    search_by_tag

    if valid_sort_by?
      @posts = sort_by
    else
      return render json: {"error": "sortBy parameter is invalid"}, :status => :bad_request
    end

    if valid_direction?
      @posts = @posts.reverse
    else
      return render json: {"error": "direction parameter is invalid"}, :status => :bad_request
    end

    render json: { 'posts': @posts}

  end


  def search_by_tag # this can be multi-threaded
    search_terms = params[:tags].split(',')
    result = search_terms.map do |tag|
      response = RestClient.get(URL + tag)
      JSON.parse(response)['posts']
    end
    @posts = result.flatten.uniq
  end

  def sort_by
    #sorted in asc order by default if no direction given
    sorted_result = @posts.sort_by { |hash| hash[params[:sortBy]] }
  end

  def valid_sort_by? # this will trigger if sortBy is nil
    SORTBY.include?(params[:sortBy])
  end

  def valid_direction?
    DIRECTION.include?(params[:direction])
  end

  def ping
    render json: { "success": true }
  end

  def tag_missing
    render json: {"error": "Tags parameter is required"}, :status => :bad_request
  end
  # private
  # common format if we are creating a new object from a model
  # def posts_params
  #   params.require(:tags).permit(:sortBy, :direction).with_defaults(sortBy: 'id', direction: 'asc')
  # end


end
