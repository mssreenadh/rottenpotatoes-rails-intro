class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  #Part3 attempt
  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings

    if !session.key?(:ratings) || !session.key?(:sort_by)
      @all_ratings_hash = Hash[@all_ratings.collect {|key| [key, '1']}]
      session[:ratings] = @all_ratings_hash if !session.key?(:ratings)
      session[:sort_by] = '' if !session.key?(:sort_by)
      redirect_to movies_path(:ratings => @all_ratings_hash, :sort_by => '') and return
    end
    
    if (!params.has_key?(:ratings) && session.key?(:ratings)) ||
      (!params.has_key?(:sort_by) && session.key?(:sort_by))
      redirect_to movies_path(:ratings => Hash[session[:ratings].collect {|key| [key, '1']}], :sort_by => session[:sort_by]) and return
    end

    @ratings_to_show = params[:ratings].keys
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]
    session[:ratings] = @ratings_to_show

    @movies = Movie.with_ratings(@ratings_to_show)
    @movies = @movies.order(params[:sort_by]) if params[:sort_by] != ''
    session[:sort_by] = params[:sort_by]
    @title_header = (params[:sort_by]=='title') ? 'hilite bg-warning' : ''
    @release_date_header = (params[:sort_by]=='release_date') ? 'hilite bg-warning' : ''
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
